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
    var lastLocationId: Int?
    var cities: [String: String] = [:]
    
    /* add machine to db or threw an error
    */
    func addMachine(newMachine: Machine, completion: (NSError?) -> Void ) {
            DynamoDB.save(newMachine) { (error) -> Void in
                completion(error)
        }
    }

    /* create unique location id for newLocation,
    add newLocation to db or threw an error
    */
    func createLocation(newLocation: Location, completion: (NSError?) -> Void ) {
        newLocation.locationId = NSUUID().UUIDString
        DynamoDB.save(newLocation) { (error) -> Void in
            if error == nil {
                Profile.userProfiles.registeringUser?.locationId = newLocation.locationId
            }
            completion(error)
        }
    }

    
    /* find the location with given location id
    */
    func getLocationWith(locationId: String, completion: (Location?, NSError?) -> Void)  {
        DynamoDB.get(Location.self, key: locationId) { (theLocation, error) -> Void in
            completion(theLocation, error)
        }
    }
    
    func updateMachine(updatedMachine: Machine, completion: (NSError?) -> Void) {
        DynamoDB.save(updatedMachine) { (error) -> Void in
            completion(error)
        }
    }
    
    func getMachinesForLocation(locationId: String, completion: ([Machine]?, NSError?) -> Void) {
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
    
        
    //TODO: func checkStreetForDouble(street: String)
    
    
}
