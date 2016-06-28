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
        newLocationVeiw.hidden = true
        errorLabel.alpha = 0.0
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        resignFirstResponder()
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
    
    // MARK: - tableView setup
    
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
        //------------- load existing location or open create new location optional view
        if indexPath.row != 0 {
            acceptButton.setTitle("confirm", forState: .Normal)
            
            if defaultUser.objectForKey("currentUser") == nil {
                Profile.userProfiles.registeringUser?.locationId = locationResults[indexPath.row - 1].locationId
            } else {
                let user = Profile.userProfiles.getDefaultUser()
                user.locationId = locationResults[indexPath.row - 1].locationId
                defaultUser.setObject(NSKeyedArchiver.archivedDataWithRootObject(user), forKey: "currentUser")
            }
            newLocationVeiw.hidden = true
        } else {
            newLocationVeiw.hidden = false
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
                    
    }   }   }   }
    
    
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
        } else if zipField.text!.characters.count == 5 && locationResults.isEmpty {
            errorLabel.text = "Zip code is incorrect."
            errorLabel.alpha = 1.0
        } else if acceptButton.titleLabel?.text == "save" && (zipField.text!.isEmpty || streetField.text!.isEmpty || NumLaundryField.text!.isEmpty || WashingTimeField.text!.isEmpty || NumDryerField.text!.isEmpty) {
            errorLabel.text = "All fields are mandatory."
            errorLabel.alpha = 1.0
        } else if acceptButton.titleLabel?.text == "confirm" {
            
            if defaultUser.objectForKey("currentUser") != nil {
                let user = Profile.userProfiles.getDefaultUser()
                Profile.userProfiles.updateUser(user) { (error) -> Void in
                    if error == nil {
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        self.serverAlert("Unable to change location", error: error!)
                }   }
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
                    self.serverAlert("Unable to create a new location", error: error!)
                } else {
                    if Profile.userProfiles.registeringUser != nil {
                        Profile.userProfiles.registeringUser!.locationId = newLocation.locationId
                        print("registering user new location added")
                    } else {
                        let user = Profile.userProfiles.getDefaultUser()
                        user.locationId = newLocation.locationId
                        self.defaultUser.setObject(NSKeyedArchiver.archivedDataWithRootObject(user), forKey: "currentUser")
                        Profile.userProfiles.updateUser(user) { (error) -> Void in
                            if error == nil {
                                print("current user updated new location")
                                self.navigationController?.popViewControllerAnimated(true)
                            } else {
                                self.serverAlert("Unable to change location", error: error!)
                        }   }
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
                                    print("Unable to add a washing machine to db: \(error)")
                                    self.serverAlert("Unable to add a washing machine to db", error: error!)
                                }   }   }   }
                    
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
                                    self.serverAlert("Unable to add a dryer to db", error: error!)
                    }   }   }   }
                    
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    
    
    func serverAlert(title:String, error: NSError) {
        let alertController = UIAlertController()
        alertController.title = title
        alertController.message = error.localizedDescription
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    func fieldAlert(alertMessage: String) {
        let alert = UIAlertController(title: "error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}