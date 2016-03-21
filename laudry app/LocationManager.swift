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
    
    // var locations: [Int : Location] = [:]
    var lastLocationId = 0
    var cities: [String: String] = [:]
    
    
    /* add machine to db or threw an error
    */
    func addMachine(newMachine: Machine, completion: (NSError?) -> Void ) {
        DynamoDB.save(newMachine) { (error) -> Void in
            var error = error
            if error != nil {
                error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey : "cannot add new machine"])
            }
        completion(error)
        }
    }
    
    /* create unique location id for newLocation,
    add newLocation to db or threw an error
    */
    func createLocation(newLocation: Location, completion: (NSError?) -> Void ) {
        lastLocationId += 1
        newLocation.locationId = newLocation.zip.integerValue * 1000 + lastLocationId
        
        DynamoDB.save(newLocation) { (error) -> Void in
            if error == nil {
                Profile.userProfiles.registeringUser?.locationId = newLocation.locationId
            } else {
                print("cannot create a new location in db")
                
            }
            completion(error)
        }
    }
    
    
    
    
    /* find all locations for the given zip code
    */
    func getLocationsForZip(zip: Int, completion: ([Location]?, NSError?) -> Void)  {
        DynamoDB.search(Location.self, parameterName: "locationId", parameterValue: zip, matchMode: .StartsWith) { (locations, error) -> Void in            
            completion(locations, error)
        }
    }
    
    
    /* find the location with given location id
    */
    func getLocationWith(locationId: Int, completion: (Location?, NSError?) -> Void)  {
        DynamoDB.get(Location.self, key: locationId) { (theLocation, error) -> Void in
            var error = error
            if error != nil {
                error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey : "unable to find location"])
            }
            completion(theLocation, error)
        }
    }
    
    
    func updateMachine(updatedMachine: Machine, completion: (NSError?) -> Void) {
        DynamoDB.save(updatedMachine) { (error) -> Void in
            completion(error)
        }
    }
    
    func getMachinesForLocation(locationId: Int, completion: ([Machine]?, NSError?) -> Void) {
        DynamoDB.search(Machine.self, parameterName: "locationId", parameterValue: locationId, matchMode: .Exact) { (machines, error) -> Void in
            completion(machines, error)
        }
    }
    
    
    
    
    
    
    /* load file with cities and zipcodes for NY
    */
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
    

    
        
    func checkStreetForDouble(street: String) {
        // addlater
    }
    
    func loadLocations() {
        loadCities()
        //let loc1 = createLocation(10024, street: "1212 78th Street")
       // let loc2 = createLocation(10024, street: "5050 50th Street")
       // let loc3 = createLocation(10024, street: "1634 64th Street")
//        for i in 1...3 {
//            addWasher(1, numOfWashers: i, locationId: loc1)
//            addDryer(i, locationId: loc1)
//        }
//        addWasher(1, numOfWashers: 1, locationId: loc2)
//        addDryer(1, locationId: loc2)
//        for i in 1...6 {
//            addWasher(1, numOfWashers: i, locationId: loc3)
//            addDryer(i, locationId: loc3)
//        }
    }
    
    
}