//
//  MachineCell.swift
//  laudry app
//
//  Created by Michalina Simik on 2/26/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

protocol MachineCellDelegate {
    func MachineCellDidChangeState(machineCell: MachineCell)
    func MachineCellDidTapReserve(machineCell: MachineCell)
    func StartButtonShowAlert(machineCell: MachineCell)
}


class MachineCell: UICollectionViewCell {
    
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var dryerStepper: UIStepper!
    @IBOutlet weak var dryerTime: UITextField!
      
    var reports: Report!
    let defaultUser = NSUserDefaults.standardUserDefaults()
    
    var machine: Machine! {
        didSet {
            if machine.machineType == .Washer {
                updateResaStatus()
            }
            updateState()
    }   }
    
    var delegate: MachineCellDelegate?
    
    
    func updateState() {
        machineLabel.text = String(machine.orderNumber)
        switch machine.state {
        case .Empty:
            startButton.setTitle("start", forState: .Normal)
            timerLabel!.text = "00:00:00"
            if machine.machineType == .Washer && reserveButton.titleLabel?.text == "cancel" {
                machineLabel.backgroundColor = UIColor(red: 1, green: 204/255, blue: 102/255, alpha: 1)
            } else {
                machineLabel.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 80/255, alpha: 1)
            } 
            if machine.machineType == .Dryer {
                timerLabel.hidden = true
                dryerTime.hidden = false
                dryerTime.keyboardType = UIKeyboardType.NumberPad
                dryerTime.placeholder = "0 min"
                dryerTime.text = nil
                dryerStepper.hidden = false
                dryerStepper.maximumValue = 120.0
                dryerStepper.minimumValue = 5.0
                dryerStepper.stepValue = 5.0
            }
        case .Working:
            if machine.machineType == .Washer {
                startButton.setTitle("washing...", forState: .Normal)
            } else {
                startButton.setTitle("drying...", forState: .Normal)
                timerLabel.hidden = false
                dryerStepper.hidden = true
                dryerTime.hidden = true
            }
            machineLabel.backgroundColor = UIColor(red: 1, green: 102/255, blue: 105/255, alpha:1)
            let counter = Int(machine.workEndDate.timeIntervalSinceNow)
            
            if counter > 0 {
                let counterText = String(format:"%02d:%02d:%02d", counter/3600, counter/60, counter%60)
                timerLabel.text = counterText
                delegate?.MachineCellDidChangeState(self)
            } else {
               delegate?.MachineCellDidChangeState(self)
            }
        case .Finished:
            startButton.setTitle("done!", forState: .Normal)
            machineLabel.backgroundColor = UIColor(red: 1, green: 102/255, blue: 105/255, alpha:1)
            timerLabel.text = "00:00:00"
            if machine.machineType == .Dryer {
                dryerStepper.hidden = true
                dryerTime.hidden = true
            }
        }
        LocationManager.sharedLocations.updateMachine(machine) { (error) in
            if error != nil {
                //LaundryAlert.presentCustomAlert("Server error", alertMessage: "machine update cannot be saved on server", toController: self)
                print("machine update cannot be saved on server")
            }
        }
    }
    
    
    func updateResaStatus() {
        if machine.machineType == .Washer {
            let user = Profile.userProfiles.getDefaultUser()
            
            ReportManager.sharedInstance.getReservationForMachineAndUser(machine.machineId, username: (user.username)) { (reservation, error) -> Void in
                if !reservation!.isEmpty {
                    for _ in reservation! {
                        self.reserveButton.setTitle("cancel", forState: .Normal)
                        if self.machine.state == .Empty {
                            self.machineLabel.backgroundColor = UIColor(red: 1, green: 204/255, blue: 102/255, alpha: 1)
                    }   }
                } else {
                    self.reserveButton.setTitle("reserve", forState: .Normal)
                    if self.machine.state == .Empty {
                        self.machineLabel.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 80/255, alpha: 1)
        }   }   }   }
    }

    /* start/empty machine
     if startbutton tapped and machine is a wmpty washer, it will verify if there is no pending reservation from different user which conflict
     with the washing time +15 min. if a collision found will pop up an alert
     
     
     */
    @IBAction func startButtonTApped(sender: UIButton) {
        let user = Profile.userProfiles.getDefaultUser()
        switch machine.state {
        case .Empty:
            let username = Profile.userProfiles.getDefaultUser().username
            if machine.machineType == .Dryer {
                startedMachine(user)
            } else {
                ReportManager.sharedInstance.getReservationForMachineAndUser(machine.machineId, username: username) { (reservations, error) in
                    if !reservations!.isEmpty {
                        let resa = reservations![0]
                        if resa.reservedTime.compare(NSDate().dateByAddingTimeInterval(901)) == NSComparisonResult.OrderedAscending {
                            self.startedMachine(user)
                            DynamoDB.delete(resa) { (error) in
                                if error != nil {
                                    print(error)
                                }
                            }
                        }
                    } else {
                        ReportManager.sharedInstance.getReservationForMachine(self.machine.machineId) { (reservations, error) in
                        if reservations!.isEmpty {
                            self.startedMachine(user)
                        } else {
                            var found = false
                            for each in reservations! {
                                if NSDate().dateByAddingTimeInterval(Double(self.machine.counter) + 899).compare(each.reservedTime) == NSComparisonResult.OrderedAscending {
                                    found = true
                                    self.startedMachine(user)
                                }
                            }
                            if !found {
                                self.delegate?.StartButtonShowAlert(self)
                            }
                        }
                    }
                }
                }
            }
//            
//            machine.state = .Working
//            updateState()
//            machine.usernameUsing = user.username
//            machine.workEndDate = NSDate().dateByAddingTimeInterval(Double(machine.counter))
//            delegate?.MachineCellDidChangeState(self)
        case .Finished:
            if machine.usernameUsing == user.username {
                machine.state = .Empty
                machine.usernameUsing = "?"
                updateState()
                machine.workEndDate = NSDate()
                delegate?.MachineCellDidChangeState(self)
            } else {
            }
        case .Working:
            break
        }
    }

    
    func startedMachine(user: User) {
        machine.state = .Working
        updateState()
        machine.usernameUsing = user.username
        machine.workEndDate = NSDate().dateByAddingTimeInterval(Double(machine.counter))
        LocationManager.sharedLocations.updateMachine(machine) { (error) in
            if error == nil {
                self.delegate?.MachineCellDidChangeState(self)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    
    @IBAction func reserveButtonTapped(sender: UIButton) {
        if defaultUser.objectForKey("currentUser") != nil {
            sender.enabled = true
            if machine.state == .Empty {
                machine.workEndDate = NSDate()
            }
            if reserveButton.titleLabel?.text! == "cancel" {
                let user = Profile.userProfiles.getDefaultUser()
                ReportManager.sharedInstance.getReservationForMachineAndUser(machine.machineId, username: (user.username)) { (reservations, error) -> Void in
                    if let reservations = reservations {
                        ReportManager.sharedInstance.addCancelledReservation(reservations) { (error) -> Void in
                            if error == nil {
                                self.updateResaStatus()
                        }   }
                    } else {
                        print("impossible to cxl reservation")
            }   }   }
            delegate?.MachineCellDidTapReserve(self)
        } else {
            sender.enabled = false
        }
    }
    
    
    @IBAction func dryerStepperTapped(sender: UIStepper) {
        machine.counter = Int(sender.value) * 60
        dryerTime.text = String(Int(sender.value))
    }
    
    
}
