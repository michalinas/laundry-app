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
            if error != nil {
                print("error \(error)")
            } else {
                self.profiles[newUser.username] = newUser
                self.currentUser = newUser
                self.registeringUser = nil
            }
            completion(error)
        }
    }
    
    func checkUsername(username: String) -> Bool {
        if profiles[username] != nil {
                return true
            }
        return false
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
        
//        if password == profiles[username]?.password {
//            currentUser = profiles[username]!
//            return true
//        }
//        return false
    }
    
    func startNewUser() {
        if registeringUser == nil {
            let newUser = User()
            registeringUser = newUser
        }
    }
    
    func changePassword(password: String) {
        profiles[(currentUser?.username)!]!.password = password
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
        
        let dynamoDB = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.hashKeyAttribute = "username"
        queryExpression.hashKeyValues = "michalina"
        dynamoDB.query(User.self, expression: queryExpression) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock:  { (task) -> AnyObject? in
            if task.error != nil {
                print("error \(task.error)")
                
            } else {
                print("result \(task.result)")
            }
            
            
            
            return nil
        })
    }
    
}