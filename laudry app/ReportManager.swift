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
    
    // var reservationReports: [String: [Report]] = [:]
    // var finishedReports: [String: [Report]] = [:]
    
    
    
    func addReservation(laundry: Machine, reservedTime: NSDate, completion: (NSError?) -> Void) {
        let reservation = Reservation()
        reservation.machineId = laundry.machineId
        reservation.username = Profile.userProfiles.currentUser!.username
        reservation.reservedTime = reservedTime
        
        DynamoDB.save(reservation) { (error) -> Void in
            completion(error)
        }
    }
    
    func getResrvationsForUser(username: String, completion: ([Reservation]?, NSError?) -> Void) {
        DynamoDB.search(Reservation.self, parameterName: "username", parameterValue: username, matchMode: .Exact) { (reservations, error) -> Void in
            //--------------------
            completion(reservations, error)
        }
    }
    
    
    
    func getReservationForMachine(machineId: Int, completion: ([Reservation]?, NSError?) -> Void) {
        DynamoDB.search(Reservation.self, parameterName: "machineId", parameterValue: machineId, matchMode: .Exact) { (reservations, error) -> Void in
            //--------------------
            completion(reservations, error)
        }
    }
    
    func addCancelledReservation(reservationToCxl: Reservation, completion: (NSError?) -> Void) {
        reservationToCxl.cancel = true
        DynamoDB.save(reservationToCxl) { (error) -> Void in
            completion(error)
        }
    }
    
    func deleteOldReservations(username: String, completion: ([Reservation]?, NSError?) -> Void) {
        DynamoDB.search(Reservation.self, parameterName: "username", parameterValue: username, matchMode: .Exact) { (reservations, error) -> Void in
            //-----------
            if let reservationsToDelete = reservations {
                let dateToCompare = NSDate().dateByAddingTimeInterval(Double(-86400))
                for each in reservationsToDelete {
                    if each.reservedTime.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
                        DynamoDB.delete(each) { (error) -> Void in
                            // ------------- ?
                        }
                    }
                }
            }
            //-----------
            completion(reservations, error)
        }
    }
    
    
//    func deleteOldReservationReports() {
//        if let userReports = reservationReports[(Profile.userProfiles.currentUser?.username)!] {
//            if userReports.count != 0 {
//                let dateToCompare = NSDate().dateByAddingTimeInterval(Double(-86400))
//                var updatedUserReports = userReports
//                for i in 0..<userReports.count {
//                    if userReports[i].useTime.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
//                        updatedUserReports.removeAtIndex(i)
//                    }
//                }
//                reservationReports[(Profile.userProfiles.currentUser?.username)!]! = updatedUserReports
//            }   }   }
    
    
//    
//    func addReservationToLaundry(laundry: Machine) {
//        let report = Report()
//        report.machineId = laundry.machineId
//        report.actionType = .Reservation
//        report.useTime = laundry.madeReservations[(Profile.userProfiles.currentUser?.username)!]!.reservedTime
//        reservationReports[(Profile.userProfiles.currentUser?.username)!]?.insert(report, atIndex: 0)
//    }
    
    
    func addReport(machine: Machine, completion: (NSError?) -> Void) {
        //-----------
        let report = Report()
        report.machineId = machine.machineId
        report.machineType = machine.type
        report.timeFinished = NSDate()
        report.username = machine.userNameForWorking!
        DynamoDB.save(report) { (error) -> Void in
            completion(error)
        }

    }
    
    func getReporsForUser(username: String, completion: ([Report]?, NSError?) -> Void) {
        DynamoDB.search(Report.self, parameterName: "username", parameterValue: username, matchMode: .Exact) { (reports, error) -> Void in
            //--------------------
            completion(reports, error)
        }}
    
    
//    func addWashingReport(machine: Machine) {
//        let report = Report()
//        report.machineId = machine.machineId
//        report.machineType = machine.type
//        report.actionType = .Finished
//        report.useTime = NSDate()
//        finishedReports[machine.userNameForWorking!]?.insert(report, atIndex: 0)
//    }
    
//    func addCancellationReport(laundry: Machine) {
//        let report = Report()
//        report.machineId = laundry.machineId
//        report.actionType = .Cancellation
//        report.cancel = true
//        reservationReports[(Profile.userProfiles.currentUser?.username)!]?.insert(report, atIndex: 0)
//    }

    
    func addUserToReports(username: String) {
       // reservationReports[username] = []
       // finishedReports[username] = []
    }
    

    
}