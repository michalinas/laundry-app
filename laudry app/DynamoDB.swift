//
//  DynamoDB.swift
//  laudry app
//
//  Created by Michalina Simik on 3/14/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import AWSDynamoDB

class DynamoDB {
    
    class func save(model: AWSDynamoDBObjectModel, completion: (NSError?) -> Void) {
        AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper().save(model).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: {(task) in
            completion(task.error)
            return nil
        })
    }
    
    class func get<T>(type: T.Type, key: String, completion: (T?, NSError?) -> Void) {
        AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper().load(type as! AnyClass, hashKey: key, rangeKey: nil).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: {(task) in
            let data: T? = task.result as? T
            
            completion(data, task.error)
            return nil
        })
    }
    
}