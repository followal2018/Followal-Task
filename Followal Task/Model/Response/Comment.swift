
//
//  Comment.swift
//  Followal Task
//
//  Created by iMac on 12/08/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
class Comment: Object, Mappable {
    
    @objc dynamic var userID: String = ""
    @objc dynamic var commentID: String = ""
    @objc dynamic var commentText: String = ""
    @objc dynamic var taskID: String = ""
    @objc dynamic var createTime: Int64 = 0


    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "commentID"
    }
    
    func mapping(map: Map) {
        userID <- map["UserId"]
        commentID <- map["_id"]
        commentText <- map["Comment"]
        taskID <- map["TaskId"]
        createTime <- map["CreateDate"]

    }
}
