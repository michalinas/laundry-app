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
    
    var profiles: [String:User] = [:]
    
    var currentUser: User? = nil
    
    var registeringUser: User? = nil

   
   func registerNewUser(newUser: User, completion: (NSError?) -> Void ) {
        DynamoDB.save(newUser) { (error) -> Void in
            print("name: \(newUser.username)")
            print("location: \(newUser.locationId)")
            if error != nil {
                print("error in profilManger\(error)")
            } else {
                self.currentUser = newUser
                self.registeringUser = nil
            }
            completion(error)
        }
    }
    
    
    func checkUsername(username: String, completion: (NSError?) -> Void ) {
        DynamoDB.get(User.self, key: username) { (user, error) -> Void in
            var error = error
            if error != nil {
                error = nil
            } else {
                error = NSError(domain: "laundry", code: 501, userInfo: [NSLocalizedDescriptionKey: "This username already exists."])
            }
        completion(error)
        }
    }


    func trytoLogIn(username: String, password: String, completion: (NSError?) -> Void) {
        DynamoDB.get(User.self, key: username) { (user, error) -> Void in
            var error = error
            
            if error == nil {
                if user!.username == username && user!.password == password {
                    self.currentUser = user
                } else {
                    error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid username or password"])
                }
            }
            completion(error)
        }
    }
    
    
    
    func startNewUser() {
        if registeringUser == nil {
            registeringUser = User()
        }
    }
    
    func updateUser(updatedUser: User, completion: (NSError?) -> Void) {
        DynamoDB.save(updatedUser) { (error) -> Void in
             var error = error
            
            if error != nil {
                error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey: "cannot save changes"])
            } else {
                print("user will be updated")
                self.currentUser = updatedUser

            }
            completion(error)
       }
    }
    
    
    func getAllUsersForLocationId(locationId: Int, completion: ([User]?, NSError?) -> Void) {
        DynamoDB.search(User.self, parameterName: "locationId", parameterValue: locationId, matchMode: .Exact) { (users, error) -> Void in
            completion(users, error)
        }
    }
    
    
    func loadUsers() {
        let user1 = User()
        let user2 = User()
        user1.username = "michalina"
        user1.password = "csx500"
        user1.locationId = 10024001
        user2.username = "david"
        user2.password = "thisis50"
        user2.locationId = 10024001
        profiles["michalina"] = user1
        profiles["david"] = user2
        ReportManager.sharedInstance.addUserToReports("michalina")
        ReportManager.sharedInstance.addUserToReports("david")
        
        DynamoDB.search(User.self, parameterName: "username", parameterValue: "s", matchMode: .Contains) { (data, error) -> Void in
            if let data = data {
                for (index, user) in data.enumerate() {
                    print("User #\(index): \(user.username)")
                }
            } else {
                print("Error: \(error)")
            }
        }
        
        getAllUsersForLocationId(10024001) { (users, error) -> Void in
            if let users = users {
                for user in users {
                    print("User with id 10024001: \(user.username)")
                }
            }
            print("End displaying users for 10024001")
        }
        
//        let dynamoDB = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
//        let queryExpression = AWSDynamoDBQueryExpression()
//        queryExpression.hashKeyAttribute = "username"
//        queryExpression.hashKeyValues = "michalina"
//        dynamoDB.query(User.self, expression: queryExpression) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock:  { (task) -> AnyObject? in
//            if task.error != nil {
//                print("error from load users \(task.error)")
//                
//            } else {
//                print("result from load users\(task.result)")
//            }
//            
//            
//            
//            return nil
//        })
    }
    
}