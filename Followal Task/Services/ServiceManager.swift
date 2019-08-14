//
//  ServiceManager.swift
//  Alarm Module
//
//  Created by iMac on 05/04/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CodableAlamofire


struct ServiceManager {
    
    func requestService(withURL: String, method: HTTPMethod, param: [String:Any], completion: @escaping (JSON?) -> Void) {

        Alamofire.request(withURL, method: method, parameters: param, encoding: JSONEncoding.default, headers: getGeneralAPIHeader()).responseJSON { (response) in
            print(response)
            switch response.result {
            case .success(_):
                let jsonData = JSON(response.result.value!)
                
                self.checkValidUser(response: response.result.value!)
                completion(jsonData)
                
            case .failure(_):
                print(response.error!.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func request<T: Codable>(url: String, inputModel: T, completion: @escaping ([String : Any]?) -> ()) {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(inputModel)
    
        var request = URLRequest(url: url.toURL()!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(getAccessToken(), forHTTPHeaderField: "X-Authorization")
        request.httpBody = jsonData
        

        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case .success(let value):
                print ("finish \(response)")
                let json = JSON(value)
                print(json)
                self.checkValidUser(response: value)
                completion(value as? [String:Any] )


            case .failure(_): break
                showAlertView(with: response.error?.localizedDescription ?? "", viewController: UIApplication.shared.keyWindow?.rootViewController ?? UIViewController())
                //completion()
            }
        }
    }
    

  
    
 
    
    func checkValidUser(response: Any) {
        let json = JSON(response)
        if json["ReturnCode"].intValue == 403 {
            TaskHelper.logout()
        }
    }
    

}
