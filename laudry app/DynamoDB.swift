//
//  DynamoDB.swift
//  laudry app
//
//  Created by Michalina Simik on 3/14/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import AWSDynamoDB

enum DynamoDBSearchMatchMode {
    
    case Exact
    case Contains
    case StartsWith
    
}

class DynamoDB {
    
    class func save(model: AWSDynamoDBObjectModel, completion: (NSError?) -> Void) {
        AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper().save(model).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: {(task) in
            completion(task.error)
            return nil
        })
    }
    
    class func get<T: AWSDynamoDBModeling>(type: T.Type, key: AnyObject, completion: (T?, NSError?) -> Void) {
        AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper().load(type, hashKey: key, rangeKey: nil).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: {(task) in
            let data: T? = task.result as? T
            var error = task.error
            
            if let data = data where error == nil {
                let attribute = T.hashKeyAttribute()
                let mirror = Mirror(reflecting: data)
                for child in mirror.children {
                    if let label = child.label where label == attribute {
                        if let stringValue = child.value as? String where stringValue == "" {
                            error = NSError(domain: "dynamodb", code: 403, userInfo: [NSLocalizedDescriptionKey: "Item not found"])
                            break
                        }
                    }
                }
            }
            completion(data, error)
            return nil
        })
    }
    
    
    class func delete(model: AWSDynamoDBObjectModel, completion: (NSError?) -> Void) {
        AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper().remove(model).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: {(task) in
            completion(task.error)
            return nil
        })
    }
    
    
    class func search<T: AWSDynamoDBModeling>(type: T.Type, parameterName: String, parameterValue: AnyObject, matchMode: DynamoDBSearchMatchMode, completion: ([T]?, NSError?) -> Void) {
        let scanExpression = AWSDynamoDBScanExpression()
        
        switch matchMode {
        case .Exact:
            scanExpression.filterExpression = "\(parameterName) = :\(parameterName)"
        case .Contains:
            scanExpression.filterExpression = "contains(\(parameterName), :\(parameterName))"
        case .StartsWith:
            scanExpression.filterExpression = "begins_with(\(parameterName), :\(parameterName))"
        }
        scanExpression.expressionAttributeValues = [":\(parameterName)" : parameterValue]
        
        AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper().scan(type, expression: scanExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: {(task) in
            var array: [T]? = nil
            var error = task.error
            
            if let result = task.result as? AWSDynamoDBPaginatedOutput where error == nil {
                if let items = result.items as? [T] {
                    array = items
                } else {
                    error = NSError(domain: "dynamodb", code: 403, userInfo: [NSLocalizedDescriptionKey: "Unable to parse items"])
                }
            }
            completion(array, error)
            return nil
        })
    }
    
    
    //quuery
    
}