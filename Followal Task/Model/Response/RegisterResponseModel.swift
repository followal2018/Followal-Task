//
//  MyProfile.swift
//  Alarm Module
//
//  Created by Vivek Gadhiya on 17/07/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON

struct RegisterResponseModel: Codable {

    var UserName: String?
    var _id: String?
    var SocketId: String?
    var IsActive:Bool?
    var Token: String?
    var PushToken: String?
    var EmailAddress: String?
    var DeviceType: String?
    var AppVersion: String?
    var IsLogin:Bool?
    var IsVerify:Bool?
    var Profile: String?
    var UserLoginType: String?
    var GoogleId: String?
    var MagicId: String?
    var LastSeenStatus: String?
    var UserGroup:[String]?
    var UpdateDate: String?
    var CreateDate: String?
    var ReferralToken : String?

}
