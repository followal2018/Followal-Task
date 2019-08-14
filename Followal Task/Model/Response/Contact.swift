//
//  Contact.swift
//  followal
//
//  Created by Vivek Gadhiya on 19/01/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Contact: Object, Mappable {
 
    @objc dynamic var userID: String = ""
    @objc dynamic var contactID: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var profileImage: String = ""
    @objc dynamic var quote: String = ""
    @objc dynamic var mobileNumber: String = ""
    @objc dynamic var trimmedNumber: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var aboutMe: String = ""
    @objc dynamic var email = ""
    @objc dynamic var isMyContact = false
    @objc dynamic var dateOfBirth = ""
    @objc dynamic var gender = ""

    
    
    @objc dynamic var isBlock = false
    @objc dynamic var oppsiteBlock = false
    
    @objc dynamic var contactPrivacy: ContactPrivacy?
  
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return Keys.userID.key
    }
    
    func mapping(map: Map) {
        userID <- map["Uid"]
        username <- map["UserName"]
        profileImage <- map["Profile"]
        quote <- map["Quote"]
        mobileNumber <- map["MobileNumber"]
        trimmedNumber <- map["TrimMobileNumber"]
        name <- map["Name"]
        aboutMe <- map["Aboutme"]
        isMyContact <- map["isMyContact"]
        isBlock <- map["IsBlock"]
        oppsiteBlock <- map["OppBlock"]
        contactPrivacy <- map["ContactPrivacy"]
        email <- map["EmailAddress"]
        dateOfBirth <- map["DateOfBirth"]
        gender <- map["Gender"]
       
    }
    
    var displayName: String {
        return name.isEmpty ? mobileNumber : name
    }
}

class ContactPrivacy: Object, Mappable {
    
    @objc dynamic var readReceipts = false
    @objc dynamic var status = false
    @objc dynamic var onlineIndicator = false
    @objc dynamic var lastSeen = false
    @objc dynamic var profile = false
    @objc dynamic var about = false
    @objc dynamic var groupAdd = false
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        readReceipts <- map["ReadReceipts"]
        status <- map[Keys.status.key]
        onlineIndicator <- map["OnlineIndicator"]
        lastSeen <- map["LastSeen"]
        profile <- map["Profile"]
        about <- map["About"]
        groupAdd <- map["GroupAdd"]
    }
}
