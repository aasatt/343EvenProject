//
//  SignupViewController.swift
//  SEEventProject
//
//  Created by Aaron Satterfield on 10/24/17.
//  Copyright © 2017 Aaron Satterfield. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import PhoneNumberKit
import SVProgressHUD

/// Used for capturing the users phone number on sign up.
class SignupViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    /// Defines a set of states that the view should be in.
    enum State {
        /// Phone number has not been enter yet
        case needsPhoneNumber
        /// Phone number submitted. Waiting for verification code input
        case needsCode
    }
    
    /// The current state the view is. See `SignupViewController.State`
    private var currentState: State = .needsPhoneNumber
    
    /// Verification identifier used for when the phone number is submitted and to pass along with the code on verification
    private var _verificationId: String?
    /// Reference to `_verificationId` with `get` and `set` methods
    fileprivate var verificationId: String? {
        get {
            return _verificationId
        }
        set {
            _verificationId = newValue
            setCurrentState(state: _verificationId == nil ? .needsPhoneNumber : .needsCode)
        }
    }
    
}

extension SignupViewController {
    
    // MARK: View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentState(state: .needsPhoneNumber)
        respondToKeyboard()
    }
    
    /// Tells the view to updates it's state
    func setCurrentState(state: State) {
        self.currentState = state
        self.titleLabel.text = self.currentState == .needsPhoneNumber ? "Enter your phone number" : "Enter the code that was sent."
        self.phoneTextField.isHidden = self.currentState != .needsPhoneNumber
        self.nextButton.isHidden = self.phoneTextField.isHidden
        self.codeTextField.isHidden = self.currentState == .needsPhoneNumber
        self.doneButton.isHidden = self.codeTextField.isHidden
    }
    
}

extension SignupViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            var txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            if !txtAfterUpdate.hasPrefix("+1") {
                txtAfterUpdate = "+1"
            }
            let formatted = PartialFormatter().formatPartial(txtAfterUpdate)
            textField.text = formatted
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        actionEnterNumber()
        return true
    }
    
}

extension SignupViewController {
    
    // MARK: Phone Verfication
    
    /// Triggers on user submission of phone number
    @IBAction func actionEnterNumber() {
        guard let phoneNumber = phoneTextField.text else { return }
        SVProgressHUD.show()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
            SVProgressHUD.dismiss()
            guard let id = verificationID else {
                if let error = error {
                    // TODO: Handle error
                    log.error(error.localizedDescription)
                    return
                }
                return
            }
            self.verificationId = id
        }
    }
    
    /// Triggers on verification code submission
    @IBAction func signInWithCode() {
        guard let code = codeTextField.text else { return }
        guard let verificationId = self.verificationId else { return }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
        SVProgressHUD.show()
        Auth.auth().signIn(with: credential) { (user, error) in
            guard let user = user else {
                SVProgressHUD.dismiss()
                if let error = error {
                    // TODO: Handle error
                    log.error(error.localizedDescription)
                    return
                }
                return
            }
            guard let phoneNumner = user.phoneNumber else {
                SVProgressHUD.dismiss()
                log.warning("user did not have phone number?")
                return
            }
            Session.sharedSession.createUser(uid: user.uid, phoneNumber: phoneNumner, completion: { (error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    log.error(error)
                    return
                }
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.setRootViewController(newRootViewController: MainNavigationController())
                }
            })
        }
    }
    
}
