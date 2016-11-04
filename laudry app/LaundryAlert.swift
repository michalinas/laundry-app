//
//  LaundryAlert.swift
//  laundryNYC
//
//  Created by Michalina Simik on 11/1/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation

class LaundryAlert {

    class func presentErrorAlert(title: String = "Error", error: NSError, toController viewController: UIViewController ) {
        let message = error.localizedDescription
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }


    class func presentCustomAlert(title: String, alertMessage: String, toController viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    

}
