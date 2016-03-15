//
//  models.swift
//  laudry app
//
//  Created by Michalina Simik on 2/3/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

enum LaundryState: Int {
    case Empty
    case Working
    case Finished
}


enum ReservationStatus: Int {
    case Free
    case Reserved
}


enum MachineType: Int {
    case Dryer
    case Washer
}


enum ActionType: Int {
    case Reservation
    case Cancellation
    case Finished
}


class Machine {
    var state: LaundryState = .Empty
    var workEndDate: NSDate = NSDate()
    var id: Int = -1
    var counter: Int = 5
    var type: MachineType = .Washer
    var madeReservations: [String: Reservation] = [:]
    var userNameForWorking: String?
}


class Reservation {
    var machineId: Int = 0
    var reservedTime: NSDate = NSDate()
    var username: String = ""
}


class Report {
    var machineId: Int = 0
    var machineType: MachineType = .Washer
    var actionType: ActionType = .Reservation
    var useTime: NSDate = NSDate()
    var cancel: Bool = false
}


class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var username: String = ""
    var password: String = ""
    var locationId: NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "User"
    }
    
    class func hashKeyAttribute() -> String {
        return "username"
    }
}

func == (left: User, right: User) -> Bool {
    return left.username == right.username
}


class Location {
    var zip: Int = 0
    var city: String = ""
    var street: String?
    var buildingNum: String?
    var washers: [Machine] = []
    var dryers: [Machine] = []
    var locationId: Int = 0
}