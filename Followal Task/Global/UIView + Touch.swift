//
//  UIView + Touch.swift
//  followal
//
//  Created by Vivek Gadhiya on 24/05/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable class ViewButton: UIView {
    
    var onClick: () -> Void = {}
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onClick()
    }
}

