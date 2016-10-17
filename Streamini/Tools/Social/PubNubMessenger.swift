//
//  PubNubMessenger.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class PubNubMessenger: NSObject, Messenger, PNDelegate {
    var pubNub: PubNub = PubNub()
    var logger = false
    
    override init() {
        super.init()
        let (publishKey, subscribeKey) = Config.shared.pubNub()
        let configuration = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey, secretKey: nil)
        
        pubNub.setConfiguration(configuration)
        logMessage("Set configuration.")
        
        pubNub.setDelegate(self)
        
        pubNub.connect()
        logMessage("Connecting to PubNub..")
    }
    
    // Subscribe to stream channel
    func connect(streamId: UInt) {
        logMessage("Subscribe to \(streamId)..")
        let channel: AnyObject! = PNChannel.channelWithName("\(streamId)")
        pubNub.subscribeOn([channel], withCompletionHandlingBlock: { (state, channels, error) -> Void in
        })
    }
    
    // Disconnect from PubNub service
    func disconnect(streamId: UInt) {
        logMessage("Disconnecting..")
        pubNub.disconnect()
    }
        
    // Send message to channel
    func send(message: Message, streamId: UInt) {
        logMessage("Send message: \(message.description) to \(streamId)..")
        let channel: PNChannel = PNChannel.channelWithName("\(streamId)") as! PNChannel
        pubNub.sendMessage(Message.serialize(message), toChannel: channel) { (state, data) -> Void in
        }
    }
    
    // Set function that handles messages
    func receive(handler: (message: Message) -> ()) {
        pubNub.observationCenter.removeMessageReceiveObserver(self)
        pubNub.observationCenter.addMessageReceiveObserver(self, withBlock: { (message) -> Void in
            self.logMessage("Received message: \(message.description)")
            let dictionary: NSDictionary = message.message as! NSDictionary
            let chatMessage = Message.deserialize(dictionary)
            handler(message: chatMessage)
        })
    }
    
    func logMessage(message: String) {
        if logger {
            print("PubNubMessenger: \(message)")
        }
    }
    
    // MARK: - PNDelegate
    
    func shouldRunClientInBackground() -> Bool {
        return true
    }
}

