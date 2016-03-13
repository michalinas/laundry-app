//
//  ReportManager.swift
//  laudry app
//
//  Created by Michalina Simik on 2/17/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation

class ReportManager {
    static let sharedInstance = ReportManager()
    
    var reservationReports: [String: [Report]] = [:]
    var finishedReports: [String: [Report]] = [:]
    
    func addReservationToLaundry(laundry: Machine) {
        let report = Report()
        report.machineId = laundry.id
        report.actionType = .Reservation
        report.useTime = dateFormat(laundry.madeReservations[(Profile.userProfiles.currentUser?.username)!]!.reservedTime)
        reservationReports[(Profile.userProfiles.currentUser?.username)!]?.insert(report, atIndex: 0)
        print("reservation repport added")
    }
    
    func addWashingReport(machine: Machine) {
        let report = Report()
        report.machineId = machine.id
        report.machineType = machine.type
        report.actionType = .Finished
        report.useTime = dateFormat(NSDate())
        finishedReports[machine.userNameForWorking!]?.insert(report, atIndex: 0)
        print("washing report added")
    }
    
    func addCancellationReport(laundry: Machine) {
        let report = Report()
        report.machineId = laundry.id
        report.actionType = .Cancellation
        report.cancel = true
        print("cancelled report added")
        reservationReports[(Profile.userProfiles.currentUser?.username)!]?.insert(report, atIndex: 0)
    }

    func dateFormat(date: NSDate) -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd-MM-YYYY HH:mm"
        return dateFormat.stringFromDate(date)
    }
    
    func addUserToReports(username: String) {
        reservationReports[username] = []
        finishedReports[username] = []
    }
    
}