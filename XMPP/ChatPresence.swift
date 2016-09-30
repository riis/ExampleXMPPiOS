//
//  OnePresence.swift
//  OneChat
//
//  Created by Paul on 27/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

// MARK: Protocol
public protocol OnePresenceDelegate {
	func onePresenceDidReceivePresence()
}

public class ChatPresence: NSObject {
	var delegate: OnePresenceDelegate?
	
	// MARK: Singleton
	
	class var sharedInstance : ChatPresence {
		struct OnePresenceSingleton {
			static let instance = ChatPresence()
		}
		return OnePresenceSingleton.instance
	}
	
	// MARK: Functions
	
	class func goOnline() {
		let presence = XMPPPresence()
		let domain = ChatConnector.sharedInstance.xmppStream!.myJID.domain
		
		if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
			let priority: DDXMLElement = DDXMLElement(name: "priority", stringValue: "24")
			presence?.addChild(priority)
		}
		
		ChatConnector.sharedInstance.xmppStream?.send(presence)
	}
	
	class func goOffline() {
		var _ = XMPPPresence(type: "unavailable")
	}
}

extension ChatPresence: XMPPStreamDelegate {
	
	@nonobjc public func xmppStream(sender: XMPPStream, didReceivePresence presence: XMPPPresence) {
		print("did received presence : \(presence)")
	}
}
