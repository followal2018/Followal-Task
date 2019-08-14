//
//  CommentRequest.swift
//  Followal Task
//
//  Created by iMac on 12/08/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
class CommentRequest : Codable {
    
    var taskId = ""
    var comment = ""

    enum CodingKeys: String, CodingKey {
        case taskId = "TaskId"
        case comment = "Comment"
    }
}
