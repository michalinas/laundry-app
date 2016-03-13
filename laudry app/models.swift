//
//  models.swift
//  laudry app
//
//  Created by Michalina Simik on 2/3/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit


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
    var useTime: String = "00:00"
    var cancel: Bool = false
}


class User: Equatable {
    var username: String = ""
    var password: String = ""
    var chosenLocationId: Int = 0
    
}

func == (left: User, right: User) -> Bool {
    return left.username == right.username
}


class Location {
    var zip: Int = 0
    var street: String?
    var buildingNum: String?
    var washers: [Machine] = []
    var dryers: [Machine] = []
    var locationId: Int = 0
}