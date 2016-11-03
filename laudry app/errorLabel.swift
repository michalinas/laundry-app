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
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 1, green: 157/255, blue: 153/255, alpha: 1).CGColor
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .None
    }
    
//    func adjustSize() -> Void {
//        let width = bounds.width
//        frame.size.width = width + 6
//        layoutIfNeeded()
//    }
    
    private var topInset: CGFloat = 2.0
    private var bottomInset: CGFloat = 2.0
    private var leftInset: CGFloat = 7.0
    private var rightInset: CGFloat = 7.0
    
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
