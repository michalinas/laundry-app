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
    // notif: "Finished": "your laundry is done", "reserved": "your reservation of machine # starts in 10 min"
    //
    var waitingMachineCell: MachineCell!
    var laundries: [Machine] = []
    var dryers: [Machine] = []
    @IBOutlet weak var dryerCollectionView: UICollectionView!
    @IBOutlet weak var noMachineLabel: UILabel!
    
    let defaultUser = NSUserDefaults.standardUserDefaults()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        machineLoad()
    }
    
    // Do any additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()
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
            cell = laundryCollectionView.dequeueReusableCellWithReuseIdentifier("laundryCell" , forIndexPath: indexPath) as? MachineCell
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
        // --- alert removed ---
        if machineCell.machine.state == .Working {
            
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: (#selector(ViewController.updateTimer(_:))), userInfo: machineCell.machine, repeats: true)
        }
    }
    
    func StartButtonShowAlert(machineCell: MachineCell) {
        let alertController = UIAlertController()
        alertController.title = "Not available"
        alertController.message = "Another user has made a reservation for this time. Please come back later."
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
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
        print(counter, counterText)
        if counter > 0 {
            machineCell?.timerLabel.text = counterText
        } else if counter <= 0 {
            machineCell?.timerLabel.text = "00:00:00"
            machine.state = .Finished
            
            ReportManager.sharedInstance.addReport(machine) { (error) -> Void in
                if error != nil {
                    print("no finished report added: \(error?.localizedDescription)")
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
                print("in closure...\(user.locationId)")
                if !(allMachines!.isEmpty) {
                    print("machines will be loaded...\(allMachines?.count)")
                    for eachMachine in allMachines! {
                        if eachMachine.machineType == .Washer {
                            self.laundries.append(eachMachine)
                            print("laundry added")
                        } else {
                            self.dryers.append(eachMachine)
                            print("dryer added")
                }   }
                print("finished")
                
                if self.laundries.count > 1 {
                self.laundries = self.laundries.sort({ (laundry1: Machine, laundry2: Machine) -> Bool in
                    return laundry1.orderNumber < laundry2.orderNumber
                })
                }
                if self.dryers.count > 1 {
                self.dryers.sortInPlace({ (dryer1: Machine, dryer2: Machine) -> Bool in
                    return dryer1.orderNumber < dryer2.orderNumber
                })
                }}
                self.laundryCollectionView.reloadData()
                self.dryerCollectionView.reloadData()
            
        }   }   }

    }
    

    
    // MARK: - Data picker for laundry
    
    @IBAction func reserveTimeChosen(sender: UIDatePicker) {
       
        
        
        
   }
    
    
    @IBOutlet weak var pickTimeView: UIView!
    @IBOutlet weak var validateReservation: UIButton!
    @IBOutlet weak var cancelReservation: UIButton!
    @IBOutlet weak var dataPicker: UIDatePicker!
    
    @IBAction func cancellButtonTapped(sender: UIButton) {
        pickTimeView.alpha = 0.0
    }
    
//add reservation time to laundryCell when validate button on datapicker view is tapped
    @IBAction func validateButtonTapped(sender: UIButton) {
        let chosenTime = dataPicker.date
        ReportManager.sharedInstance.getReservationForMachine(waitingMachineCell.machine.machineId) { (reservations, error) in
            if reservations!.isEmpty {
                print("can be added right now")
                ReportManager.sharedInstance.addReservation(self.waitingMachineCell.machine, reservedTime: chosenTime) { (error) -> Void in
                    if error != nil {
                        print("cannot add reservation: \(error?.localizedDescription)")
                    }
                self.waitingMachineCell.updateResaStatus()
                self.pickTimeView.alpha = 0.0
                }
            } else {
            let conflictingTimeInterval = Double(self.waitingMachineCell.machine.counter + 900)
            print(conflictingTimeInterval)
            for each in reservations! {
                let actualTimeInterval = chosenTime.timeIntervalSinceDate(each.reservedTime)
                print(actualTimeInterval)
                if actualTimeInterval > conflictingTimeInterval || actualTimeInterval < (-1 * conflictingTimeInterval) {
                    ReportManager.sharedInstance.addReservation(self.waitingMachineCell.machine, reservedTime: chosenTime) { (error) -> Void in
                        if error != nil {
                            print("cannot add reservation: \(error?.localizedDescription)")
                        }
                        print("ok")
                        self.waitingMachineCell.updateResaStatus()
                        self.pickTimeView.alpha = 0.0
                    }
                } else {
                    let alertController = UIAlertController()
                    alertController.title = "Time not available"
                    alertController.message = "Chosen time has been reserved by another user. Please choose other convinient time."
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    print("wrong time chosen")

                }
                } }
            print("all checked")
        }
        
        
//        ReportManager.sharedInstance.addReservation(waitingMachineCell.machine, reservedTime: dataPicker.date) { (error) -> Void in
//            if error != nil {
//                print("cannot add reservation: \(error?.localizedDescription)")
//            }
//            self.waitingMachineCell.updateResaStatus()
//            self.pickTimeView.alpha = 0.0
//        }
        
        // -- reserved alert removed --
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

