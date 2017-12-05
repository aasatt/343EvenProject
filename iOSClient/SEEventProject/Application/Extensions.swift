//
//  Extensions.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 10/24/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation
import UIKit
import Networking

extension UIViewController {
    /// Sets up gesture recongizers on the view to provide natural dismissal of the keyboard for the user.
    func respondToKeyboard() {
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGest)
        let swipeDownGest = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        swipeDownGest.direction = .down
        view.addGestureRecognizer(swipeDownGest)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /// Respond to `UIKeyboardWillShowNotification`
    @objc func keyboardWillShow (notification: Notification) {    }
    
    /// Respond to `UIKeyboardWillHideNotification`
    @objc func keyboardWillHide (notification: Notification) {    }
    
    /// A method to force the dismissal of the keyboard for any subview in the current `ViewController`
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func presentAlert(title: String?, description: String?, dismissed: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            dismissed?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentError(error: NSError?, dismissed: (() -> Void)?) {
        presentAlert(title: "Error", description: error?.localizedDescription, dismissed: dismissed)
    }
    
}

extension UIImage {
    /// Compresses `UIImage` to `Data` no more than 0.5 mb. To be used for profile pics the user uploads.
    func compressedImageData() -> Data? {
        guard let originalData = UIImageJPEGRepresentation(self, 1.0) else {
            return nil
        }
        let targetBytes = 500000
        guard originalData.count > targetBytes else {
            return originalData
        }
        return UIImageJPEGRepresentation(self, CGFloat(targetBytes)/CGFloat(originalData.count))
    }
   
}

extension UIImageView {
    
    /// MARK: UIImageView
    
    func set(imageUrl: String?) {
        set(imageUrl: imageUrl, tint: nil, completion: nil)
    }
    
    func set(imageUrl: String?, tint: UIColor?) {
        set(imageUrl: imageUrl, tint: tint, completion: nil)
    }
    
    func set(imageUrl: String?, completion: ((_ image: UIImage?)-> Void)?) {
        set(imageUrl: imageUrl, tint: nil, completion: completion)
    }
    
    func set(imageUrl: String?, tint: UIColor?, completion: ((_ image: UIImage?)-> Void)?) {
        guard let url = imageUrl else {
            return
        }
        let networking = Networking(baseURL: "")
        networking.downloadImage(url) { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    guard url == response.fullResponse.url?.absoluteString else {return}
                    self.image = response.image
                    completion?(response.image)
                    if let color = tint {
                        self.image = self.image?.withRenderingMode(.alwaysTemplate)
                        self.tintColor = color
                    }
                }
                break
            case .failure(let response):
                log.error("Failed to download image with error: \(response.error)")
                completion?(nil)
                break
            }
        }
    }
    
}

extension Dictionary {
    
    /// MARK: Dictionary
    
    func prettyPrint() {
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            print(String(data: jsonParams, encoding: .utf8) ?? "Not JSON")
        } catch {
            print("Failed to make JSON")
        }
    }
    
}

extension UIWindow {
    
    func setRootViewController(newRootViewController: UIViewController) {
        let previousViewController = rootViewController
        DispatchQueue.main.async {
            guard let snapshot:UIView = (self.snapshotView(afterScreenUpdates: true)) else {
                UIApplication.shared.keyWindow?.rootViewController = newRootViewController
                return
            }
            newRootViewController.view.addSubview(snapshot);
            UIApplication.shared.keyWindow?.rootViewController = newRootViewController
            UIView.animate(withDuration: 0.3, animations: {() in
                snapshot.layer.opacity = 0;
                snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
            }, completion: {
                (done: Bool) in
                if done {
                    snapshot.removeFromSuperview();
                }
            });
            guard previousViewController != nil else {
                return
            }
            previousViewController?.dismiss(animated: false, completion: {
            })
            
        }
    }
}

// MARK: Notification + UIKeyboardInfo

extension Notification {
    
    /// Gets the optional CGRect value of the UIKeyboardFrameEndUserInfoKey from a UIKeyboard notification
    func keyboardEndFrame() -> CGRect? {
        return (self.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
    
    /// Gets the optional AnimationDuration value of the UIKeyboardAnimationDurationUserInfoKey from a UIKeyboard notification
    func keyboardAnimationDuration() -> Double? {
        return (self.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }
}

