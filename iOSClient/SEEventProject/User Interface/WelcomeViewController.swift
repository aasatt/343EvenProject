//
//  ViewController.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 10/17/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import UIKit

/// First view controller user's see upon entering the app. Can continue to login from here
class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if Session.sharedSession.restoreSession() {
            (UIApplication.shared.delegate as? AppDelegate)?.window?.setRootViewController(newRootViewController: MainNavigationController())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actionSignup() {
        
    }
    
}

