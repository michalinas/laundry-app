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
        report.useTime = laundry.madeReservations[(Profile.userProfiles.currentUser?.username)!]!.reservedTime
        reservationReports[(Profile.userProfiles.currentUser?.username)!]?.insert(report, atIndex: 0)
    }
    
    func addWashingReport(machine: Machine) {
        let report = Report()
        report.machineId = machine.id
        report.machineType = machine.type
        report.actionType = .Finished
        report.useTime = NSDate()
        finishedReports[machine.userNameForWorking!]?.insert(report, atIndex: 0)
    }
    
    func addCancellationReport(laundry: Machine) {
        let report = Report()
        report.machineId = laundry.id
        report.actionType = .Cancellation
        report.cancel = true
        reservationReports[(Profile.userProfiles.currentUser?.username)!]?.insert(report, atIndex: 0)
    }

    
    func addUserToReports(username: String) {
        reservationReports[username] = []
        finishedReports[username] = []
    }
    
    func deleteOldReservationReports() {
        if let userReports = reservationReports[(Profile.userProfiles.currentUser?.username)!] {
            if userReports.count != 0 {
                let dateToCompare = NSDate().dateByAddingTimeInterval(Double(-86400))
                var updatedUserReports = userReports
                for i in 0..<userReports.count {
                    if userReports[i].useTime.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
                        updatedUserReports.removeAtIndex(i)
                    }
                }
                reservationReports[(Profile.userProfiles.currentUser?.username)!]! = updatedUserReports
    }   }   }
    
}