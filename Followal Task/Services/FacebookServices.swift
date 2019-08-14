//
//  FacebookServices.swift
//  Alarm Module
//
//  Created by iMac on 04/04/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import SwiftyJSON
//import FBSDKCoreKit
//import FBSDKLoginKit
//
//struct FacebookService {
//
//    func login(_ from: UIViewController, completion: @escaping (Bool) -> ()) {
//        let loginPermission = FBSDKLoginManager()
//        loginPermission.logIn(withReadPermissions: ["public_profile","email"], from: from, handler: { (result, error) in
//
//            guard error == nil else { return }
//
//            if(result?.isCancelled)! {
//                print("Login Cancelled")
//            } else {
//                print("Login Success")
//                print("result:=\(result)")
//                if (result?.token) != nil {
//                    completion(true)
//                }
//            }
//        })
//    }
//
//    func getFBResult(completion: @escaping (JSON) -> ()) {
//
//        guard FBSDKAccessToken.current() != nil else { return }
//
//        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender, link"]).start(completionHandler: { (connection, result, error) -> Void in
//
//            guard error == nil else { return }
//
//            if let resultData = result {
//                let json = JSON(resultData)
//                let profileUrl = json["picture"]["data"]["url"].string
//                completion(json)
//
//            }
//        })
//    }
//}
//
