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
}


class MachineCell: UICollectionViewCell {
    
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var dryerStepper: UIStepper!
    @IBOutlet weak var dryerTime: UITextField!
      
    var reports: Report!
    
    var machine: Machine! {
        didSet {
            updateState()
            if machine.type == .Washer {
                updateResaStatus()
    }   }   }
    
    var delegate: MachineCellDelegate?
    
    
    func updateState() {
        switch machine.state {
        case .Empty:
            startButton.setTitle("start", forState: .Normal)
            timerLabel!.text = "00:00:00"
            if machine.type == .Dryer {
                machineLabel.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 80/255, alpha: 1)
                timerLabel.hidden = true
                dryerTime.hidden = false
                dryerTime.keyboardType = UIKeyboardType.NumberPad
                dryerTime.placeholder = "5 min"
                dryerTime.text = nil
                dryerStepper.hidden = false
                dryerStepper.maximumValue = 120.0
                dryerStepper.minimumValue = 5.0
                dryerStepper.stepValue = 5.0
            } else if machine.type == .Washer && machine.madeReservations[(Profile.userProfiles.currentUser?.username)!] == nil {
                machineLabel.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 80/255, alpha: 1)
            } else {
                machineLabel.backgroundColor = UIColor(red: 1, green: 204/255, blue: 102/255, alpha: 1)
            }
        case .Working:
            if machine.type == .Washer {
                    startButton.setTitle("washing...", forState: .Normal)
            } else {
                startButton.setTitle("drying...", forState: .Normal)
                timerLabel.hidden = false
                dryerStepper.hidden = true
                dryerTime.hidden = true
            }
            machineLabel.backgroundColor = UIColor(red: 1, green: 102/255, blue: 105/255, alpha:1)
            timerLabel.text = String(format:"%02d:%02d:%02d", machine.counter/3600, machine.counter/60, machine.counter%60)
        case .Finished:
            startButton.setTitle("done!", forState: .Normal)
            machineLabel.backgroundColor = UIColor(red: 1, green: 102/255, blue: 105/255, alpha:1)
            timerLabel.text = "00:00:00"
        }
    }
    
    func updateResaStatus() {
        if machine.type == .Washer {
            if (machine.madeReservations[(Profile.userProfiles.currentUser?.username)!] == nil) {
                reserveButton.setTitle("reserve", forState: .Normal)
                if machine.state == .Empty {
                    machineLabel.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 80/255, alpha: 1)
                }
            } else if (machine.madeReservations[(Profile.userProfiles.currentUser?.username)!]?.reservedTime.dateByAddingTimeInterval(Double(900)).compare(NSDate()) == NSComparisonResult.OrderedAscending) {
                machine.madeReservations[(Profile.userProfiles.currentUser?.username)!] = nil
                ReportManager.sharedInstance.addCancellationReport(machine)
                reserveButton.setTitle("reserve", forState: .Normal)
                if machine.state == .Empty {
                    machineLabel.backgroundColor = UIColor(red: 45/255, green: 188/255, blue: 80/255, alpha: 1)
                }
                
            } else {
                reserveButton.setTitle("cancel", forState: .Normal)
                if machine.state == .Empty {
                    machineLabel.backgroundColor = UIColor(red: 1, green: 204/255, blue: 102/255, alpha: 1)
                }
            }   }   }
    
    
    @IBAction func startButtonTApped(sender: UIButton) {
        switch machine.state {
        case .Empty:
            machine.state = .Working
            updateState()
            machine.userNameForWorking = Profile.userProfiles.currentUser?.username
            machine.workEndDate = NSDate().dateByAddingTimeInterval(Double(machine.counter))
            delegate?.MachineCellDidChangeState(self)
        case .Finished:
            if machine.userNameForWorking == Profile.userProfiles.currentUser?.username {
                machine.state = .Empty
                machine.userNameForWorking = nil
                updateState()
                machine.workEndDate = NSDate()
                delegate?.MachineCellDidChangeState(self)
            } else {
                sender.enabled = false
            }
        case .Working:
            break
        }
    }
    
    @IBAction func reserveButtonTapped(sender: UIButton) {
        if Profile.userProfiles.currentUser != nil {
            if machine.state == .Empty {
                machine.workEndDate = NSDate()
            }
            if machine.madeReservations[(Profile.userProfiles.currentUser?.username)!] != nil {
                ReportManager.sharedInstance.addCancellationReport(machine)
            }
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