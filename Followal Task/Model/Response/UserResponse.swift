//
//  UserResponse.swift
//  Followal Task
//
//  Created by iMac on 31/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON


class UserDataResponseModel:Object, Mappable {
    
    @objc dynamic var EmailAddress: String = ""
    @objc dynamic var UserName: String = ""
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        EmailAddress <- map["EmailAddress"]
        UserName <- map["UserName"]
    }
    
}
class UserResponseModel:Object, Mappable {
    
    
    @objc dynamic var EmailAddress: String = ""
    @objc dynamic var UserId: String = ""
    @objc dynamic var Profile: String = ""
    @objc dynamic var UserName: String = ""
    @objc dynamic var Schedule:ScheduleTask!
    
    override static func primaryKey() -> String? {
        return "EmailAddress"
    }
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        EmailAddress <- map["EmailAddress"]
        UserId <- map["_id"]
        Profile <- map["Profile"]
        UserName <- map["UserName"]
        if let scheduleData = JSON(map["Schedule"].currentValue as Any).rawString() , let schedule = Mapper<ScheduleTask
            >().map(JSONString:  scheduleData) {
            Schedule = schedule
        }
    }
    
}

class AssignUserResponseModel:Object, Mappable {
    
    
    @objc dynamic var EmailAddress: String = ""
    @objc dynamic var UserId: String = ""
    @objc dynamic var Profile: String = ""
    @objc dynamic var UserName: String = ""
    @objc dynamic var Schedule:ScheduleTask!
    
   
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        EmailAddress <- map["EmailAddress"]
        UserId <- map["_id"]
        Profile <- map["Profile"]
        UserName <- map["UserName"]
        if let scheduleData = JSON(map["Schedule"].currentValue as Any).rawString() , let schedule = Mapper<ScheduleTask
            >().map(JSONString:  scheduleData) {
            Schedule = schedule
        }
    }
    
}
