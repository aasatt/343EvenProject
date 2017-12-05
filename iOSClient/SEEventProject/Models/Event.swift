//
//  Event.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/9/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation

/// Event data model used throught the app
struct Event: Codable {
    var id: String
    /// Name of event
    var title: String
    /// URL for the event image
    var imageUrl: String
    /// Description of the event
    var description: String
    /// Location of the event
    var location: EventLocation?
    /// Any external links to the event
    var externalLinks: [ExternalLink]?
    /// Date event was submitted for review
    var dateSubmitted: Date
    /// Date event was reviewed and approved
    var dateApproved: Date?
    
    init?(id: UUID, title: String?, imageUrl: String?, description: String?) {
        guard let t = title,
            let i = imageUrl,
            let d = description else {
                return nil
        }
        self.id = id.uuidString
        self.title = t
        self.imageUrl = i
        self.description = d
        self.dateSubmitted = Date()
    }
    
}

