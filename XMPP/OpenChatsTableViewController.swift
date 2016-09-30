import UIKit
import JSQMessagesViewController
import XMPPFramework

class OpenChatsTableViewController: UITableViewController, OneRosterDelegate {
	
	var chatList = NSArray()

	// Mark: Life Cycle
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        NotificationCenter.default.addObserver(self, selector: #selector(OpenChatsTableViewController.logout), name: NSNotification.Name(rawValue: kNeedToTimeOutString), object: nil)


        ChatRoster.sharedInstance.delegate = self
		
		tableView.rowHeight = 50
	}
	
	override func viewWillDisappear(_ animated: Bool)
    {
		super.viewWillDisappear(animated)
		
		ChatRoster.sharedInstance.delegate = nil
	}
    func logout()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.isUserLoggedIn = false
        ChatConnector.sharedInstance.disconnect()
        
        //swift 3 need to do like this
        let _ = navigationController?.popViewController(animated: true)

//        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark:Action methods
    @IBAction func onSelectLogout(_ sender: AnyObject)
    {
        
        logout()
    }
    
    @IBAction func onSelectSettings(_ sender: AnyObject)
    {
        
    }
    
	// Mark: OneRoster Delegates
	func oneRosterContentChanged(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
		//Will reload the tableView to reflet roster's changes
		tableView.reloadData()
	}
	
    
    // Mark: UITableView Datasources
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sections: NSArray? =  ChatRoster.buddyList.sections as NSArray?
        
        if section < sections!.count {
            let sectionInfo: AnyObject = sections![section] as AnyObject
            
            return sectionInfo.numberOfObjects
        }
        
        return 0;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return ChatRoster.buddyList.sections!.count
    }
    
    // Mark: UITableView Delegates
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let sections: NSArray? = ChatRoster.sharedInstance.fetchedResultsController()!.sections as NSArray?
        
        if section < sections!.count {
            let sectionInfo: AnyObject = sections![section] as AnyObject
            let tmpSection: Int = Int(sectionInfo.name)!
            
            switch (tmpSection) {
            case 0 :
                return kAvailable
                
            case 1 :
                return kAwayString
                
            default :
                return kOfflineString
                
            }
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = ChatRoster.userFromRosterAtIndexPath(indexPath: indexPath)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath)
        let user = ChatRoster.userFromRosterAtIndexPath(indexPath: indexPath)
        
        cell!.textLabel!.text = user.displayName;
        cell!.detailTextLabel?.isHidden = true
        
        if user.unreadMessages.intValue > 0 {
            cell!.backgroundColor = UIColor.orange
        } else {
            cell!.backgroundColor = UIColor.white
        }
        
        ChatConnector.sharedInstance.configurePhotoForCell(cell!, user: user)
        
        return cell!;
    }
    

	
	// Mark: Segue support
	
	override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
		if segue?.identifier == kOpenChatToChatSegue {
			if let controller = segue?.destination as? ChatViewController {
                
                if let cell: UITableViewCell = sender as? UITableViewCell {
                    let user = ChatRoster.userFromRosterAtIndexPath(indexPath: tableView.indexPath(for: cell)!)
                    controller.recipient = user
                }
			}
		}
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
