//
//  Location.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/9/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation

/// Master location protocol to be used by location subclasses
protocol AbstractLocation {
    
    /// Longitude value of locatio coodinate
    var longitude: Double {get set}
    /// Latitude value of location coodinate
    var latitude: Double {get set}
}

/// Location object with coordinates
struct Location: Codable, AbstractLocation {
    
    /// Longitude value of location coodinate
    var longitude: Double
    /// Latitude value of location coodinate
    var latitude: Double
    
    
}

/// Location for the event object
struct EventLocation: Codable, AbstractLocation {
    
    /// Longitude value of location coodinate
    var longitude: Double
    /// Latitude value of location coodinate
    var latitude: Double
    var title: String
    var subtitle: String
    
}
