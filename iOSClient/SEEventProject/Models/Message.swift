//
//  Message.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/10/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation
import MessageKit

/// Message sent to the event from a user
struct Message: Codable, MessageType {
    
    /// Unique identiferier of the message
    var id: UUID
    /// User who sent the message
    var messageSender: User
    /// Message text
    var body: String
    /// The date the message was sent
    var sentOn: Date
    
    // MARK: Message Kit
    
    /// The sender of the message
    var sender: Sender {
        return Sender(id: messageSender.id, displayName: messageSender.displayName)
    }
    
    /// The id of the message
    var messageId: String {
        return id.uuidString
    }
    
    /// Date the message was send
    var sentDate: Date {
        return sentOn
    }
    
    /// The body of the message
    var data: MessageData {
        return MessageData.text(body)
    }
    
}

