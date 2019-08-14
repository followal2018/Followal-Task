//
//  UIFont + Helper.swift
//  followal
//
//  Created by Vivek Gadhiya on 16/01/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import UIKit

class Fonts {
    
    static func regular(size: CGFloat) -> UIFont? {
        return R.font.sfProTextRegular(size: size)
    }
    
    static func medium(size: CGFloat) -> UIFont? {
        return R.font.sfProTextMedium(size: size)
    }
    
}
