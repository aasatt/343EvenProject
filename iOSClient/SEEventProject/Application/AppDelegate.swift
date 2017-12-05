//
//  AppDelegate.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 10/17/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import UIKit
import Firebase
import SwiftyBeaver
import GooglePlaces
import GoogleMaps

let log = SwiftyBeaver.self
let PlacesAPIKey = "AIzaSyDP11BzI8xkmUmjOQkluqEZmWkl-9iWRxg"
let GMSServicesAPIKey = "AIzaSyDP11BzI8xkmUmjOQkluqEZmWkl-9iWRxg"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        //Database.database().isPersistenceEnabled = true
        GMSPlacesClient.provideAPIKey(PlacesAPIKey)
        GMSServices.provideAPIKey(GMSServicesAPIKey)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    // MARK: Logging
    func setupLogging() {
        let console = ConsoleDestination()
        console.levelString.verbose = "💜 VERBOSE"
        console.levelString.debug = "💚 DEBUG"
        console.levelString.info = "💙 INFO"
        console.levelString.warning = "💛 WARNING"
        console.levelString.error = "❤️ ERROR"
        console.format = "[Events] $DHH:mm:ss$d $L $M"
        log.addDestination(console)
    }
}


