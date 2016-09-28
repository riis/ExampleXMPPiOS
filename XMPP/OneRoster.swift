//
//  OneRoster.swift
//  OneChat
//
//  Created by Paul on 26/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public protocol OneRosterDelegate {
    func oneRosterContentChanged(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
}

open class OneRoster: NSObject, NSFetchedResultsControllerDelegate {
    open var delegate: OneRosterDelegate?
    open var fetchedResultsControllerVar: NSFetchedResultsController<NSFetchRequestResult>?
    
    // MARK: Singleton
    
    open class var sharedInstance : OneRoster {
        struct OneRosterSingleton {
            static let instance = OneRoster()
        }
        return OneRosterSingleton.instance
    }
    
    open class var buddyList: NSFetchedResultsController<NSFetchRequestResult> {
        get {
            if sharedInstance.fetchedResultsControllerVar != nil {
                return sharedInstance.fetchedResultsControllerVar!
            }
            return sharedInstance.fetchedResultsController()!
        }
    }
    
    // MARK: Core Data
    
    func managedObjectContext_roster() -> NSManagedObjectContext {
        return OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    fileprivate func managedObjectContext_capabilities() -> NSManagedObjectContext {
        return OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
    }
    
    open func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        if fetchedResultsControllerVar == nil {
            let moc = OneRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
            let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
            let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
            let sd2 = NSSortDescriptor(key: "displayName", ascending: true)
            
            let sortDescriptors = [sd1, sd2]
            
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "XMPPUserCoreDataStorageObject")

            //let fetchRequest = NSFetchRequest()
            
            fetchRequest.entity = entity
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.fetchBatchSize = 10
            
            fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
            fetchedResultsControllerVar?.delegate = self
            
            do {
                try fetchedResultsControllerVar!.performFetch()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
            //  if fetchedResultsControllerVar?.performFetch() == nil {
            //Handle fetch error
            //}
        }
        
        return fetchedResultsControllerVar!
    }
    
    open class func userFromRosterAtIndexPath(indexPath: IndexPath) -> XMPPUserCoreDataStorageObject {
        return sharedInstance.fetchedResultsController()!.object(at: indexPath) as! XMPPUserCoreDataStorageObject
    }
    
    open class func userFromRosterForJID(jid: String) -> XMPPUserCoreDataStorageObject? {
        let userJID = XMPPJID(string:jid)
        
        if let user = OneChat.sharedInstance.xmppRosterStorage.user(for: userJID, xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: sharedInstance.managedObjectContext_roster()) {
            return user
        } else {
            return nil
        }
    }
    
    open class func removeUserFromRosterAtIndexPath(indexPath: IndexPath) {
        let user = userFromRosterAtIndexPath(indexPath: indexPath)
        sharedInstance.fetchedResultsControllerVar?.managedObjectContext.delete(user)
    }
    
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.oneRosterContentChanged(controller)
    }
}

extension OneRoster: XMPPRosterDelegate {
    
    public func xmppRoster(_ sender: XMPPRoster, didReceiveBuddyRequest presence:XMPPPresence) {
        //was let user
        _ = OneChat.sharedInstance.xmppRosterStorage.user(for: presence.from(), xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: managedObjectContext_roster())
    }
    
    public func xmppRosterDidEndPopulating(_ sender: XMPPRoster?) {
        let jidList = OneChat.sharedInstance.xmppRosterStorage.jids(for: OneChat.sharedInstance.xmppStream)
        print("List=\(jidList)")
        
    }
}

extension OneRoster: XMPPStreamDelegate {
    
    public func xmppStream(_ sender: XMPPStream, didReceive ip: XMPPIQ) -> Bool {
        if let msg = ip.attribute(forName: "from") {
            if msg.stringValue == "conference.process-one.net"  {
                
            }
        }
        return false
    }
}
