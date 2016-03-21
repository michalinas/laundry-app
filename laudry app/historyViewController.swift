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
    
    var reservationReports: [Reservation] = []
    var finishedReports: [Report] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = "YOUR HISTORY"
        titleHistory.text = title
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.HistoryTableView.addSubview(refreshControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        HistoryTableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Profile.userProfiles.currentUser == nil {
            noUserLabel.hidden = false
            noUserLabel.text = "Please log in to see your history."
            return 0
        } else if section == 0 {
            noUserLabel.hidden = true
            
            ReportManager.sharedInstance.getResrvationsForUser(Profile.userProfiles.currentUser!.username) { (reservations, error) -> Void in
                if error != nil {
                    self.reservationReports = reservations!
                }
            }
            return reservationReports.count
        } else {
            noUserLabel.hidden = true
            
            ReportManager.sharedInstance.getReporsForUser(Profile.userProfiles.currentUser!.username) { (reports, error) -> Void in
                if error != nil {
                    self.finishedReports = reports!
                }
            }
            return finishedReports.count
        }
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
        
        
        
        if Profile.userProfiles.currentUser != nil {
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
    
    
    func refresh() {
        self.HistoryTableView.reloadData()
        refreshControl.endRefreshing()
    }

    

}










