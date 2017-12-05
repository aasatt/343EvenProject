//
//  User.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/10/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation

/// Push notification token for a user's device
struct DeviceToken: Codable {
    
    /// Unique identifier of the device
    var id: UUID
    // Push notification token
    var token: String
}

/// A user object. A end user of the application
struct User: Codable {
    
    /// Id of user
    var id: String
    /// Name of user to show in app
    var displayName: String
    /// User image URL
    var imageUrl: String
    /// Location of the user
    var location: Location?
    /// List of devices registed under the user
    var devices: [DeviceToken]?
    /// Phone number user used to register
    var phoneNumber: String
    
}
