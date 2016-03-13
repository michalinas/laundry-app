//
//  errorLabel.swift
//  laudry app
//
//  Created by Michalina Simik on 3/4/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit


class ErrorLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 3
        layer.borderColor = UIColor(red: 1, green: 157/255, blue: 153/255, alpha: 1).CGColor
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = UIColor.whiteColor()
    }
    
}



// Washing Machine by jon trillana from the Noun Project
// User Setup by Richard Schumann from the Noun Project