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
    
    
    var username: String = ""
    var password: String = ""
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var loginErrorLabel: ErrorLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.placeholder = "enter user name"
        nameField.delegate = self
        passwordField.placeholder = "enter your password"
        passwordField.delegate = self
        passwordField.secureTextEntry = true
        Profile.userProfiles.loadUsers()
        LocationManager.sharedLocations.loadLocations()
        loginErrorLabel.alpha = 0.0
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
            self.loggedViewOpen()
            self.loggedView.alpha = 1.0
            self.tabBarController?.selectedIndex = 0
                } else {
            self.loginErrorLabel.text = "Username or password are incorrect. Please try again"
            self.loginErrorLabel.alpha = 1.0

                    let alertController = UIAlertController()
            alertController.title = "Unable to login"
            alertController.message = error!.localizedDescription
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            } })
            
            
            
            
            
            
            
//            {
//                self.loginView.alpha = 0.0
//                loggedViewOpen()
//                self.loggedView.alpha = 1.0
//                self.tabBarController?.selectedIndex = 0
//            } else {
//                loginErrorLabel.text = "Username or password are incorrect. Please try again"
//                loginErrorLabel.alpha = 1.0
//            }
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
        locationButton.setTitle("click to chose your location", forState: .Normal)
        sendToRegisterButton.setTitle("click to register", forState: .Normal)
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


//    func profileError(alertMessage: String, alertTitle: String = "error") {
//        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//        self.presentViewController(alert, animated: true, completion: nil)
//    }
    
    func deleteAlert() {
        let alert = UIAlertController(title: "delete", message: "You will delete your profile permamently and loose all your data.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
            Profile.userProfiles.profiles.removeValueForKey(Profile.userProfiles.currentUser!.username)
            Profile.userProfiles.currentUser = nil
            self.loggedView.alpha = 0.0
            self.registerView.alpha = 1.0
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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

    
    /* verify if all field are filled, then check if username is available if so create a new user,
     set as a current user (=log in) and switch to the home page.
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
            if !Profile.userProfiles.checkUsername(newUsernameField.text!) {
                if (newPasswordField.text == confirmPasswordField.text) && (newPasswordField.text!.characters.count >= 6) {
                    let newUser = Profile.userProfiles.registeringUser
                    newUser!.password = newPasswordField.text!
                    newUser!.username = newUsernameField.text!
                    ReportManager.sharedInstance.addUserToReports((newUser?.username)!)
                    
                    if newUser!.locationId!.integerValue != 0 {
                        Profile.userProfiles.registerNewUser(newUser!, completion: {(error) in
                            if error == nil {
                                self.registerView.alpha = 0.0
                                self.loggedViewOpen()
                                self.loggedView.alpha = 1.0
                                self.tabBarController?.selectedIndex = 0
                            } else {
                                let alertController = UIAlertController()
                                alertController.title = "Unable to register"
                                alertController.message = error!.localizedDescription
                                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        
                        })
                        
                    } else {
                        locationErrorLabel.text = "Please select a location."
                        locationErrorLabel.alpha = 1.0
                    }
                } else {
                    passwordErrorLabel.text = "Your passwords must match and be at least 6 charachters long."
                    passwordErrorLabel.alpha = 1.0
                }
            } else {
                newUsernameErrorLabel.text = "This username is not available."
                newUsernameErrorLabel.alpha = 1.0
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
        let userData = Profile.userProfiles.currentUser!
        loggedHelloLabel.text = "Hello, \(userData.username)"
        loggedPasswordButton.setTitle("change password", forState: .Normal)
        currentLocationLabel.text = "Your current laundry address: \((LocationManager.sharedLocations.locations[(userData.locationId!.integerValue)]?.street)!) in \(LocationManager.sharedLocations.locations[(userData.locationId!.integerValue)]?.city)"
        changeAdressButton.setTitle("change laundry location", forState: .Normal)
        logOutButton.setTitle("log out", forState: .Normal)
        delateProfileButton.setTitle("delete profile", forState: .Normal)
        ReportManager.sharedInstance.deleteOldReservationReports()

    }
    
    
    @IBAction func logOutButtonTapped(sender: AnyObject) {
        Profile.userProfiles.currentUser = nil
        loggedView.alpha = 0.0
        loginView.alpha = 1.0
    }
    
    @IBAction func delateProfileButtonTapped(sender: AnyObject) {
        deleteAlert()
    }
    
    
}