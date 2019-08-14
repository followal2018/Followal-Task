//
//  Task.swift
//  followal
//
//  Created by Vivek Gadhiya on 08/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON
class ListTransform<T:RealmSwift.Object> : TransformType where T:Mappable {
    typealias Object = List<T>
    typealias JSON = [AnyObject]
    
    let mapper = Mapper<T>()
    
    func transformFromJSON(_ value: Any?) -> Object? {
        let results = List<T>()
        if let objects = mapper.mapArray(JSONObject: value) {
            for object in objects {
                results.append(object)
            }
        }
        return results
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        var results = [AnyObject]()
        if let value = value {
            for obj in value {
                let json = mapper.toJSON(obj)
                results.append(json as AnyObject)
            }
        }
        return results
    }
}

class ScheduleTask: Object, Mappable {
    @objc dynamic var StartDate: String = ""
    @objc dynamic var DueDateAndTime: String = ""
    @objc dynamic var RepeatReminderDate: String = ""
    @objc dynamic var StopReminder: String = ""
    @objc dynamic var IntervalType:RepeatIntervalType = .never
    var IntervalMonths = List<Int>()
    var IntervalDays = List<Int>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        StartDate <- map["StartDate"]
        DueDateAndTime <- map["DueDateAndTime"]
        StopReminder <- map["StopReminder"]
        RepeatReminderDate <- map["RepeatReminderDate"]
        IntervalType = RepeatIntervalType.getRepeatIntervalType(JSON(map["IntervalType"].currentValue).stringValue)
        let aDay = JSON(map["IntervalDays"].currentValue).arrayValue
        let aMonth = JSON(map["IntervalMonths"].currentValue).arrayValue
        for list in aDay {
            if list != "" {
                IntervalDays.append(list.intValue)
            }
        }
        for list in aMonth {
            if list != "" {
                IntervalMonths.append(list.intValue)
            }
        }
    }
}



class Task: Object, Mappable {
    
    @objc dynamic var UserId: String = ""
    @objc dynamic var _id: String = ""
    @objc dynamic var TaskLocalId: String = ""
    @objc dynamic var TaskTitle: String = ""
    @objc dynamic var FolderName: String = ""
    @objc dynamic var Description: String = ""
    @objc dynamic var IsDone: TaskStatus = .pending
    @objc dynamic var Schedule:ScheduleTask!
    var SubTask = List<SubTask>()
    var Assigned =  List<AssignUserResponseModel>()
    var Reviewer = List<UserResponseModel>()
    var Files = List<String>()

    override static func primaryKey() -> String? {
        return "TaskLocalId"
    }
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        UserId <- map["UserId"]
        _id <- map["_id"]
        TaskLocalId <- map["TaskLocalId"]
        TaskTitle <- map["TaskTitle"]
        FolderName <- map["FolderName"]
        Description <- map["Description"]
        // RepeatReminder <- (map["RepeatReminder"], ListTransform<RepeatInterval>)
      //  Schedule <- map["Schedule"]
        
        
        if let scheduleData = JSON(map["Schedule"].currentValue as Any).rawString() , let schedule = Mapper<ScheduleTask
            >().map(JSONString:  scheduleData) {
            Schedule = schedule
        }
        SubTask <- (map["SubTask"], ListTransform<SubTask>())
        if let assignData = JSON(map["Assign"].currentValue as Any).rawString() , let assignObj = Mapper<AssignUserResponseModel
            >().mapArray(JSONString:  assignData) {
            Assigned.append(objectsIn: assignObj)
        }
        Reviewer <- (map["Reviewer"], ListTransform<UserResponseModel>())
        Files <- map["Files"]
        IsDone = TaskStatus.getTaskStatus(map["IsDone"].currentValue as? Int ?? 0)
        
        Files.removeAll()
        let files = JSON(map["Files"].currentValue).arrayValue
        for file in files {
              Files.append(file.stringValue)
          }
        }
}

class SubTask: Object, Mappable {
    
    @objc dynamic var Task: String = ""
    @objc dynamic var IsDone: TaskStatus = .pending
    @objc dynamic var _id: String = ""
    @objc dynamic var SubtaskId: String = ""

    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "SubtaskId"
    }
    
    func mapping(map: Map) {
        Task <- map["Task"]
        _id <- map["_id"]
        SubtaskId <- map["SubtaskId"]
        IsDone = TaskStatus.getTaskStatus(map["IsDone"].currentValue as? Int ?? 0)

    }
    
   
}

class CreateSubTask {
    
    var Task: String = ""
    var IsDone: Int = 0
    var SubtaskId: String = "" 

    
}

//class RepeatInterval: Object,Mappable {
//
//    required convenience init?(map: Map) {
//        self.init()
//    }
//
//    func mapping(map: Map) {
//        type = RepeatIntervalType.getRepeatIntervalType(JSON(map["Type"].currentValue).stringValue)
//        for list in JSON(map["Day"].currentValue).arrayValue {
//            days.append(list.intValue)
//        }
//        for list in JSON(map["Month"].currentValue).arrayValue {
//            month.append(list.intValue)
//        }
//        for list in JSON(map["Week"].currentValue).arrayValue {
//            weeks.append(list.intValue)
//        }
//
//    }
//}

@objc enum TaskStatus: Int {
    
    case pending = 0
    case done = 1
    
    static func getTaskStatus(_ value: Int) -> TaskStatus {
        switch value {
        case 0:
            return .pending
        case 1:
            return .done
        default:
            return .pending
        }
    }
    var intValue: Int {
       return rawValue
    }
}


@objc enum SortBy: Int {
    
    case none = 0
    case startDate = 1
    case dueDate = 2
    case remindDate = 3
    
}

@objc enum RepeatIntervalType: Int {
    
    case never = 0
    case day = 1
    case week = 2
    case month = 3
    case year = 4
    
    static func getRepeatIntervalType(_ string: String) -> RepeatIntervalType {
        
        switch string {
        case "Never":
            return .never
        case "Day":
            return .day
        case "Week":
            return .week
        case "Month":
            return .month
        default:
            return .year
        }
    }
    
    var textValue: String {
        if self.rawValue == 0 {
            return "Never"
        } else if self.rawValue == 1 {
            return "Day"
        } else if self.rawValue == 2 {
            return "Week"
        } else if self.rawValue == 3 {
            return "Month"
        } else {
            return "Year"
        }
    }
}
