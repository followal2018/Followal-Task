//
//  OtpVerifyRequestModel.swift
//  Alarm Module
//
//  Created by Vivek Gadhiya on 18/07/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation

class OtpVerifyRequest: Codable {
    
    var trimMobileNumber = ""
    var otp = ""
    var pushToken = ""
    var deviceType = ""
    
    enum CodingKeys: String, CodingKey {
        case trimMobileNumber = "TrimMobileNumber"
        case otp = "Otp"
        case pushToken = "PushToken"
        case deviceType = "DeviceType"
    }
}
