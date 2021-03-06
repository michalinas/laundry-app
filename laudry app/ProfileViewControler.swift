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
    private let screenHeight = Profile.userProfiles.screenHeight
    private var registerInProgress = false
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var loginErrorLabel: ErrorLabel!
    @IBOutlet weak var loginViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loggedView: UIView!
    @IBOutlet weak var loggedHelloLabel: UILabel!
    @IBOutlet weak var loggedPasswordButton: UIButton!
    @IBOutlet weak var changeAdressButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var delateProfileButton: UIButton!
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var newUsernameField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var sendToRegisterButton: UIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var registerErrorLabel: ErrorLabel!
    @IBOutlet weak var registerViewBottomConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginErrorLabel.hidden = true
        if defaultUser.objectForKey("currentUser") != nil {
            showLoggedView()
        } else if registerInProgress {
            showRegisterView()
        } else {
            showLoginView()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if defaultUser.objectForKey("currentUser") == nil {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
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
    
    func showLoggedView() {
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
        UIView.animateWithDuration(0.3) {() -> Void in
            self.loginView.alpha = 0.0
            self.registerView.alpha = 0.0
            self.loggedView.alpha = 1.0
        }
    }
    
    func showLoginView() {
        loginErrorLabel.hidden = true
        nameField.placeholder = "enter user name"
        nameField.delegate = self
        passwordField.placeholder = "enter your password"
        passwordField.delegate = self
        passwordField.secureTextEntry = true
        
        UIView.animateWithDuration(0.3) {() -> Void in
            self.registerView.alpha = 0.0
            self.loggedView.alpha = 0.0
            self.loginView.alpha = 1.0
        }
    }
    
    func showRegisterView() {
        registerInProgress = true
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
        registerErrorLabel.hidden = true
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.registerView.alpha = 1.0
            self.loginView.alpha = 0.0
            self.loggedView.alpha = 0.0
        }
    }

    /* check if both username and password are given;
    if yes, verify if they match and set currentuser with given username.
    switch the view to logged view and go to home page.
    */
    @IBAction func logInButtonTapped(sender: UIButton) {
        view.endEditing(true)
        if nameField.text!.isEmpty || passwordField.text!.isEmpty {
            loginErrorLabel.text = "Please fill all fields"
            loginErrorLabel.hidden = false
        } else {
            loginErrorLabel.hidden = true
            Profile.userProfiles.trytoLogIn(nameField.text!, password: passwordField.text!, completion: {(error) in
                if error == nil {
                    self.showLoginView()
                    self.tabBarController?.selectedIndex = 0
                } else {
                    self.loginErrorLabel.text = "Username or password are incorrect. Please try again"
                    self.loginErrorLabel.hidden = false
                }
            })
        }
    }
    
    /* switch the view to register page when button tapped;
    set up all fields, numeric keyboard for phone
    */
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func registerButtonTapped(sender: AnyObject) {
        view.endEditing(true)
        showRegisterView()
        Profile.userProfiles.startNewUser()
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
    @IBAction func backToLoginTapped(sender: AnyObject) {
        view.endEditing(true)
        showLoginView()
    }

    /* verify if all field are filled.
    Then check if username is available. If not throws an error label, if yes continue the checks.
    create a new user, set as a current user (=log in) and switch to the home page.
    change alpha of login view to 0 and logged view to 1, so next time the user see his profile info.
    */
    @IBAction func sendToRegisterButtonTapped(sender: AnyObject) {
        view.endEditing(true)
        registerErrorLabel.hidden = true
        if (newUsernameField.text!.isEmpty || newPasswordField.text!.isEmpty || confirmPasswordField.text!.isEmpty) {
            registerErrorLabel.text = "Please fill all fields"
            registerErrorLabel.hidden = false
        } else {
            registerErrorLabel.hidden = true
            
            Profile.userProfiles.checkUsername(newUsernameField.text!) {(user, error) -> Void in
                if user != nil {
                    self.registerErrorLabel.text = "This username is not available."
                    self.registerErrorLabel.hidden = false
                } else if self.newPasswordField.text!.characters.count < 6 {
                    self.registerErrorLabel.text = "Password length: min. 6 characters"
                    self.registerErrorLabel.hidden = false
                } else if self.newPasswordField.text == self.confirmPasswordField.text {
                    let newUser = Profile.userProfiles.startNewUser()
                    newUser.password = self.newPasswordField.text!
                    newUser.username = self.newUsernameField.text!
                    
                    if newUser.locationId != "" {
                        Profile.userProfiles.registerNewUser(newUser) {(error) in
                            if error == nil {
                                self.showLoginView()
                                self.tabBarController?.selectedIndex = 0
                            } else {
                                LaundryAlert.presentErrorAlert("Unable to register", error: error!, toController: self)
                            }
                        }
                    } else {
                        self.registerErrorLabel.text = "Please select a location."
                        self.registerErrorLabel.hidden = false
                    }
                } else {
                        self.registerErrorLabel.text = "Your passwords must match."
                        self.registerErrorLabel.hidden = false
                }
            }
        }
    }
    
    // MARK: - loggedView
    @IBAction func logOutButtonTapped(sender: AnyObject) {
        defaultUser.setObject(nil, forKey: "currentUser")
        showLoginView()
    }
    
    @IBAction func delateProfileButtonTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "delete", message: "You will delete your profile permamently and loose all your data.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
            
            let userToDelete = Profile.userProfiles.getDefaultUser()

            ReportManager.sharedInstance.getReservationsForUser(userToDelete.username) { (userReservations, error) -> Void in
                if userReservations != nil {
                    for eachReservation in userReservations! {
                        DynamoDB.delete(eachReservation) { (error) -> Void in
                            if error != nil {
                                LaundryAlert.presentErrorAlert(error: error!, toController: self)
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
                                LaundryAlert.presentErrorAlert(error: error!, toController: self)
                            }
                        }
                    }
                }
            }
            LocationManager.sharedLocations.getMachinesForLocation(userToDelete.locationId) { (machines, error) -> Void in
                if machines != nil {
                    for eachMachine in machines! {
                        if eachMachine.usernameUsing == userToDelete.username {
                            eachMachine.usernameUsing = Profile.userProfiles.emptyUsernameConstant
                            eachMachine.state = .Empty
                            eachMachine.workEndDate = NSDate()
                            LocationManager.sharedLocations.updateMachine(eachMachine) { (error) -> Void in
                                if error != nil {
                                    LaundryAlert.presentErrorAlert(error: error!, toController: self)
                                }
                            }
                        }
                    }
                }
            }
            DynamoDB.delete(userToDelete) { (error) -> Void in
                if error != nil {
                    LaundryAlert.presentErrorAlert(error: error!, toController: self)
                } else {
                    self.defaultUser.setObject(nil, forKey: "currentUser")
                    self.showRegisterView()
                }
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        updateViewForKeyboard(keyboardFrame.height)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateViewForKeyboard(0)
    }
    
    func updateViewForKeyboard(height: CGFloat) {
        UIView.animateWithDuration(0.35) { () -> Void in
            if self.loginView.alpha == 1.0 {
                self.loginViewBottomConstraint.constant = height
            }
            if self.registerView.alpha == 1.0 {
                if self.screenHeight <= 480 && height > 0 {
                    self.registerViewBottomConstraint.constant = height - 84
                } else {
                    self.registerViewBottomConstraint.constant = height
                }
            }
        }
    }
    

}
