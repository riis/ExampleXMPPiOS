//
//  OneChats.swift
//  OneChat
//
//  Created by Paul on 04/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public class OneChats: NSObject, NSFetchedResultsControllerDelegate {
    
    var chatList = NSMutableArray()
    var chatListBare = NSMutableArray()
    
    // MARK: Class function
    class var sharedInstance : OneChats {
        struct OneChatsSingleton {
            static let instance = OneChats()
        }
        return OneChatsSingleton.instance
    }
    
    public class func getChatsList() -> NSArray {
        if 0 == sharedInstance.chatList.count {
            if let chatList: NSMutableArray = sharedInstance.getActiveUsersFromCoreDataStorage() as? NSMutableArray {//NSUserDefaults.standardUserDefaults().objectForKey("openChatList")
                chatList.enumerateObjects({ (jidStr, index, finished) -> Void in
                    OneChats.sharedInstance.getUserFromXMPPCoreDataObject(jidStr: jidStr as! String)
                    
                    if let user = OneRoster.userFromRosterForJID(jid: jidStr as! String) {
                        OneChats.sharedInstance.chatList.add(user)
                    }
                })
            }
        }
        return sharedInstance.chatList
    }
    
    private func getActiveUsersFromCoreDataStorage() -> NSArray? {
        let moc = OneMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "XMPPMessageArchiving_Message_CoreDataObject")

        //let request = NSFetchRequest()
        let predicateFormat = "streamBareJidStr like %@ "
        
        if let predicateString = UserDefaults.standard.string(forKey: "kXMPPmyJID") {
            let predicate = NSPredicate(format: predicateFormat, predicateString)
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                let results = try moc?.fetch(request)
                var _: XMPPMessageArchiving_Message_CoreDataObject
                let archivedMessage = NSMutableArray()
                
                for message in results! {
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                    } catch _ {
                        element = nil
                    }
                    let sender: String
                    
                    if element.attributeStringValue(forName: "to") != UserDefaults.standard.string(forKey: "kXMPPmyJID")! && !(element.attributeStringValue(forName: "to") as NSString).contains(UserDefaults.standard.string(forKey: "kXMPPmyJID")!) {
                        sender = element.attributeStringValue(forName: "to")
                        if !archivedMessage.contains(sender) {
                            archivedMessage.add(sender)
                        }
                    }
                }
                return archivedMessage
            } catch _ {
            }
        }
        return nil
    }
    
    private func getUserFromXMPPCoreDataObject(jidStr: String) {
        let moc = OneRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
        let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "XMPPUserCoreDataStorageObject")

       // let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entity
        
        var predicate: NSPredicate
        
        if OneChat.sharedInstance.xmppStream == nil {
            predicate = NSPredicate(format: "jidStr == %@", jidStr)
        } else {
            predicate = NSPredicate(format: "jidStr == %@ AND streamBareJidStr == %@", jidStr, UserDefaults.standard.string(forKey: "kXMPPmyJID")!)
        }
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        //		if let results = moc?.executeFetchRequest(fetchRequest, error: nil) {
        //			println("get user from xmpp - results")
        //			var user: XMPPUserCoreDataStorageObject
        //			var archivedUser = NSMutableArray()
        //
        //			for user in results {
        //				println(user)
        //				// var element = DDXMLElement(XMLString: user.messageStr, error: nil)
        //				//        let sender: String
        //				//
        //				//        if element.attributeStringValueForName("to") != NSUserDefaults.standardUserDefaults().stringForKey("kXMPPmyJID")! && !(element.attributeStringValueForName("to") as NSString).containsString(NSUserDefaults.standardUserDefaults().stringForKey("kXMPPmyJID")!) {
        //				//          sender = element.attributeStringValueForName("to")
        //				//          if !archivedMessage.containsObject(sender) {
        //				//            archivedMessage.addObject(sender)
        //				//          }
        //				//        }
        //			}
        //			//println("so response \(archivedMessage.count) from \(archivedMessage)")
        //			//return archivedMessage
        //		}
        //return nil
    }
    
    
    public class func knownUserForJid(jidStr: String) -> Bool {
        if sharedInstance.chatList.contains(OneRoster.userFromRosterForJID(jid: jidStr)!) {
            return true
        } else {
            return false
        }
    }
    
    public class func addUserToChatList(jidStr: String) {
        if !knownUserForJid(jidStr: jidStr) {
            sharedInstance.chatList.add(OneRoster.userFromRosterForJID(jid: jidStr)!)
            sharedInstance.chatListBare.add(jidStr)
        }
    }
    
    public class func removeUserAtIndexPath(indexPath: NSIndexPath) {
        let user = OneChats.getChatsList().object(at:indexPath.row) as! XMPPUserCoreDataStorageObject
        
        sharedInstance.removeMyUserActivityFromCoreDataStorageWith(user: user)
        sharedInstance.removeUserActivityFromCoreDataStorage(user: user)
        removeUserFromChatList(user: user)
    }
    
    public class func removeUserFromChatList(user: XMPPUserCoreDataStorageObject) {
        if sharedInstance.chatList.contains(user) {
            sharedInstance.chatList.remove(user)
            sharedInstance.chatListBare.remove(user.jidStr)
        }
    }
    
    func removeUserActivityFromCoreDataStorage(user: XMPPUserCoreDataStorageObject) {
        let moc = OneMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "XMPPMessageArchiving_Message_CoreDataObject")

        
        //let request = NSFetchRequest()
        let predicateFormat = "bareJidStr like %@ "
        
        let predicate = NSPredicate(format: predicateFormat, user.jidStr)
        request.predicate = predicate
        request.entity = entityDescription
        
        do {
            let results = try moc?.fetch(request)
            for message in results! {
                moc?.delete(message as! NSManagedObject)
            }
        } catch _ {
        }
    }
    
    func removeMyUserActivityFromCoreDataStorageWith(user: XMPPUserCoreDataStorageObject) {
        let moc = OneMessage.sharedInstance.xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "XMPPMessageArchiving_Message_CoreDataObject")

       // let request = NSFetchRequest()
        let predicateFormat = "streamBareJidStr like %@ "
        
        if let predicateString = UserDefaults.standard.string(forKey: "kXMPPmyJID") {
            let predicate = NSPredicate(format: predicateFormat, predicateString)
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                let results = try moc?.fetch(request)
                for message in results! {
                    var element: DDXMLElement!
                    do {
                        element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                    } catch _ {
                        element = nil
                    }
                    
                    if element.attributeStringValue(forName: "to") != UserDefaults.standard.string(forKey: "kXMPPmyJID")! && !(element.attributeStringValue(forName: "to") as NSString).contains(UserDefaults.standard.string(forKey: "kXMPPmyJID")!) {
                        if element.attributeStringValue(forName: "to") == user.jidStr {
                            moc?.delete(message as! NSManagedObject)
                        }
                    }
                }
            } catch _ {
            }
        }
    }
}
