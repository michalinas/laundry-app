//
//  DryerCell.swift
//  laudry app
//
//  Created by Michalina Simik on 2/25/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

//protocol DryerCellDelegate {
//    func DryerChangeState(dryerCell: DryerCell)
//    
//}

//class DryerCell: MachineCell {
    
//    var dryer: Dryer!  {
//        didSet {
//            updateState()
//        }
//    }

    //var delegate: DryerCellDelegate?
    
  //  var reports: Report!

    
//    func updateState() {
//        switch dryer.state {
//        case .Empty:
//            startButton.setTitle("start", forState: .Normal)
//            machineLabel.backgroundColor = UIColor.greenColor()
//            timerLabel.text = "00:00:00"
//        case .Working:
//            startButton.setTitle("washing...", forState: .Normal)
//            machineLabel.backgroundColor = UIColor.redColor()
//            timerLabel.text = String(format:"%02d:%02d:%02d", dryer.counter/3600, dryer.counter/60, dryer.counter%60)
//        case .Finished:
//            startButton.setTitle("done!", forState: .Normal)
//            machineLabel.backgroundColor = UIColor.redColor()
//            timerLabel.text = "00:00:00"
//            print("adding to reports...")
//            ReportManager.sharedInstance.addWashingReport(dryer)
//        }
//    }
//    
//    @IBAction func startButtonTapped(sender: AnyObject) {
//        switch dryer.state {
//        case .Empty:
//            print("work end time before updating: \(dryer.workEndDate)")
//            dryer.state = .Working
//            updateState()
//            dryer.workEndDate = NSDate().dateByAddingTimeInterval(Double(dryer.counter))
//            print("work end time: \(dryer.workEndDate)")
//            delegate?.DryerChangeState(self)
//        case .Finished:
//            print("dryer work end time when .finished is: \(dryer.workEndDate)")
//            dryer.state = .Empty
//            updateState()
//            dryer.workEndDate = NSDate()
//            print("work end time when empty: \(dryer.workEndDate)")
//            delegate?.DryerChangeState(self)
//        case .Working:
//            break
//        }
//    }
    
    
    
//}