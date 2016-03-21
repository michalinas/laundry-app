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
        let label = cell!.machineLabel
        label?.text = "\(indexPath.item + 1)"
        cell!.delegate = self
        return cell!
    }
    
    
    //MARK: - delegates
    
    func MachineCellDidTapReserve(laundryCell: MachineCell) {
        waitingMachineCell = laundryCell
        
        ReportManager.sharedInstance.getResrvationsForUser((Profile.userProfiles.currentUser?.username)!) { (reservations, error) -> Void in
            if reservations != nil {
                var i = 1
                for everyReservation in reservations! {
                    print("resa \(i)")
                    i++
                    if everyReservation.machineId == laundryCell.machine.machineId && !everyReservation.cancel {
                        ReportManager.sharedInstance.addCancelledReservation(everyReservation) { (error) -> Void in
                            //---------------
                        }
                        break
                    }
                }
                    print("picktime inside reservations !=nil")
                    self.pickTime(laundryCell)
            
            } else {
                print("picktime no res")
                self.pickTime(laundryCell)
            }
            laundryCell.updateResaStatus()
    }   }


    func MachineCellDidChangeState(machineCell: MachineCell) {
        waitingMachineCell = machineCell
        // --- alert removed ---
        if machineCell.machine.state == .Working {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: ("updateTimer:"), userInfo: machineCell.machine, repeats: true)
        }
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
        if machine.type == .Washer {
            machineCells = (laundryCollectionView.visibleCells() as? [MachineCell])!
        } else {
            machineCells = (dryerCollectionView.visibleCells() as? [MachineCell])!
        }
            for cell in machineCells {
                if cell.machine === machine {
                    machineCell = cell
                    break
        }   }
        if machine.counter > 1 {
            machine.counter--
            machineCell?.timerLabel.text = String(format:"%02d:%02d:%02d", machine.counter/3600, machine.counter/60, machine.counter%60)
        } else if machine.counter == 1 {
            machine.counter--
            machineCell?.timerLabel.text = String(format:"%02d:%02d:%02d", machine.counter/3600, machine.counter/60, machine.counter%60)
            machine.state = .Finished
            
            ReportManager.sharedInstance.addReport(machine) { (error) -> Void in
                if error != nil {
                    print("no finished report added: \(error?.localizedDescription)")
                }
            }
            
            machineCell?.updateState()
            
            if let _ = machineCell {
               MachineCellDidChangeState(machineCell!)
    }   }   }
    
    
    func machineLoad() {
        if Profile.userProfiles.currentUser == nil {
            noMachineLabel.text = "Please log in to see your location display."
            noMachineLabel.hidden = false
            laundries.removeAll()
            dryers.removeAll()
        } else {
            noMachineLabel.hidden = true
            
            LocationManager.sharedLocations.getMachinesForLocation(Int((Profile.userProfiles.currentUser?.locationId)!)) { (allMachines, error) -> Void in
                if allMachines != nil {
                    for eachMachine in allMachines! {
                        if eachMachine.type == .Washer {
                            self.laundries.append(eachMachine)
                        } else {
                            self.dryers.append(eachMachine)
        }   }   }   }   }
        
        laundryCollectionView.reloadData()
        dryerCollectionView.reloadData()
    }
    

    
    // MARK: - Data picker for laundry
    
    @IBAction func reserveTimeChosen(sender: UIDatePicker) {
       // let chosenTime: NSDate = dataPicker.date
      //  waitingMachineCell.machine.reservationTime = chosenTime
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
        
        ReportManager.sharedInstance.addReservation(waitingMachineCell.machine, reservedTime: dataPicker.date) { (error) -> Void in
            if error != nil {
                print("cannot add reservation: \(error?.localizedDescription)")
            }
        }
        
        pickTimeView.alpha = 0.0

        waitingMachineCell.updateResaStatus()
        // -- reserved alert removed --
    }
    
// set a datepicker with Cancel,Done buttons and opens the datapicekr view
    func pickTime(laundryCell: MachineCell) {
        let maxDate = NSDate().dateByAddingTimeInterval(86400)
        //maxDate = maxDate.dateByAddingTimeInterval(86400)
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

