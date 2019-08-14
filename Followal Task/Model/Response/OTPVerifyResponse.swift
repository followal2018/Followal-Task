//
//  OTPVerifyResponse.swift
//  Alarm Module
//
//  Created by Vivek Gadhiya on 18/07/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation

struct OTPVerifyResponse: Codable {
    
    var token = ""
    var uid = ""
    
    enum CodingKeys: String, CodingKey {
        case token = "Token"
        case uid = "Uid"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token = try values.decodeIfPresent(String.self, forKey: .token) ?? ""
        uid = try values.decodeIfPresent(String.self, forKey: .uid) ?? ""
    }
}
