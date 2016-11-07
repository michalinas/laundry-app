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
    case Empty = 0
    case Working = 1
    case Finished = 2
}


enum MachineType: Int {
    case Washer = 0
    case Dryer = 1
}


class Machine: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var locationId: String = ""
    var machineId: String = ""
    var stateInt: Int = 0
    var workEndDatestamp: NSNumber = 0
    var counter: Int = 5
    var machineTypeInt: Int = 0
    var usernameUsing: String = Profile.userProfiles.emptyUsernameConstant
    var orderNumber: Int = 0
    
    var state: LaundryState {
        get { return LaundryState(rawValue: stateInt)! }
        set { stateInt = newValue.rawValue }
    }
    
    var machineType: MachineType {
        get { return MachineType(rawValue: machineTypeInt)! }
        set { machineTypeInt = newValue.rawValue }
    }
    
    var workEndDate: NSDate {
        get { return NSDate(timeIntervalSince1970: workEndDatestamp.doubleValue) }
        set { workEndDatestamp = newValue.timeIntervalSince1970 }
    }
    
    class func dynamoDBTableName() -> String {
        return "Machine"
    }
    
    class func hashKeyAttribute() -> String {
        return "machineId"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["machineType", "state", "workEndDate"]
    }
}


class Reservation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var reservationId: String = NSUUID().UUIDString
    var machineId: String = ""
    var reservedTimestamp: NSNumber = 0
    var username: String = ""
    var cancel: Bool = false
    var orderNumber: Int = 0
    
    var reservedTime: NSDate {
        get { return NSDate(timeIntervalSince1970: reservedTimestamp.doubleValue) }
        set { reservedTimestamp = newValue.timeIntervalSince1970 }
    }
    
    class func dynamoDBTableName() -> String {
        return "Reservation"
    }
    
    class func hashKeyAttribute() -> String {
        return "reservationId"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["reservedTime"]
    }
}


class Report: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    var reportId:  String = NSUUID().UUIDString
    var machineId: String = ""
    var username: String = ""
    var machineTypeInt: Int = 0
    var finishedTimestamp: NSNumber = 0
    var orderNumber: Int = 0
    
    var machineType: MachineType {
        get { return MachineType(rawValue: machineTypeInt)! }
        set { machineTypeInt = newValue.rawValue  }
    }
    
    var timeFinished: NSDate {
        get { return NSDate(timeIntervalSince1970: finishedTimestamp.doubleValue) }
        set { finishedTimestamp = newValue.timeIntervalSince1970 }
    }

    class func dynamoDBTableName() -> String {
        return "Report"
    }
    
    class func hashKeyAttribute() -> String {
        return "reportId"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["timeFinished", "machineType"]
    }
}


class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var username: String = ""
    var password: String = ""
    var locationId: String = ""
    
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


class Location: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var locationId: String = ""
    var city: String = ""
    var street: String = ""
    var zip: String = "00000"
    var numDryers: String = "0"
    var numWashers: String = "0"
    
    class func dynamoDBTableName() -> String {
        return "Location"
    }
    
    class func hashKeyAttribute() -> String {
        return "locationId"
    }
}
