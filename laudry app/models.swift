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




class Machine: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var locationId: NSNumber = 0
    var machineId: Int = -1
    var state: LaundryState = .Empty
    var workEndDate: NSDate = NSDate()
    var counter: Int = 5
    var type: MachineType = .Washer
    // var madeReservations: [String: Reservation] = [:]
    var userNameForWorking: String?
    
    class func dynamoDBTableName() -> String! {
        return "Machine"
    }
    
    class func hashKeyAttribute() -> String! {
        return "machineId"
    }
}


class Reservation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var machineId: NSNumber = 0
    var reservedTime: NSDate = NSDate()
    var username: String = ""
    var cancel: Bool = false
    
    class func dynamoDBTableName() -> String! {
        return "Reservation"
    }
    
    class func hashKeyAttribute() -> String! {
        return "username"
    }
}


class Report: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    var machineId: Int = 0
    var username: String = ""
    var machineType: MachineType = .Washer
    var finishedTimestamp: NSNumber = 0
    
    var timeFinished: NSDate {
        get { return NSDate(timeIntervalSince1970: finishedTimestamp.doubleValue) }
        set { finishedTimestamp = newValue.timeIntervalSince1970 }
    }

    class func dynamoDBTableName() -> String! {
        return "Report"
    }
    
    class func hashKeyAttribute() -> String! {
        return "username"
    }
    
    class func ignoreAttributes() -> [AnyObject]! {
        return ["timeFinished"]
    }

}


class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var username: String = ""
    var password: String = ""
    var locationId: NSNumber = 0
    
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
    var locationId: NSNumber = 0
    var city: String = ""
    var street: String?
    var zip: NSNumber = 0
    var numDryers: Int = 0
    var numWashers: Int = 0
    // var buildingNum: String?
    // var washers: [Machine] = []
    // var dryers: [Machine] = []   
    
    class func dynamoDBTableName() -> String {
        return "Location"
    }
    
    class func hashKeyAttribute() -> String {
        return "locationId"
    }
}