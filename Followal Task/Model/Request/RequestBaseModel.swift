//
//  RequestBaseModel.swift
//  Followal Task
//
//  Created by iMac on 31/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON

class RequestBaseModel<T: Codable> : Codable {
    var data: T?
    var eventName = ""
    var accessToken = ""

    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case eventName = "EventName"
        case accessToken = "Token"

    }
}
