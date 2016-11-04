//
//  ViewController.swift
//  laudry app
//
//  Created by Michalina Simik on 25/01/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, MachineCellDelegate {
    

    @IBOutlet weak var laundryCollectionView: UICollectionView!
    @IBOutlet weak var washerDryerSwitch: UISegmentedControl!
    var waitingMachineCell: MachineCell!
    var laundries: [Machine] = []
    var dryers: [Machine] = []
    @IBOutlet weak var dryerCollectionView: UICollectionView!
    @IBOutlet weak var noMachineLabel: UILabel!
    
    
    @IBOutlet weak var pickTimeView: UIView!
    @IBOutlet weak var validateReservation: UIButton!
    @IBOutlet weak var cancelReservation: UIButton!
    @IBOutlet weak var dataPicker: UIDatePicker!
    
    let defaultUser = NSUserDefaults.standardUserDefaults()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        machineLoad()
    }
    
    
    @IBAction func LDswitchTapped(sender: AnyObject) {
        switch washerDryerSwitch.selectedSegmentIndex {
        case 0:
            laundryCollectionView.alpha = 1.0
            dryerCollectionView.alpha = 0.0
            laundryCollectionView.reloadData()
        case 1:
            laundryCollectionView.alpha = 0.0
            dryerCollectionView.alpha = 1.0
            pickTimeView.alpha = 0.0
            dryerCollectionView.reloadData()
        default:
           break
        }
    }
    
    
    // MARK: - CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if washerDryerSwitch.selectedSegmentIndex == 0 {
            return laundries.count ?? 0
        } else {
            return dryers.count ?? 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: MachineCell?
        if washerDryerSwitch.selectedSegmentIndex == 1 {
            cell = dryerCollectionView.dequeueReusableCellWithReuseIdentifier("dryerCell", forIndexPath: indexPath) as? MachineCell
            cell!.machine = dryers[indexPath.item]
        } else {
            cell = laundryCollectionView.dequeueReusableCellWithReuseIdentifier("laundryCell", forIndexPath: indexPath) as? MachineCell
            cell!.machine = laundries[indexPath.item]
        }
        cell!.delegate = self
        return cell!
    }
    
    
    //MARK: - delegates
    
    func MachineCellDidTapReserve(laundryCell: MachineCell) {
        waitingMachineCell = laundryCell
        if laundryCell.reserveButton.titleLabel!.text == "reserve" {
            self.pickTime(laundryCell)
        }
        laundryCell.updateResaStatus()
    }
    

    func MachineCellDidChangeState(machineCell: MachineCell) {
        waitingMachineCell = machineCell
        if machineCell.machine.state == .Working {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: (#selector(ViewController.updateTimer(_:))), userInfo: machineCell.machine, repeats: true)
        }
    }
    
    
    func MachineCellPresentError(machineCell: MachineCell, error: NSError) {
        LaundryAlert.presentErrorAlert(error: error, toController: self)
    }

     
    /* count down laundry machine timer when it's working;
    finds a laudry which is passed as a timer.userInfo and start couting and
    updating timerLabel;
    update state when finished 
    */
    func updateTimer(timer: NSTimer) {
        let machine = timer.userInfo as! Machine
        var machineCell: MachineCell?
        var machineCells: [MachineCell]
        if machine.machineType == .Washer {
            machineCells = (laundryCollectionView.visibleCells() as? [MachineCell])!
        } else {
            machineCells = (dryerCollectionView.visibleCells() as? [MachineCell])!
        }
            for cell in machineCells {
                if cell.machine === machine {
                    machineCell = cell
                    break
        }   }
        let counter = Int(machine.workEndDate.timeIntervalSinceNow)
        let counterText = String(format:"%02d:%02d:%02d", counter/3600, counter/60, counter%60)
        if counter > 0 {
            machineCell?.timerLabel.text = counterText
        } else if counter <= 0 {
            machineCell?.timerLabel.text = "00:00:00"
            machine.state = .Finished
            
            ReportManager.sharedInstance.addReport(machine) { (error) -> Void in
                if error != nil {
                    LaundryAlert.presentErrorAlert(error: error!, toController: self)
                }
            }
            
            machineCell?.updateState()
            
            if let _ = machineCell {
               MachineCellDidChangeState(machineCell!)
            }
            timer.invalidate()
        }
    }
    
    
    func machineLoad() {
        if defaultUser.objectForKey("currentUser") == nil {
            laundries.removeAll()
            dryers.removeAll()
            noMachineLabel.text = "Please log in to see your location display."
            noMachineLabel.hidden = false
            laundryCollectionView.reloadData()
            dryerCollectionView.reloadData()
        } else {
            noMachineLabel.hidden = true
            
            let user = Profile.userProfiles.getDefaultUser()
            if !laundries.isEmpty && laundries[0].locationId != user.locationId {
                laundries.removeAll()
                dryers.removeAll()
            }
            if laundries.isEmpty || dryers.isEmpty {
                LocationManager.sharedLocations.getMachinesForLocation(user.locationId) { (allMachines, error) -> Void in
                    if error != nil || (allMachines?.isEmpty)! {
                        LaundryAlert.presentErrorAlert(error: error!, toController: self)
                    } else if !(allMachines!.isEmpty) {
                        for eachMachine in allMachines! {
                            if eachMachine.machineType == .Washer {
                                self.laundries.append(eachMachine)
                            } else {
                                self.dryers.append(eachMachine)
                            }
                        }
                        
                        if self.laundries.count > 1 {
                            self.laundries = self.laundries.sort({ (laundry1: Machine, laundry2: Machine) -> Bool in
                                return laundry1.orderNumber < laundry2.orderNumber
                            })
                        }
                        if self.dryers.count > 1 {
                            self.dryers.sortInPlace({ (dryer1: Machine, dryer2: Machine) -> Bool in
                                return dryer1.orderNumber < dryer2.orderNumber
                            })
                        }
                    }
                    self.laundryCollectionView.reloadData()
                    self.dryerCollectionView.reloadData()

                }
            }
        }
    }

    
    

    // MARK: - Data picker for laundry
    
    @IBAction func cancellButtonTapped(sender: UIButton) {
        pickTimeView.alpha = 0.0
    }
    
//add reservation time to laundryCell when validate button on datapicker view is tapped
    @IBAction func validateButtonTapped(sender: UIButton) {
        let chosenTime = dataPicker.date
        ReportManager.sharedInstance.getReservationForMachine(waitingMachineCell.machine.machineId) { (reservations, error) in
            if error != nil {
                LaundryAlert.presentErrorAlert(error: error!, toController: self)
            } else if reservations!.isEmpty {
                ReportManager.sharedInstance.addReservation(self.waitingMachineCell.machine, reservedTime: chosenTime) { (error) -> Void in
                    if error != nil {
                        LaundryAlert.presentErrorAlert(error: error!, toController: self)
                    }
                    self.waitingMachineCell.updateResaStatus()
                    self.pickTimeView.alpha = 0.0
                }
            } else {
                let conflictingTimeInterval = Double(self.waitingMachineCell.machine.counter + 900)
                for each in reservations! {
                    let actualTimeInterval = chosenTime.timeIntervalSinceDate(each.reservedTime)
                    if actualTimeInterval > conflictingTimeInterval || actualTimeInterval < (-1 * conflictingTimeInterval) {
                        ReportManager.sharedInstance.addReservation(self.waitingMachineCell.machine, reservedTime: chosenTime) { (error) -> Void in
                            if error != nil {
                                LaundryAlert.presentCustomAlert("Server error", alertMessage: "Laundry app was unable to make your reservation. Please try again", toController: self)
                            }
                            self.waitingMachineCell.updateResaStatus()
                            self.pickTimeView.alpha = 0.0
                        }
                    } else {
                        LaundryAlert.presentCustomAlert("Time slot not available", alertMessage: "Chosen time has been reserved by another user. Please choose other convinient time.", toController: self)
                    }
                }
            }
        }
    }
    
// set a datepicker with Cancel,Done buttons and opens the datapicekr view
    func pickTime(laundryCell: MachineCell) {
        let maxDate = NSDate().dateByAddingTimeInterval(86400)
        dataPicker.maximumDate = maxDate
        dataPicker.minimumDate = (laundryCell.machine.workEndDate.compare(NSDate()) == NSComparisonResult.OrderedDescending) ? laundryCell.machine.workEndDate: NSDate()
        dataPicker.minuteInterval = 30
        validateReservation.setTitle("Done", forState: .Normal)
        cancelReservation.setTitle("Cancel", forState: .Normal)
        pickTimeView.backgroundColor = UIColor.whiteColor()
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.pickTimeView.alpha = 1.0
        }
    }
    
    
    
}

