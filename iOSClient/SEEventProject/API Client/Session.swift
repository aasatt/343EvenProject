//
//  APIClient.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 11/10/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation
import FirebaseDatabase

/// User session used throught the application handles fetching data and updating models as well as keeping track of the current user
class Session: NSObject {
    
    /// Singleton instance of Session used throughout the application for various requests
    static var sharedSession = Session()
    
    /// The current authenticated user of the app
    var currentUser: User?
    
    /// JSON Decoder used for session
    var decoder = JSONDecoder()
    
    /// Creates a Session instance
    override init() {
        if let data = UserDefaults.standard.data(forKey: "user") {
            currentUser = try? decoder.decode(User.self, from: data)
        }
    }
    
    /// Removes user session from persistant storage
    func clearSavedSession() {
        currentUser = nil
        UserDefaults.standard.set(nil, forKey: "user")
    }
    
    /// Retreives and restores persisted user Session
    /// - returns: whether or not Session has been restored successfully
    func restoreSession() -> Bool {
        return currentUser != nil
    }
    
    /// API call to create the current user
    /// - parameter phoneNumber: the verfied phone number
    /// - parameter displayName: the name of the user
    /// - parameter completion: async completion block returning the newly authenticated user
    func createUser(uid: String, phoneNumber: String, completion: @escaping (_ error: Error?) -> Void) {
        let user = User(id: uid, displayName: "user_\(Int(arc4random())%Int(Date().timeIntervalSince1970))", imageUrl: "https://api.adorable.io/avatars/240/\(uid)", location: nil, devices: nil, phoneNumber: phoneNumber)
        guard let data = try? JSONEncoder().encode(user),
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
            print("could not make user json")
            return
        }
        Database.database().reference().child(uid).setValue(json) { (error, _) in
            if let error = error {
                completion(error)
                return
            }
            UserDefaults.standard.set(data, forKey: "user")
            completion(nil)
        }
    }
    
    /// API call to create the current user
    /// - parameter id: id of the user to fetch
    /// - parameter completion: async completion block returning the requested user
    func getUser(id: UUID, completion: (_ user: User) -> Void) {}
    
    /// API call to update the current user
    /// - parameter user: user object to update
    /// - parameter completion: async completion block returning if the update was successful or not
    func update(user: User, completion: (_ success: Bool) -> Void) {}
    
    /// API call to set or update device token of the user
    /// - parameter device: device of the user with push token
    /// - parameter user: id of user who the devices belongs to
    /// - parameter completion: async completion block returning if the update was successful or not
    func update(device: DeviceToken, for user: UUID, completion: (_ success: Bool) -> Void) {}
    
    /// Gets all active events
    /// - parameter completion: async completion block returning active events
    func getActiveEvents(completion: @escaping (_ events: [Event]?) -> Void) {
        Database.database().reference().child("events").child("active").observeSingleEvent(of: .value) { (snapshot) in
            guard let info = snapshot.value as? [String: [String: Any]] else {
                completion(nil)
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: info.map{return $0.value}, options: .prettyPrinted)
                let events = try self.decoder.decode([Event].self, from: data)
                completion(events)
            } catch {
                log.error(error.localizedDescription)
                completion(nil)
            }
        }
        
    }
    
    /// Submits new user event for review
    /// - parameter event: event to submit
    /// - parameter completion: async completion block returning if the update was successful or not
    func submitEvent(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        guard let data = try? JSONEncoder().encode(event),
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
                print("could not make user json")
                return
        }
        Database.database().reference().child("events").child("pending").child(event.id).setValue(json) { (error, _) in
            if let error = error {
                log.error(error)
                completion(false)
                return
            }
            log.info("Submitted Event!")
            completion(true)
        }
    }
    
    /// Gets all active events
    /// - parameter completion: async completion block returning archived or passed events
    func getArchivedEvents(completion: (_ events: [Event]) -> Void) {}
    
    /// Gets all messages for the event
    /// - parameter eventId: if of the event to get messages for
    /// - parameter completion: async completion block returning event messages
    func getMessages(for eventId: UUID, completion: (_ messages: [Message]) -> Void) {}
    
    /// Sends a new message to the event
    /// - parameter message: message to send to the event
    /// - parameter eventId: id of the event to send message to
    /// - parameter completion: async completion block returning message sent successfully
    func send(message: Message, for eventId: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let data = try? JSONEncoder().encode(message),
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
                print("could not make message json")
                return
        }
        Database.database().reference().child("messages").child(eventId).childByAutoId().setValue(json) { (error, _) in
            if let error = error {
                log.error(error)
                completion(false)
                return
            }
            log.info("Sent Message!")
            completion(true)
        }
    }

}
