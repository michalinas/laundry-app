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
    let profileAlerts: [String:String] = ["loginError": "Username or password are incorrect. Please try again",
        "usernameUsed": "This username is not available", "password" : "Your passwords must match and be at least 6 charachters long",
        "EmptyField": "Please fill all fields", "logout": "You have sucessfully logged out. Goodbye!",
        "delete": "You will delete your profile permamently and loose all your data.", "location" : "please select a location"]
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.placeholder = "enter user name"
        nameField.delegate = self
        passwordField.placeholder = "enter your password"
        passwordField.delegate = self
        passwordField.secureTextEntry = true
        
        Profile.userProfiles.loadUsers()
        LocationManager.sharedLocations.loadLocations()
        
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
            profileError(profileAlerts["EmptyField"]!)
        } else {
            if Profile.userProfiles.trytoLogIn(nameField.text!, password: passwordField.text!) {
            print("log in")
            print(Profile.userProfiles.currentUser?.username)
            self.loginView.alpha = 0.0
            loggedViewOpen()
            self.loggedView.alpha = 1.0
            self.tabBarController?.selectedIndex = 0
            } else {
                print("failed login")
                profileError(profileAlerts["loginError"]!)
            }
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


    func profileError(alertMessage: String, alertTitle: String = "error") {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteAlert(alertMessage: String) {
        let alert = UIAlertController(title: "delete", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
            print(Profile.userProfiles.currentUser!.username)
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
        if (newUsernameField.text!.isEmpty || newPasswordField.text!.isEmpty || confirmPasswordField.text!.isEmpty) {
            profileError(profileAlerts["EmptyField"]!)
        } else {
            if !Profile.userProfiles.checkUsername(newUsernameField.text!) {
                if (newPasswordField.text == confirmPasswordField.text) && (newPasswordField.text!.characters.count >= 6) {
                    let newUser = Profile.userProfiles.registeringUser
                    if newUser == nil {
                        print("user nil")
                        
                    }
                    if Profile.userProfiles.registeringUser == nil {
                        print("registering user nil")
                    }
                    newUser!.password = newPasswordField.text!
                    newUser!.username = newUsernameField.text!
                    
                    ReportManager.sharedInstance.addUserToReports((newUser?.username)!)

                    if newUser!.chosenLocationId != 0 {
                        Profile.userProfiles.registerNewUser(newUser!)
                        self.registerView.alpha = 0.0
                        loggedViewOpen()
                        self.loggedView.alpha = 1.0
                        self.tabBarController?.selectedIndex = 0
                    } else {
                        profileError(profileAlerts["location"]!)
                        // ----------- when OK go to locaiton veiw Controller
                        // ----------- cancel just close alert
                    }
                } else {
                    profileError(profileAlerts["password"]!)
                }
            } else {
                profileError(profileAlerts["usernameUsed"]!)
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
        currentLocationLabel.text = "Your current laundry address: \((LocationManager.sharedLocations.locations[(userData.chosenLocationId)]?.street)!) in \(LocationManager.sharedLocations.cities[String(LocationManager.sharedLocations.locations[userData.chosenLocationId]?.zip)])"
        changeAdressButton.setTitle("change laundry location", forState: .Normal)
        logOutButton.setTitle("log out", forState: .Normal)
        delateProfileButton.setTitle("delete profile", forState: .Normal)
    }
    
    
    @IBAction func logOutButtonTapped(sender: AnyObject) {
        Profile.userProfiles.currentUser = nil
        profileError(profileAlerts["logout"]!, alertTitle: "confirmation")
        loggedView.alpha = 0.0
        loginView.alpha = 1.0
        
    }
    
    @IBAction func delateProfileButtonTapped(sender: AnyObject) {
        deleteAlert(profileAlerts["delete"]!)
    }
    
    
}