//
//  historyViewController.swift
//  laudry app
//
//  Created by Michalina Simik on 2/11/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var titleHistory: UILabel!
    @IBOutlet weak var HistoryTableView: UITableView!
    @IBOutlet weak var noUserLabel: UILabel!
    
    let defaultUser = NSUserDefaults.standardUserDefaults()
    
    var reservationReports: [Reservation] = []
    var finishedReports: [Report] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = "YOUR HISTORY"
        titleHistory.text = title
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(HistoryViewController.refresh), forControlEvents: .ValueChanged)
        self.HistoryTableView.addSubview(refreshControl)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        loadContent()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "reservations"
        case 1:
            return "Done laundries"
        default:
            return ""
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath) as! ReportCell
        var machineReport: Report?
        var machineReservation: Reservation?
        
        if defaultUser.objectForKey("currentUser") != nil {
            if indexPath.section == 0 {
                machineReservation = reservationReports[indexPath.row]
                cell.resReport = machineReservation
            } else {
                machineReport = finishedReports[indexPath.row]
                cell.report = machineReport
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if defaultUser.objectForKey("currentUser") == nil {
            noUserLabel.hidden = false
            noUserLabel.text = "Please log in to see your history."
            return 0
        } else if section == 0 {
            noUserLabel.hidden = true
            return reservationReports.count
        } else {
            noUserLabel.hidden = true
            return finishedReports.count
        }
    }

    
    func refresh() {
        self.HistoryTableView.reloadData()
        refreshControl.endRefreshing()
    }

    func loadContent() {
        if defaultUser.objectForKey("currentUser") == nil {
            reservationReports.removeAll()
            finishedReports.removeAll()
            self.HistoryTableView.reloadData()
        } else {
            let user = Profile.userProfiles.getDefaultUser()
            ReportManager.sharedInstance.getReservationsForUser(user.username) { (reservations, error) -> Void in
                if error == nil {
                    self.reservationReports = reservations!
                    self.reservationReports.sortInPlace({ (reservation1: Reservation, reservation2: Reservation) -> Bool in
                        return reservation1.reservedTime.compare(reservation2.reservedTime) == NSComparisonResult.OrderedAscending
                    })
                } else {
                    LaundryAlert.presentErrorAlert(error: error!, toController: self)
                }
            
                self.HistoryTableView.reloadData()
            }
            ReportManager.sharedInstance.getReporsForUser(user.username) { (reports, error) -> Void in
                if error == nil {
                    self.finishedReports = reports!
                    self.finishedReports.sortInPlace({ (report1: Report, report2: Report) -> Bool in
                        return report1.timeFinished.compare(report2.timeFinished) == NSComparisonResult.OrderedDescending
                    })
                } else {
                    LaundryAlert.presentErrorAlert(error: error!, toController: self)
                }
            self.HistoryTableView.reloadData()
            }
        }
    }
}










