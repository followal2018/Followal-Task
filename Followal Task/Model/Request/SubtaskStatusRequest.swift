//
//  SubtaskStatusRequest.swift
//  Followal Task
//
//  Created by iMac on 09/08/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
class SubtaskStatusRequest : Codable {
    
    var TaskLocalId = ""
    var SubtaskId = ""
    var IsDone = 0
    
}

class TaskStatusRequest : Codable {
    
    var TaskLocalId = ""
    var IsDone = 0
    
}
