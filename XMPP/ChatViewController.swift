import UIKit
import JSQMessagesViewController
import XMPPFramework

class ChatViewController: JSQMessagesViewController, OneMessageDelegate,ContactPickerDelegate {
	
	let appDelegate = UIApplication.shared.delegate as? AppDelegate
	var messages = NSMutableArray()
	var recipient: XMPPUserCoreDataStorageObject?
	var firstTime = true
	var userDetails = UIView()
	
	// Mark: Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.navigationItem.setHidesBackButton(false, animated:true);

		SendReceiveChatMessage.sharedInstance.delegate = self
  
		if ChatConnector.sharedInstance.isConnected() {
			self.senderId = ChatConnector.sharedInstance.xmppStream?.myJID.bare()
			self.senderDisplayName = ChatConnector.sharedInstance.xmppStream?.myJID.bare()
		}
		
		self.collectionView!.collectionViewLayout.springinessEnabled = false
		self.inputToolbar!.contentView!.leftBarButtonItem!.isHidden = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if let recipient = recipient {
			self.navigationItem.rightBarButtonItems = []
			
                	navigationItem.title = recipient.displayName
			
			DispatchQueue.main.async(execute: { () -> Void in
				self.messages = SendReceiveChatMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
				self.finishReceivingMessage(animated: true)
			})
		} else {
//			if userDetails == nil {
                        	navigationItem.title = kNewMessageString
//            		}
			
			self.inputToolbar!.contentView!.rightBarButtonItem!.isEnabled = false
			self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ChatViewController.addRecipient)), animated: true)
			if firstTime {
				firstTime = false
				addRecipient()
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.scrollToBottom(animated: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
        userDetails.removeFromSuperview()
    }
	
	// Mark: Private methods
	
	func addRecipient() {
		let navController = self.storyboard?.instantiateViewController(withIdentifier: kContactListId) as? UINavigationController
		let contactController: ContactListTableViewController? = navController?.viewControllers[0] as? ContactListTableViewController
		contactController?.delegate = self
		
		self.present(navController!, animated: true, completion: nil)
	}
	
	func didSelectContact(_ recipient: XMPPUserCoreDataStorageObject) {
		self.recipient = recipient
//		if userDetails == nil {
            		navigationItem.title = recipient.displayName
//        	}
		
		if !ChatsHistory.knownUserForJid(jidStr: recipient.jidStr) {
			ChatsHistory.addUserToChatList(jidStr: recipient.jidStr)
		} else {
			messages = SendReceiveChatMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
			finishReceivingMessage(animated: true)
		}
	}
	
	// Mark: JSQMessagesViewController method overrides
	
	var isComposing = false
    	var timer: Timer?
    
	override func textViewDidChange(_ textView: UITextView) {
        	super.textViewDidChange(textView)
        
        	if textView.text.characters.count == 0 {
            		if isComposing {
                		hideTypingIndicator()
            		}
        	} else {
            		timer?.invalidate()
            		if !isComposing {
                		self.isComposing = true
                		SendReceiveChatMessage.sendIsComposingMessage((recipient?.jidStr)!, completionHandler: { (stream, message) -> Void in
                    			self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatViewController.hideTypingIndicator), userInfo: nil, repeats: false)
                		})
            		} else {
                		self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatViewController.hideTypingIndicator), userInfo: nil, repeats: false)
            		}
        	}
    	}
    
    	func hideTypingIndicator() {
        	if let recipient = recipient {
            		self.isComposing = false
            		SendReceiveChatMessage.sendIsComposingMessage((recipient.jidStr)!, completionHandler: { (stream, message) -> Void in
            
            		})
        	}
    	}
	
	override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

		let fullMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: Date(), text: text)
        messages.add(fullMessage)
		
		if let recipient = recipient {
			SendReceiveChatMessage.sendMessage(text, to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
				JSQSystemSoundPlayer.jsq_playMessageSentSound()
				self.finishSendingMessage(animated: true)
			})
		}
	}
	
	// Mark: JSQMessages CollectionView DataSource
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        return message
        
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let outgoingBubbleImageData = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        let incomingBubbleImageData = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        if message.senderId == self.senderId {
            return outgoingBubbleImageData
        }
        
        return incomingBubbleImageData

    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if message.senderId == self.senderId {
            if let photoData = ChatConnector.sharedInstance.xmppvCardAvatarModule?.photoData(for: ChatConnector.sharedInstance.xmppStream?.myJID) {
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: photoData), diameter: 30)
                return senderAvatar
            } else {
                let senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: kSRString, backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: kHelveticaNeueFont, size: 14.0), diameter: 30)
                return senderAvatar
            }
        } else {
            if let photoData = ChatConnector.sharedInstance.xmppvCardAvatarModule?.photoData(for: recipient!.jid!) {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: photoData), diameter: 30)
                return recipientAvatar
            } else {
                let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: kSRString, backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: kHelveticaNeueFont, size: 14.0)!, diameter: 30)
                return recipientAvatar
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil

    }
    
    
    
    /*
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
		let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		return message
	}
 
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
		let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		let bubbleFactory = JSQMessagesBubbleImageFactory()
		
		let outgoingBubbleImageData = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
		let incomingBubbleImageData = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
		
		if message.senderId == self.senderId {
			return outgoingBubbleImageData
		}
		
		return incomingBubbleImageData
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
		let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		if message.senderId == self.senderId {
			if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoData(for: OneChat.sharedInstance.xmppStream?.myJID) {
				let senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: photoData), diameter: 30)
				return senderAvatar
			} else {
				let senderAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: kSRString, backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: kHelveticaNeueFont, size: 14.0), diameter: 30)
				return senderAvatar
			}
		} else {
			if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoData(for: recipient!.jid!) {
				let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: photoData), diameter: 30)
				return recipientAvatar
			} else {
				let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: kSRString, backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: kHelveticaNeueFont, size: 14.0)!, diameter: 30)
				return recipientAvatar
			}
		}
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: IndexPath!) -> NSAttributedString! {
		if indexPath.item % 3 == 0 {
			let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
			return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
		}
		
		return nil;
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: IndexPath!) -> NSAttributedString! {
		let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		if message.senderId == self.senderId {
			return nil
		}
		
		if indexPath.item - 1 > 0 {
			let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
			if previousMessage.senderId == message.senderId {
				return nil
			}
		}
		
		return nil
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: IndexPath!) -> NSAttributedString! {
		return nil
	}
	
 */
	// Mark: UICollectionView DataSource
    
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.messages.count
	}
	
    
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell

		//let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
		let msg: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		if !msg.isMediaMessage {
			if msg.senderId == self.senderId {
				cell.textView!.textColor = UIColor.black
				cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.black, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
			} else {
				cell.textView!.textColor = UIColor.white
				cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.white, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
			}
		}
		
		return cell
	}
	
	// Mark: JSQMessages collection view flow layout delegate
	
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
            if indexPath.item % 3 == 0 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
            
            return 0.0

    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        let currentMessage: JSQMessage = self.messages[indexPath.item] as! JSQMessage
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault

    }
   
        
    func collectionView(collectionView: JSQMessagesCollectionView!, layout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath: IndexPath!)-> CGFloat {
        return 0.0
    }
        
        
       /*
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: IndexPath!) -> CGFloat {
		if indexPath.item % 3 == 0 {
			return kJSQMessagesCollectionViewCellLabelHeightDefault
		}
		
		return 0.0
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: IndexPath!) -> CGFloat {
		let currentMessage: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		if currentMessage.senderId == self.senderId {
			return 0.0
		}
		
		if indexPath.item - 1 > 0 {
			let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
			if previousMessage.senderId == currentMessage.senderId {
				return 0.0
			}
		}
		
		return kJSQMessagesCollectionViewCellLabelHeightDefault
	}
 
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: IndexPath!) -> CGFloat {
		return 0.0
	}*/

	
	// Mark: Chat message Delegates
	
	func oneStream(_ sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject) {
		if message.isChatMessageWithBody() {
			//let displayName = user.displayName
			
			JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
			
			if let msg: String = message.forName(kBodyString)?.stringValue {
				if let from: String = message.attribute(forName: kFromString)?.stringValue {
					let message = JSQMessage(senderId: from, senderDisplayName: from, date: Date(), text: msg)
					messages.add(message)
					
					self.finishReceivingMessage(animated: true)
				}
			}
		}
	}
	
	func oneStream(_ sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject) {
		self.showTypingIndicator = !self.showTypingIndicator
		self.scrollToBottom(animated: true)
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
