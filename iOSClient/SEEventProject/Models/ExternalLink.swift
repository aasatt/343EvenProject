//
//  ExternalLink.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/10/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation

/// Link to the source article or website/newsfeed
struct ExternalLink: Codable {
    
    /// URL of resource
    var url: String
    /// Name of resource
    var title: String
    
    init(url: String, title: String) {
        self.url = url
        self.title = title
    }
    
}
