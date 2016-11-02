//
//  passwordViewControler.swift
//  laudry app
//
//  Created by Michalina Simik on 3/3/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

class passwordViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    let defaultUser = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPasswordField.placeholder = "new password"
        newPasswordField.secureTextEntry = true
        confirmPasswordField.placeholder = "confirm new password"
        confirmPasswordField.secureTextEntry = true
        saveButton.setTitle("change password", forState: .Normal)
        errorLabel.hidden = true
        
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
    
    

}
