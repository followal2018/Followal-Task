//
//  FolderResponse.swift
//  Followal Task
//
//  Created by iMac on 31/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON

class FolderResponseModel:Object, Mappable {
    
    @objc dynamic var UserId: String = ""
    @objc dynamic var _id: String = ""
    @objc dynamic var FolderName: String = ""
    @objc dynamic var FolderId: String = ""
    var Userdata =  List<UserDataResponseModel>()

    override static func primaryKey() -> String? {
        return "FolderName"
    }
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        UserId <- map["UserId"]
        _id <- map["_id"]
        FolderName <- map["FolderName"]
        FolderId <- map["FolderID"]
        Userdata <- map["Userdata"]
        if let userdata = JSON(map["Userdata"].currentValue as Any).rawString() , let userdataObj = Mapper<UserDataResponseModel
            >().mapArray(JSONString:  userdata) {
            Userdata.append(objectsIn: userdataObj)
        }
    }
}
