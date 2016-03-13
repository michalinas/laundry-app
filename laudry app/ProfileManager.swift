//
//  ProfileManager.swift
//  laudry app
//
//  Created by Michalina Simik on 2/22/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

class Profile {
    
    static let userProfiles = Profile()
    
    var profiles: [String:User] = [:]
    
    var currentUser: User? = nil
    
    var registeringUser: User? = nil

    
    func registerNewUser(newUser: User) {
        profiles[newUser.username] = newUser
        currentUser = newUser
        registeringUser = nil
    }
    
    func checkUsername(username: String) -> Bool {
        if profiles[username] != nil {
                return true
            }
        return false
    }
    
    func trytoLogIn(username: String, password: String) -> Bool {
        if password == profiles[username]?.password {
            currentUser = profiles[username]!
            return true
        }
        return false
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
        user1.chosenLocationId = 10024001
        user2.username = "david"
        user2.password = "thisis50"
        user2.chosenLocationId = 10024001
        profiles["michalina"] = user1
        profiles["david"] = user2
        ReportManager.sharedInstance.addUserToReports("michalina")
        ReportManager.sharedInstance.addUserToReports("david")
    }
    
}