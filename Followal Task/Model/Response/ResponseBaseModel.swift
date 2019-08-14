//
//  ResponseBaseModel.swift
//  Followal Task
//
//  Created by iMac on 31/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON

class ResponseBaseModel<T: Codable> : Codable {
    var data: T?
    var eventName = ""
    var returnCode = 0
    var returnMsg = ""
    var returnValue = false
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case eventName = "EventName"
        case returnCode = "ReturnCode"
        case returnMsg = "ReturnMsg"
        case returnValue = "ReturnValue"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decode(T.self, forKey: .data)
        eventName = try values.decodeIfPresent(String.self, forKey: .eventName) ?? ""
        returnCode = try values.decodeIfPresent(Int.self, forKey: .returnCode) ?? 0
        returnMsg = try values.decodeIfPresent(String.self, forKey: .returnMsg) ?? ""
        returnValue = try values.decodeIfPresent(Bool.self, forKey: .returnValue) ?? false
    }
}

