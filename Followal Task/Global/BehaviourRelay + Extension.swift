//
//  BehaviourRelay + Extension.swift
//  followal
//
//  Created by Vivek Gadhiya on 22/02/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RxCocoa

extension BehaviorRelay where Element: RangeReplaceableCollection {
    func acceptAppending(_ element: Element.Element) {
        accept(value + [element])
    }
  
    func remove(at index: Element.Index) {
        var newValue = value
        newValue.remove(at: index)
        accept(newValue)
    }
    
    func replace(_ element: Element.Element, index: Element.Index) {
        var newValue = value
        newValue.remove(at: index)
        newValue.insert(element, at: index)
        accept(newValue)
    }
    
}
