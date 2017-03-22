//  ViewController.swift
//  LoginHelper
//
//  Created by Anthony on 3/21/17.
//  Copyright © 2017 Anthony. All rights reserved.

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    override func viewDidLoad() {super.viewDidLoad()}
    
    func checkFingerAuth() {
        let context = LAContext()
        var error:NSError?
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access requires authentication", reply: { (success, error) in
                if error != nil {
                    switch error!._code {
                    case LAError.Code.systemCancel.rawValue:
                        self.notifyUser("Session canceled", err: (error?.localizedDescription)!)
                    case LAError.touchIDLockout.rawValue:
                        self.notifyUser("TouchID Locked Out", err: "Too many failed attempts.")
                    case LAError.Code.userCancel.rawValue:
                        self.notifyUser("Please try again", err: (error?.localizedDescription)!)
                    case LAError.Code.userFallback.rawValue:
                        OperationQueue.main.addOperation({ () -> Void in
                            self.showPasswordAlert()
                        })
                    default:
                        self.notifyUser("Authentication failed", err: (error?.localizedDescription)!)
                    }
                } else {
                    self.notifyUser("Authentication successful", err: "You now have full access")
                }
            })
        } else {
            //device cannot use touchID
            switch error!.code {
            case LAError.Code.touchIDNotEnrolled.rawValue:
                notifyUser("TouchID is not enrolled", err: (error?.localizedDescription)!)
            case LAError.Code.passcodeNotSet.rawValue:
                notifyUser("A passcode has not been set", err: (error?.localizedDescription)!)
            default:
                notifyUser("TouchID not available", err: (error?.localizedDescription)!)
            }
        }
    }
    
    func showPasswordAlert() {
        // New way to present an alert view using UIAlertController
        let alertController : UIAlertController = UIAlertController(title:"TouchID Demo" , message: "Please enter password", preferredStyle: .alert)
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print(action)
        }
        let doneAction : UIAlertAction = UIAlertAction(title: "Done", style: .default) { (action) -> Void in
            let passwordTextField = alertController.textFields![0] as UITextField
            self.login(password: passwordTextField.text!)
        }
        doneAction.isEnabled = false
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) -> Void in
                doneAction.isEnabled = textField.text != ""
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        self.present(alertController, animated: true) {
            // Nothing to do here
        }
    }
    
    func login(password: String) {
        if password == "test123" {
            notifyUser("Yea!!", err: "You logged in with a password")
        } else {
            self.showPasswordAlert()
        }
    }
    
    func notifyUser(_ msg:String, err:String) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func touchIDButtonPressed(_ sender: UIButton) {
        checkFingerAuth()
    }
}
