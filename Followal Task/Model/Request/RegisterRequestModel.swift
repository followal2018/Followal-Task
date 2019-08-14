//
//  RegisterRequestModel.swift
//  Alarm Module
//
//  Created by Vivek Gadhiya on 17/07/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON


class RegisterRequest : Codable {
    
    var emailAddress = ""
    var profile = ""
    var userName = ""
    var userLoginType = ""
    var pushToken = ""
    var googleId = ""
    var deviceType = ""
    var appVersion = ""
    var referralIds = ""
    var password = ""
    enum CodingKeys: String, CodingKey {
        case emailAddress = "EmailAddress"
        case profile = "Profile"
        case userName = "UserName"
        case userLoginType = "UserLoginType"
        case pushToken = "PushToken"
        case googleId = "GoogleId"
        case deviceType = "DeviceType"
        case appVersion = "AppVersion"
        case referralIds = "ReferralIds"
        case password = "Password"

    }
}

class SocketRegisterRequest : Codable {
    var pushToken = ""
    enum CodingKeys: String, CodingKey {
        case pushToken = "Token"
    }
}

