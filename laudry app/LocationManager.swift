//
//  LocationManager.swift
//  laudry app
//
//  Created by Michalina Simik on 3/1/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

class LocationManager {
    
    static let sharedLocations = LocationManager()
    
    var locations: [Int : Location] = [:]
    var lastLocationId = 0
    var cities: [String: String] = [:]
    
    func addWasher(counter: Int, numOfWashers: Int, location: Location) {
        let newWasher = Machine()
        newWasher.type = .Washer
        newWasher.counter = counter * 60
        newWasher.id = numOfWashers
        newWasher.state = .Empty
        newWasher.workEndDate = NSDate()
        location.washers.append(newWasher)
        
    }
    
    func addDryer(numOfDryers: Int, location: Location) {
        let newDryer = Machine()
        newDryer.type = .Dryer
        newDryer.id = numOfDryers
        newDryer.state = .Empty
        newDryer.workEndDate = NSDate()
        location.dryers.append(newDryer)
    }

    func createLocation(zip: Int, street: String, buildingNum: String = "") -> Location {
        let newLocation = Location()
        lastLocationId += 1
        newLocation.locationId = zip * 1000 + lastLocationId
        newLocation.zip = zip
        newLocation.street = street
        newLocation.buildingNum = buildingNum
        newLocation.city = cities[String(zip)]!
        locations[newLocation.locationId] = newLocation
        Profile.userProfiles.registeringUser?.locationId = newLocation.locationId
        return newLocation
    }
    
    
    func loadCities() {
        let bundle = NSBundle.mainBundle().pathForResource("zips", ofType: "txt")
        let content = try! String(contentsOfFile: bundle!)
        let arrayContent: [String] = content.componentsSeparatedByString("\n")
        for each in arrayContent {
            var cityData = each.componentsSeparatedByString(" ")
            let length = cityData.count - 1
            var cityName = ""
            if length != 0 {
                for i in 1...length {
                    cityName += cityData[i] + " "
                }
                cities[cityData[0]] = cityName
            } }
    }
    
    func getCityForZip(zip: String) -> String {
        if let cityName = cities[zip] {
            return cityName
        } else {
            return ""
        }
    }
    
    func getLocationsForZip(newZip: String) -> [Int] {
        let numZip: Int = Int(newZip)!
        var existingLocations: [Int] = []
        for each in locations {
            if each.1.zip == numZip {
                existingLocations.append(each.1.locationId)
            }
        }
        return existingLocations
    }
    
        
    func checkStreetForDouble(street: String) {
        // addlater
    }
    
    func loadLocations() {
        loadCities()
        let loc1 = createLocation(10024, street: "1212 78th Street")
        let loc2 = createLocation(10024, street: "5050 50th Street")
        let loc3 = createLocation(10024, street: "1634 64th Street")
        for i in 1...3 {
            addWasher(1, numOfWashers: i, location: loc1)
            addDryer(i, location: loc1)
        }
        addWasher(1, numOfWashers: 1, location: loc2)
        addDryer(1, location: loc2)
        for i in 1...6 {
            addWasher(1, numOfWashers: i, location: loc3)
            addDryer(i, location: loc3)
        }
    }
    

    
    
    
}