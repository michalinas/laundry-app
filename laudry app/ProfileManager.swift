//
//  ProfileManager.swift
//  laudry app
//
//  Created by Michalina Simik on 2/22/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class Profile {
    
    static let userProfiles = Profile()
    let emptyUsernameConstant = "_empty_username_"
    
    var profiles: [String:User] = [:]
    
    // var currentUser: User? = nil
    
    var registeringUser: User? = nil
    
    let defaultUser = NSUserDefaults.standardUserDefaults()   
    
   func registerNewUser(newUser: User, completion: (NSError?) -> Void ) {
        DynamoDB.save(newUser) { (error) -> Void in
            if error != nil {
                print("error in profilManger registerNewUser\(error)")
            } else {
                // self.currentUser = newUser
                self.defaultUser.setObject(NSKeyedArchiver.archivedDataWithRootObject(newUser), forKey: "currentUser")
                self.registeringUser = nil
            }
            completion(error)
        }
    }
    
    
    func checkUsername(username: String, completion: (User?, NSError?) -> Void ) {
        DynamoDB.get(User.self, key: username) { (user, error) -> Void in
            var error = error
            if user != nil {
                error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey : "username exists already"])
            } else if error != nil {
                error = nil
            }
            
            completion(user, error)
        }
    }


    func trytoLogIn(username: String, password: String, completion: (NSError?) -> Void) {
        DynamoDB.get(User.self, key: username) { (user, error) -> Void in
            var error = error
            guard let user = user else {
                error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey : "user not found"])
                completion(error)
                return 
            }
            
            if error == nil && user.username == username && user.password == password {
                self.defaultUser.setObject(NSKeyedArchiver.archivedDataWithRootObject(user), forKey: "currentUser")
            } else {
                print(" error in func \(error?.localizedDescription)")
                error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey : "uncorrect password"])
            }
            completion(error)
        }
    }
    
    
    
    func startNewUser() -> User {
        if registeringUser == nil {
            registeringUser = User()
        }
        
        return registeringUser!
    }
    
    func updateUser(updatedUser: User, completion: (NSError?) -> Void) {
        DynamoDB.save(updatedUser) { (error) -> Void in
            if error == nil {
                self.defaultUser.setObject(NSKeyedArchiver.archivedDataWithRootObject(updatedUser), forKey: "currentUser")
               // self.currentUser = updatedUser
            }
            completion(error)
       }
    }
    
    
    func getAllUsersForLocationId(locationId: String, completion: ([User]?, NSError?) -> Void) {
        DynamoDB.search(User.self, parameterName: "locationId", parameterValue: locationId, matchMode: .Exact) { (users, error) -> Void in
            completion(users, error)
        }
    }
    

    func getDefaultUser() -> User {
        let data = defaultUser.objectForKey("currentUser") as! NSData
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
    }
    
}
