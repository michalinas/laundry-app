//
//  ProfileViewControler.swift
//  laudry app
//
//  Created by Michalina Simik on 2/19/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    let defaultUser = NSUserDefaults.standardUserDefaults()
    var username: String = ""
    var password: String = ""
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var loginErrorLabel: ErrorLabel!
    

    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        loginErrorLabel.alpha = 0.0
        if defaultUser.objectForKey("currentUser") != nil {
            loginView.alpha = 0.0
            registerView.alpha = 0.0
            loggedViewOpen()
            loggedView.alpha = 1.0
        } else {
            loginErrorLabel.alpha = 0.0
            nameField.placeholder = "enter user name"
            nameField.delegate = self
            passwordField.placeholder = "enter your password"
            passwordField.delegate = self
            passwordField.secureTextEntry = true
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }
    

    
    /* check if both username and password are given;
    if yes, verify if they match and set currentuser with given username.
    switch the view to logged view and go to home page.
    */
    @IBAction func logButtonTapped(sender: UIButton) {
        if nameField.text!.isEmpty || passwordField.text!.isEmpty {
            loginErrorLabel.text = "Please fill all fields"
            loginErrorLabel.alpha = 1.0
        } else {
            loginErrorLabel.alpha = 0.0
            Profile.userProfiles.trytoLogIn(nameField.text!, password: passwordField.text!, completion: {(error) in
                if error == nil {
                    self.loginView.alpha = 0.0
                    self.registerView.alpha = 0.0
                    self.loggedViewOpen()
                    self.loggedView.alpha = 1.0
                    self.tabBarController?.selectedIndex = 0
                } else {
                    print("error found in login \(error?.localizedDescription)")
                    self.loginErrorLabel.text = "Username or password are incorrect. Please try again"
                    self.loginErrorLabel.alpha = 1.0
                }
            })
        }
    }
    
    
    /* switch the view to register page when button tapped;
    set up all fields, numeric keyboard for phone
    */
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func registerButtonTapped(sender: AnyObject) {
        newUsernameField.placeholder = "enter username"
        newUsernameField.delegate = self
        newPasswordField.placeholder = "enter your password"
        newPasswordField.delegate = self
        newPasswordField.secureTextEntry = true
        confirmPasswordField.placeholder = "re-enter your password"
        confirmPasswordField.delegate = self
        confirmPasswordField.secureTextEntry = true
        locationButton.setTitle("choose your location", forState: .Normal)
        sendToRegisterButton.setTitle("register", forState: .Normal)
        backToLoginButton.setTitle("back to log in", forState: .Normal)
        newUsernameErrorLabel.alpha = 0.0
        passwordErrorLabel.alpha = 0.0
        locationErrorLabel.alpha = 0.0
        
        Profile.userProfiles.startNewUser()
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.registerView.alpha = 1.0
        }
    }
    
    
    /* set a max length for textFields and permit only to use numbers in phoneField
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {        
        if string.characters.count == 0 {
            return true
        }
            return textField.text!.characters.count <= 15
    }

    
    // MARK: - registerView

    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var newUsernameField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var sendToRegisterButton: UIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var newUsernameErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    
    @IBAction func backToLoginTapped(sender: AnyObject) {
        UIView.animateWithDuration(0.3) {() -> Void in
            self.registerView.alpha = 0.0
            self.loginView.alpha = 1.0
        }
    }

    
    /* verify if all field are filled.
    Then check if username is available. If not throws an error label, if yes continue the checks.
    create a new user, set as a current user (=log in) and switch to the home page.
    change alpha of login view to 0 and logged view to 1, so next time the user see his profile info.
    */
    @IBAction func sendToRegisterButtonTapped(sender: AnyObject) {
        locationErrorLabel.alpha = 0.0
        passwordErrorLabel.alpha = 0.0
        newUsernameErrorLabel.alpha = 0.0
        if (newUsernameField.text!.isEmpty || newPasswordField.text!.isEmpty || confirmPasswordField.text!.isEmpty) {
            newUsernameErrorLabel.text = "Please fill all fields"
            newUsernameErrorLabel.alpha = 1.0
        } else {
            newUsernameErrorLabel.alpha = 0.0
            passwordErrorLabel.alpha = 0.0
            locationErrorLabel.alpha = 0.0
            
            Profile.userProfiles.checkUsername(newUsernameField.text!) {(user, error) -> Void in
                if error != nil {
                    self.newUsernameErrorLabel.text = "This username is not available."
                    print(error)
                    self.newUsernameErrorLabel.alpha = 1.0
                } else if self.newPasswordField.text!.characters.count < 6 {
                    self.passwordErrorLabel.text = "Password length: min. 6 characters"
                    self.passwordErrorLabel.alpha = 1.0
                } else if self.newPasswordField.text == self.confirmPasswordField.text {
                    let newUser = Profile.userProfiles.registeringUser
                    newUser!.password = self.newPasswordField.text!
                    newUser!.username = self.newUsernameField.text!
                    
                    if newUser!.locationId != "" {
                        Profile.userProfiles.registerNewUser(newUser!) {(error) in
                            if error == nil {
                                self.loginView.alpha = 0.0
                                self.registerView.alpha = 0.0
                                self.loggedViewOpen()
                                self.loggedView.alpha = 1.0
                                self.tabBarController?.selectedIndex = 0
                            } else {
                                LaundryAlert.presentErrorAlert("Unable to register", error: error!, toController: self)
                            }
                        }
                    } else {
                        self.locationErrorLabel.text = "Please select a location."
                        self.locationErrorLabel.alpha = 1.0
                    }
                } else {
                        self.passwordErrorLabel.text = "Your passwords must match."
                        self.passwordErrorLabel.alpha = 1.0
                }
            }
        }
    }
    

    
    
    // MARK: - loggedView
    
    @IBOutlet weak var loggedView: UIView!
    @IBOutlet weak var loggedHelloLabel: UILabel!
    @IBOutlet weak var loggedPasswordButton: UIButton!
    @IBOutlet weak var changeAdressButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var delateProfileButton: UIButton!
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    
    func loggedViewOpen() {
        let userData = Profile.userProfiles.getDefaultUser()
        loggedHelloLabel.text = "Hello, \(userData.username)"
        
        LocationManager.sharedLocations.getLocationWith(userData.locationId) { (userLocation, error) -> Void in
            if userLocation != nil {
                self.currentLocationLabel.text = "Your current laundry address: \(userLocation!.street) in \(userLocation!.city)"
            } else {
                self.currentLocationLabel.text = "cannot find your location details"
            }
        }
        
        loggedPasswordButton.setTitle("change password", forState: .Normal)
        changeAdressButton.setTitle("change laundry location", forState: .Normal)
        logOutButton.setTitle("log out", forState: .Normal)
        delateProfileButton.setTitle("delete profile", forState: .Normal)
    }
    
    
    @IBAction func logOutButtonTapped(sender: AnyObject) {
        defaultUser.setObject(nil, forKey: "currentUser")
        loggedView.alpha = 0.0
        loginView.alpha = 1.0
    }
    
    
    @IBAction func delateProfileButtonTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "delete", message: "You will delete your profile permamently and loose all your data.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
            
            let userToDelete = Profile.userProfiles.getDefaultUser()
            DynamoDB.delete(userToDelete) { (error) -> Void in
                var error = error
                if error == nil {
                    ReportManager.sharedInstance.getReservationsForUser(userToDelete.username) { (userReservations, error) -> Void in
                        if userReservations != nil {
                            for eachReservation in userReservations! {
                                DynamoDB.delete(eachReservation) { (error) -> Void in
                                    if error != nil {
                                        LaundryAlert.presentCustomAlert("Error", alertMessage: "Unable to delete your account. Try again later", toController: self)
                                    }
                                }
                            }
                        }
                    }
                    ReportManager.sharedInstance.getReporsForUser(userToDelete.username) { (userReports, error) -> Void in
                        if userReports != nil {
                            for eachReport in userReports! {
                                DynamoDB.delete(eachReport) { (error) -> Void in
                                    if error != nil {
                                        LaundryAlert.presentCustomAlert("Server error", alertMessage: "Cannot delete your past activity", toController: self)
                                    }
                                }
                            }
                        }
                    }
                    LocationManager.sharedLocations.getMachinesForLocation(userToDelete.locationId) { (machines, error) -> Void in
                        if machines != nil {
                            for eachMachine in machines! {
                                if eachMachine.usernameUsing == userToDelete.username {
                                    eachMachine.usernameUsing = "?"
                                    LocationManager.sharedLocations.updateMachine(eachMachine) { (error) -> Void in
                                        if error != nil {
                                            print("cannot update machine after deleted user\(error!.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.defaultUser.setObject(nil, forKey: "currentUser")
                    self.loggedView.alpha = 0.0
                    self.registerView.alpha = 1.0
                    
                } else {
                    print("error, user cannot be deleted")
                    error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey : "cannot delete the user"])
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}
