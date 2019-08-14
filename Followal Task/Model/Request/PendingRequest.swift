//
//  PendingRequest.swift
//  Followal Task
//
//  Created by iMac on 05/08/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON

class PendingRequest: Object {
    @objc dynamic var eventName: String = ""
    @objc dynamic var request: String = ""
    
}
