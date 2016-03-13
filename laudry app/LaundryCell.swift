//
//  LaundryCell.swift
//  laudry app
//
//  Created by Michalina Simik on 2/3/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

//protocol LaundryCellDelegate {
//    func laundryCellDidTapReserve(laundryCell: LaundryCell)
//    func laundryCellDidChangeState(laundryCell: LaundryCell)
//}
//
//
//class LaundryCell: MachineCell {

//    var delegate: LaundryCellDelegate?
//    
//    var laundry: Laundry! {
//        didSet {
//            updateState()
//            updateResaStatus()
//        }
//    }
//    
   // var reports: Report!
    
   // @IBOutlet weak var machineLabel: UILabel!
  //  @IBOutlet weak var reserveButton: UIButton!
   // @IBOutlet weak var startButton: UIButton!
   // @IBOutlet weak var timerLabel: UILabel!
    
    
//    func updateState() {
//        switch laundry.state {
//        case .Empty:
//            startButton.setTitle("start", forState: .Normal)
//            if laundry.resaStatus == .Free {
//                machineLabel.backgroundColor = UIColor.greenColor()
//            } else if laundry.resaStatus == .Reserved {
//                machineLabel.backgroundColor = UIColor.yellowColor()
//            }
//            timerLabel?.text = "00:45:00"
//        case .Working:
//            startButton.setTitle("washing...", forState: .Normal)
//            machineLabel.backgroundColor = UIColor.redColor()
//            timerLabel?.text = String(format:"%02d:%02d:%02d", laundry.counter/3600, laundry.counter/60, laundry.counter%60)
//        case .Finished:
//            startButton.setTitle("done!", forState: .Normal)
//            machineLabel.backgroundColor = UIColor.redColor()
//            timerLabel?.text = "00:00:00"
//            print("adding to reports...")
//            ReportManager.sharedInstance.addWashingReport(laundry)
//        }
//    }
    
//    func updateResaStatus() {
//        switch laundry.resaStatus {
//        case .Free:
//            reserveButton.setTitle("reserve", forState: .Normal)
//            if laundry.state == .Empty {
//                machineLabel.backgroundColor = UIColor.greenColor() }
//        case .Reserved:
//            reserveButton.setTitle("cancel", forState: .Normal)
//            if laundry.state == .Empty {
//                machineLabel.backgroundColor = UIColor.yellowColor() }
//        }
//    }
    
    
//    @IBAction func reserveButtonTapped(sender: UIButton) {
//        if Profile.userProfiles.currentUser != nil {
//        if laundry.state == .Empty {
//            laundry.workEndDate = NSDate()
//        }
//        if laundry.resaStatus == .Reserved {
//            ReportManager.sharedInstance.addCancellationReport(laundry)
//        }
//        
//        delegate?.laundryCellDidTapReserve(self)
//        } else {
//            sender.enabled = false
//        }
//    }

  //  @IBAction func startButtonTapped(sender: UIButton) // {
//        switch laundry.state {
//        case .Empty:
//            print("work end time before updating: \(laundry.workEndDate)")
//            laundry.state = .Working
//            updateState()
//            laundry.workEndDate = NSDate().dateByAddingTimeInterval(Double(laundry.counter))
//            print("work end time: \(laundry.workEndDate)")
//            delegate?.laundryCellDidChangeState(self)
//        case .Finished:
//            print("work end time when staus finished is: \(laundry.workEndDate)")
//            laundry.state = .Empty
//            updateState()
//            laundry.workEndDate = NSDate()
//            print("work end time when empty: \(laundry.workEndDate)")
//            delegate?.laundryCellDidChangeState(self)
//        case .Working:
//            break
//        }
//    }
 

//}
