//
//  UITextField + Apperance.swift
//  followal
//
//  Created by Vivek Gadhiya on 16/02/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import UIKit
extension UITextField {
    
    func setImagePlaceHolder(image: UIImage?, placeHolder: String, font: UIFont, color: UIColor) {
        let placeholderImageTextAttachment = NSTextAttachment()
        placeholderImageTextAttachment.image = image
        placeholderImageTextAttachment.bounds = CGRect(x: 4, y: -2, width: 16, height: 16)
        
        let placeholderText = NSAttributedString(string: "  " + placeHolder, attributes: [ NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color])
        
        let finalPlaceholder = NSAttributedString.init(attachment: placeholderImageTextAttachment).mutableCopy() as! NSMutableAttributedString
        
        finalPlaceholder.append(placeholderText)
        
        self.attributedPlaceholder = finalPlaceholder
    }
    
    
    
}
class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
