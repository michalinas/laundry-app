//
//  roundedButton.swift
//  laudry app
//
//  Created by Michalina Simik on 3/4/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        clipsToBounds = true

    }
    
    
    
}