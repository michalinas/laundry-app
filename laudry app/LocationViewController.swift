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
    
    let alertsMessages = ["zipLength":"please insert full 5-digit zip code", "empty": "all fields are obligatory. Fill missing fields and submit again."]
    
    var locationResults: [Int] = []
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
        NumLaundryField.text = "0"
        NumLaundryField.keyboardType = .NumberPad
        NumLaundryField.delegate = self
        washingTimeLabel.text = "washing machine cycle length (min)"
        WashingTimeField.text = "0"
        WashingTimeField.keyboardType = .NumberPad
        WashingTimeField.delegate = self
        washingTimeStepper.maximumValue = 120.0
        numDryerLabel.text = "number of dryers"
        NumDryerField.text = "0"
        NumDryerField.keyboardType = .NumberPad
        NumDryerField.delegate = self
        acceptButton.setTitle("save", forState: .Normal)
        locationTableView.delegate = self
        locationTableView.dataSource = self
        newLocationVeiw.hidden = true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
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
    
    //-----------
    
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
            print("row 0")
            cell.textLabel?.text = cityName
            cell.detailTextLabel?.text = "click to add new location"
        } else {
            let index = indexPath.row - 1
            cell.textLabel?.text = cityName + ", " + LocationManager.sharedLocations.locations[locationResults[index]]!.street!
            let washingMachines = LocationManager.sharedLocations.locations[locationResults[index]]!.washers.count
            let dryers = LocationManager.sharedLocations.locations[locationResults[index]]!.dryers.count
            if washingMachines == 1 && dryers == 1{
                cell.detailTextLabel?.text = "\(washingMachines) washing mashine, \(dryers) dryer"
            } else if washingMachines == 1 {
                cell.detailTextLabel?.text = "\(washingMachines) washing mashine, \(dryers) dryers"
            } else if dryers == 1 {
                cell.detailTextLabel?.text = "\(washingMachines) washing mashines, \(dryers) dryer"
            } else {
                cell.detailTextLabel?.text = "\(washingMachines) washing mashines, \(dryers) dryers"
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //------------- load location or create new
        if indexPath.row != 0 {
            acceptButton.setTitle("confirm", forState: .Normal)
            Profile.userProfiles.registeringUser?.chosenLocationId = (LocationManager.sharedLocations.locations[locationResults[indexPath.row - 1]]!.locationId)
            newLocationVeiw.hidden = true
        } else {
            newLocationVeiw.hidden = false
            acceptButton.setTitle("save", forState: .Normal)
        }
    }
    
    //-----------------
    
    
    @IBAction func zipEntered(sender: UITextField) {
        if sender.text!.characters.count < 5 {
            locationResults.removeAll()
            self.locationTableView.reloadData()
        } else {
        LocationManager.sharedLocations.loadCities()
        cityName = LocationManager.sharedLocations.getCityForZip(sender.text!)
        print(cityName)
        if cityName != "" {
            locationResults = LocationManager.sharedLocations.getLocationsForZip(sender.text!)
        }
        self.locationTableView.reloadData()
        } }
    
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
        if sender.title == "save" && (zipField.text!.isEmpty || streetField.text!.isEmpty || NumLaundryField.text!.isEmpty || WashingTimeField.text!.isEmpty || NumDryerField.text!.isEmpty) {
            fieldAlert(alertsMessages["empty"]!)
        // } else if zipField.text!.characters.count != 5 {
           // fieldAlert(alertsMessages["zipLength"]!)
        } else if acceptButton.titleLabel?.text == "confirm" {
            navigationController?.popViewControllerAnimated(true)

        } else {
            let newLocation = LocationManager.sharedLocations.createLocation(Int(zipField.text!)!, street: streetField.text!)
            let dryers = Int(NumDryerField.text!)
            let washers = Int(NumLaundryField.text!)
            for every in 1...dryers! {
                LocationManager.sharedLocations.addDryer(every, location: newLocation)
            }
            for every in 1...washers! {
                LocationManager.sharedLocations.addWasher(Int(WashingTimeField.text!)! , numOfWashers: every, location: newLocation)
            }
                Profile.userProfiles.currentUser?.chosenLocationId = newLocation.locationId
                navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    func fieldAlert(alertMessage: String) {
        let alert = UIAlertController(title: "error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}