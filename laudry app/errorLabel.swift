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
    private var topInset: CGFloat = 2.0
    private var bottomInset: CGFloat = 2.0
    private var leftInset: CGFloat = 5.0
    private var rightInset: CGFloat = 5.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 1, green: 157/255, blue: 153/255, alpha: 1).CGColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
        backgroundColor = .None
    }
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func intrinsicContentSize() -> CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize()
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }

    
}



// Washing Machine by jon trillana from the Noun Project
// User Setup by Richard Schumann from the Noun Project
