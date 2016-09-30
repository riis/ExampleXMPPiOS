import UIKit
import XMPPFramework

protocol ContactPickerDelegate{
	func didSelectContact(_ recipient: XMPPUserCoreDataStorageObject)
}

class ContactListTableViewController: UITableViewController, OneRosterDelegate {
	
	var delegate:ContactPickerDelegate?
	
	// Mark : Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		ChatRoster.sharedInstance.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ChatConnector.sharedInstance.isConnected() {
			navigationItem.title = kSelectRecipient
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		ChatRoster.sharedInstance.delegate = nil
	}
	
	func oneRosterContentChanged(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.reloadData()
	}
	
	// Mark: UITableView Datasources
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sections: NSArray? =  ChatRoster.buddyList.sections as NSArray?
		
		if section < sections!.count {
			let sectionInfo: AnyObject = sections![section] as AnyObject
			
			return sectionInfo.numberOfObjects
		}
		
		return 0;
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return ChatRoster.buddyList.sections!.count
	}
	
	// Mark: UITableView Delegates
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
		
		delegate?.didSelectContact(ChatRoster.userFromRosterAtIndexPath(indexPath: indexPath))
		close(self)
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
		if segue?.identifier != kOpenSettingsSegue {
			if let controller: ChatViewController = segue?.destination as? ChatViewController {
				if let cell = sender as? UITableViewCell {
					let user = ChatRoster.userFromRosterAtIndexPath(indexPath: tableView.indexPath(for: cell)!)
					controller.recipient = user
				}
			}
		}
	}
	
	// Mark: IBAction
	
	@IBAction func close(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
