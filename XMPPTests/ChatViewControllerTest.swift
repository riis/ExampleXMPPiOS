import XCTest
import Foundation
import UIKit
import xmpp_messenger_ios
import JSQMessagesViewController
@testable import Smack

class ChatsViewControllerTest: XCTestCase {
    
    override func tearDown(){
        super.tearDown()
    }
    
    let chatViewController = ChatViewController()
    
    override func setUp(){
        super.setUp()
        
        let chatViewController = ChatViewController()
       // chatViewController.messages = makeNormalConversation()
        OneChat.start(true, delegate: nil) { (stream, error) -> Void in
            if let _ = error {
                //handle start errors here
                print(kAppDelegateErrors)
            } 
        }
        
        // This ensures that ViewDidLoad() has been called
        let _ = chatViewController.view
        
        //let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        //openChats = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        //openChats.loadView()
    }
    
    func testSendButtonAction() {
        let _ = chatViewController.view
        let button = self.chatViewController.inputToolbar.sendButtonOnRight ? self.chatViewController.inputToolbar.contentView!.rightBarButtonItem! : self.chatViewController.inputToolbar.contentView!.leftBarButtonItem!
        let text = "Testing text"
        let senderId = "daithi@jwchat.org"
        let senderDisplayName = "daithi@jwchat.org"
        let date = Date()
        
        let originalCount = self.chatViewController.messages.count
        
        self.chatViewController.didPressSendButton(button, withMessageText: text, senderId: senderId, senderDisplayName: senderDisplayName, date: date)
        
        let newCount = self.chatViewController.messages.count
        
        XCTAssert(newCount == (originalCount + 1))
        //JSQMessage
        let newMessage = self.chatViewController.messages.lastObject as? JSQMessage
        
        XCTAssert(newMessage!.senderId == senderId)
        XCTAssert(newMessage!.senderDisplayName == senderDisplayName)
        XCTAssert(newMessage!.text == text)
    }
}
