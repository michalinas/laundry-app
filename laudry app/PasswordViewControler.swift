//
//  passwordViewControler.swift
//  laudry app
//
//  Created by Michalina Simik on 3/3/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

class PasswordViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var errorLabel: ErrorLabel!
    @IBOutlet weak var savePasswordButtonBottomConstraint: NSLayoutConstraint!
    let defaultUser = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        view.layoutIfNeeded()
        super.viewDidLoad()
        newPasswordField.placeholder = "new password"
        newPasswordField.secureTextEntry = true
        confirmPasswordField.placeholder = "confirm new password"
        confirmPasswordField.secureTextEntry = true
        saveButton.setTitle("change password", forState: .Normal)
        errorLabel.hidden = true
        savePasswordButtonBottomConstraint.constant = Profile.userProfiles.screenHeight / 3
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PasswordViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PasswordViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }
    
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if (newPasswordField.text!.isEmpty) || (confirmPasswordField.text!.isEmpty) {
            errorLabel.text = "please enter and confirm your password"
            errorLabel.hidden = false
        } else if newPasswordField.text! != confirmPasswordField.text! {
            errorLabel.text = "passwords don't match"
            errorLabel.hidden = false
        } else if newPasswordField.text?.characters.count < 6 {
            errorLabel.text = "password has to be min. 6 characters"
            errorLabel.hidden = false
        } else {
            errorLabel.hidden = true
            let updatedUser = Profile.userProfiles.getDefaultUser()
            updatedUser.password = newPasswordField.text!
            
            Profile.userProfiles.updateUser(updatedUser) {(error) -> Void in
                if error == nil {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    LaundryAlert.presentErrorAlert("Unable to change password", error: error!, toController: self)
                }
            }
        }
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        updateBottomViewWithKeyboard(keyboardFrame.height)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        let height = Profile.userProfiles.screenHeight / 3
        updateBottomViewWithKeyboard(height)
    }
    
    func updateBottomViewWithKeyboard(height: CGFloat) {
        let height = height + 20
        savePasswordButtonBottomConstraint.constant = height
    }
    
}
