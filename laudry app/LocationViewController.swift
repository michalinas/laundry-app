//
//  LocationViewController.swift
//  laudry app
//
//  Created by Michalina Simik on 2/29/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

class LocationViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var zipCodeLabel: UILabel!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var streetField: UITextField!
    @IBOutlet weak var NumLaundryField: UITextField!
    @IBOutlet weak var numLaundryStepper: UIStepper!
    @IBOutlet weak var numLaundryLabel: UILabel!
    @IBOutlet weak var WashingTimeField: UITextField!
    @IBOutlet weak var washingTimeStepper: UIStepper!
    @IBOutlet weak var washingTimeLabel: UILabel!
    @IBOutlet weak var NumDryerField: UITextField!
    @IBOutlet weak var numDryerStepper: UIStepper!
    @IBOutlet weak var numDryerLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var newLocationVeiw: UIView!
    @IBOutlet weak var errorLabel: ErrorLabel!
    @IBOutlet weak var newLocationViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptButtonBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var newLocationViewTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var newLocationViewTopTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!

    private let screenSizeHeight = Profile.userProfiles.screenHeight
    
    let defaultUser = NSUserDefaults.standardUserDefaults()
    
    var locationResults: [Location] = []
    var cityName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zipField.placeholder = "zip code:"
        zipField.keyboardType = UIKeyboardType.NumberPad
        zipField.delegate = self
        streetField.placeholder = "building number, street"
        streetField.delegate = self
        streetField.keyboardType = UIKeyboardType.Default
        streetLabel.text = "address:"
        numLaundryLabel.text = "number of washing machines:"
        NumLaundryField.placeholder = "0"
        NumLaundryField.keyboardType = .NumberPad
        NumLaundryField.delegate = self
        washingTimeLabel.text = "washing machine cycle length (min)"
        WashingTimeField.placeholder = "0"
        WashingTimeField.keyboardType = .NumberPad
        WashingTimeField.delegate = self
        washingTimeStepper.maximumValue = 120.0
        numDryerLabel.text = "number of dryers"
        NumDryerField.placeholder = "0"
        NumDryerField.keyboardType = .NumberPad
        NumDryerField.delegate = self
        acceptButton.setTitle("save", forState: .Normal)
        locationTableView.delegate = self
        locationTableView.dataSource = self
        newLocationViewConstraint.constant = 0
        newLocationVeiw.hidden = true
        errorLabel.alpha = 0.0
        
        if screenSizeHeight <= 568 {
            errorLabelHeightConstraint.constant = 0
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.layoutIfNeeded()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == zipField {
            newLocationVeiw.hidden = true
            newLocationViewConstraint.constant = 0
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        resignFirstResponder()
        view.layoutIfNeeded()
        self.view.endEditing(true)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 {
            return true
        }
        let numberstring = string.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0123456789").invertedSet)
        
        switch textField {
        case zipField:
            return string == numberstring && zipField.text!.characters.count <= 4
        case NumLaundryField, NumDryerField:
            return string == numberstring && NumDryerField.text!.characters.count <= 1 && NumLaundryField.text!.characters.count <= 1
        case WashingTimeField:
            return string == numberstring && WashingTimeField.text!.characters.count <= 2
        case streetField:
            return streetField.text!.characters.count <= 63
        default:
            return true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cityName != "" {
            return locationResults.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = cityName
            cell.detailTextLabel?.text = "click to add new location"
        } else {
            let index = indexPath.row - 1
            cell.textLabel?.text = cityName + ", " + locationResults[index].street
            let washingMachines = locationResults[index].numWashers
            let dryers = locationResults[index].numDryers
            
            if washingMachines == "1" && dryers == "1"{
                cell.detailTextLabel?.text = "\(washingMachines) washing mashine, \(dryers) dryer"
            } else if washingMachines == "1" {
                cell.detailTextLabel?.text = "\(washingMachines) washing mashine, \(dryers) dryers"
            } else if dryers == "1" {
                cell.detailTextLabel?.text = "\(washingMachines) washing mashines, \(dryers) dryer"
            } else {
                cell.detailTextLabel?.text = "\(washingMachines) washing mashines, \(dryers) dryers"
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 {
            acceptButton.setTitle("confirm", forState: .Normal)
            
            if defaultUser.objectForKey("currentUser") == nil {
                Profile.userProfiles.startNewUser().locationId = locationResults[indexPath.row - 1].locationId
            } else {
                let user = Profile.userProfiles.getDefaultUser()
                user.locationId = locationResults[indexPath.row - 1].locationId
                defaultUser.setObject(NSKeyedArchiver.archivedDataWithRootObject(user), forKey: "currentUser")
            }
            newLocationVeiw.hidden = true
            newLocationViewConstraint.constant = 0
        } else {
            newLocationVeiw.hidden = false
            newLocationViewConstraint.constant = 156
            acceptButton.setTitle("save", forState: .Normal)
        }
    }
    
    @IBAction func zipEntered(sender: UITextField) {
        if sender.text!.characters.count < 5 {
            locationResults.removeAll()
            self.locationTableView.reloadData()
        } else {
            errorLabel.alpha = 0.0
            LocationManager.sharedLocations.loadCities()
            cityName = LocationManager.sharedLocations.getCityForZip(sender.text!)
            if cityName != "" {
                DynamoDB.search(Location.self, parameterName: "zip", parameterValue: zipField.text!, matchMode: .Exact) { (locations, error) -> Void in
                    if let locations = locations {
                        self.locationResults = locations
                        LocationManager.sharedLocations.lastLocationId = locations.count
                    } else {
                        print("error in get loc for zip: \(error?.localizedDescription, error?.localizedFailureReason, error?.localizedRecoverySuggestion)")
                    }
                self.locationTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func LaundryStepperChanged(sender: UIStepper) {
        self.NumLaundryField.text = String(Int(sender.value))
    }
    
    @IBAction func washingTimeStepperChanged(sender: UIStepper) {
        self.WashingTimeField.text = String(Int(sender.value))
    }
    
    @IBAction func DryerStepperChanged(sender: UIStepper) {
        self.NumDryerField.text = String(Int(sender.value))
    }
    
    @IBAction func acceptButtonTapped(sender: AnyObject) {
        errorLabel.alpha = 0.0
        if zipField.text!.characters.count != 5 {
            errorLabel.text = "Please enter 5-digit zip code."
            errorLabel.alpha = 1.0
        } else if acceptButton.titleLabel?.text == "save" && (zipField.text!.isEmpty || streetField.text!.isEmpty || NumLaundryField.text!.isEmpty || WashingTimeField.text!.isEmpty || NumDryerField.text!.isEmpty) {
            if screenSizeHeight <= 568 {
                LaundryAlert.presentCustomAlert("Error", alertMessage: "All fields are mandatory", toController: self)
            } else {
                errorLabel.text = "All fields are mandatory."
                errorLabel.alpha = 1.0
            }
        } else if acceptButton.titleLabel?.text == "confirm" {
            
            if defaultUser.objectForKey("currentUser") != nil {
                let user = Profile.userProfiles.getDefaultUser()
                Profile.userProfiles.updateUser(user) { (error) -> Void in
                    if error == nil {
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        LaundryAlert.presentErrorAlert("Unable to change location", error: error!, toController: self)
                    }
                }
            } else {
                navigationController?.popViewControllerAnimated(true)
            }
        } else {
            errorLabel.alpha = 0.0
            let newLocation = Location()
            newLocation.locationId = NSUUID().UUIDString
            newLocation.zip = zipField.text!
            newLocation.street = streetField.text!
            newLocation.city = LocationManager.sharedLocations.cities[String(newLocation.zip)]!
            newLocation.numDryers = NumDryerField.text!
            newLocation.numWashers = NumLaundryField.text!
            
            DynamoDB.save(newLocation) { (error) -> Void in
                if error != nil {
                    LaundryAlert.presentErrorAlert("Unable to create a new location", error: error!, toController: self)
                } else {
                    if Profile.userProfiles.registeringUser != nil {
                        Profile.userProfiles.registeringUser!.locationId = newLocation.locationId
                    } else {
                        let user = Profile.userProfiles.getDefaultUser()
                        user.locationId = newLocation.locationId
                        self.defaultUser.setObject(NSKeyedArchiver.archivedDataWithRootObject(user), forKey: "currentUser")
                        Profile.userProfiles.updateUser(user) { (error) -> Void in
                            if error == nil {
                                self.navigationController?.popViewControllerAnimated(true)
                            } else {
                                LaundryAlert.presentErrorAlert("Unable to change location", error: error!, toController: self)
                            }
                        }
                    }
                    let washers = Int(newLocation.numWashers)!
                    if washers > 0 {
                        for id in 1...washers {
                            let newMachine = Machine()
                            newMachine.locationId = newLocation.locationId
                            newMachine.machineId = NSUUID().UUIDString
                            newMachine.machineType = .Washer
                            newMachine.counter = Int(self.WashingTimeField.text!)! * 60
                            newMachine.state = .Empty
                            newMachine.workEndDate = NSDate()
                            newMachine.orderNumber = id
                        
                            LocationManager.sharedLocations.addMachine(newMachine) { (error) -> Void in
                                if error != nil {
                                    print("Unable to add a washing machine to database \(error!.localizedDescription)")
                                    LaundryAlert.presentCustomAlert("Server error", alertMessage: "Unable to add a washing machine to database. Please try again later.", toController: self)
                                }
                            }
                        }
                    }
                    let dryers = Int(newLocation.numDryers)!
                    if dryers > 0 {
                        for id in 1...dryers {
                            let newDryer = Machine()
                            newDryer.machineType = .Dryer
                            newDryer.state = .Empty
                            newDryer.workEndDate = NSDate()
                            newDryer.locationId = newLocation.locationId
                            newDryer.machineId = NSUUID().UUIDString
                            newDryer.orderNumber = id
                        
                            LocationManager.sharedLocations.addMachine(newDryer) { (error) -> Void in
                                if error != nil {
                                    print("Unable to add a dryer machine to database \(error!.localizedDescription)")
                                    LaundryAlert.presentCustomAlert("Server error", alertMessage: "Unable to add a dryer to database. Please try again later", toController: self)
                                }
                            }
                        }
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        updateBottomLayoutConstraint(withHeight: keyboardFrame.height)
        updateNewLocationTopConstraint(true)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraint(withHeight: 49)
        updateNewLocationTopConstraint(false)
    }
    
    func updateBottomLayoutConstraint(withHeight height: CGFloat) {
        acceptButtonBottonConstraint.constant = height
    }
    
    func updateNewLocationTopConstraint(keyboardOpen: Bool) {
            if self.screenSizeHeight <= 480 {
                if keyboardOpen && !self.newLocationVeiw.hidden {
                    self.zipField.hidden = true
                    self.zipCodeLabel.hidden = true
                    self.errorLabel.hidden = true
                    self.newLocationViewTopTableViewConstraint.priority = 250
                    self.newLocationViewTopLayoutConstraint.priority = 999
                } else {
                    self.newLocationViewTopLayoutConstraint.priority = 250
                    self.newLocationViewTopTableViewConstraint.priority = 999
                    self.zipField.hidden = false
                    self.zipCodeLabel.hidden = false
                    self.errorLabel.hidden = false
                }
            }
            self.view.layoutIfNeeded()
    }
 
    
}


