//
//  SocketManage.swift
//  followal
//
//  Created by Vivek Gadhiya on 21/01/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.

import Foundation
import SocketIO
import SwiftyJSON
import Alamofire
import RxSwift
import RxCocoa
import ObjectMapper
import MapKit
import CryptoSwift
import RealmSwift
import SDWebImage
import UserNotifications
//import Reachability
struct SocketHelper {
    
    static let manager = SocketManager(socketURL: URL(string: webUrls.baseURL())!,config: [.log(false)])
    static var socket: SocketIOClient!
    
    static func connectSocket() {
        
        socket = manager.defaultSocket
        appDelegte.socket = socket
        guard socket.status != .connected else { return }
        
        guard UserDefaults.standard.bool(forKey: Keys.isUserLogIn()) else {
            return
        }
        
        socket.removeAllHandlers()
        
        registerHandler()
        socket.connect()
    }
    
    static func disconnectSocket() {
        socket.disconnect()
        socket.removeAllHandlers()
    }
    
    static func registerHandler() {
        
        socket.on(clientEvent: .connect) {data, ack in
        
            print("Socket Connected")
            // print(data)
            
            let req = SocketRegisterRequest()
            req.pushToken = getAccessToken()
            
            let request = RequestBaseModel<SocketRegisterRequest>()
            request.data = req
            request.eventName = webUrls.socketRegister()
            request.accessToken = getAccessToken()
            emitWithAck(param: request, eventName: webUrls.socketRegister(), completion: { (data) in
                let json = JSON(data)
                if json[Keys.returnValue.key].boolValue {
                    
                    appDelegte.isSocketConnected.accept(true)
                    
                    let socket_id = json[Keys.data.key]["SocketId"].stringValue
                  //  let jobFormApiUpdate = json[Keys.data.key]["JobFormApiUpdate"].intValue
                    print("SocketID = \(socket_id)")
                    UserDefaults.standard.set(socket_id, forKey: Keys.socket_id())
                  
                //    self.sendAllPendingRequest()
                } else{
                    
                }
            })
        }
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            self.connectSocket()
            print("Socket disconnected")
            appDelegte.isSocketConnected.accept(false)
        }
        
        socket.on(clientEvent: .error) { (data, ack) in
            print("Socket error")
            self.connectSocket()
            appDelegte.isSocketConnected.accept(false)
        }
        
        socket.on("res") { (data, ack) in
            
            let json = JSON(data.first!)
            print("From socket \(json["EventName"].stringValue)")
            handleEvent(json: json,isDecryptionNeed: false)
        }
        
    }
    
//    static func sendAllPendingRequest() {
//        let itemsToCallRequest = realm.objects(PendingRequest.self)
//
//        for item in itemsToCallRequest {
//            DispatchQueue.global().async {
//                SocketHelper.emitWithAck(param: item.request.convertToDictionary()!) { (data) in
//                    print(data)
//                }
//            }
//        }
//        try? realm.write {
//            realm.delete(itemsToCallRequest)
//        }
//    }
    
    static func handleEvent(json: JSON, isDecryptionNeed:Bool) {
        var dataDict = JSON()
        //        if isDecryptionNeed {
        //            let responseString = SocketHelper.decryptReponse(strToDecrypt: (json.stringValue).replacingOccurrences(of: "SUCCESS:", with: ""))
        //            if responseString != "" {
        //                dataDict = JSON(responseString.convertToDictionary()!)
        //            }
        //        } else{
        dataDict = json
        //        }
        
        let eventName = dataDict["EventName"].stringValue
        let data = dataDict[Keys.data.key]
        print("eventName : \(eventName),\n data:\(data)")
        if eventName == "SendAssignedTask" {
            if let dataTask = data.dictionaryObject {
                if let task = Mapper<Task>().map(JSON: dataTask) {
                    try! realm.write {
                        realm.add(task, update: true)
                    }
                    TaskHelper.setAllTask()
                    SocketHelper().createLocalNotification(title: "\"\(task.TaskTitle)\" assigned you now", body: task.Description, info: ["message_info":"AssignTask"])
                    TaskHelper.prepareRequestAssignFolder(task.FolderName)
                }
            }
        } else if eventName == "SubTaskStatus" {
            if let dataTask = data.dictionaryObject {
                if let task = Mapper<Task>().map(JSON: dataTask) {
//                    try! realm.write {
//                        realm.add(task, update: true)
//                    }
                   // TaskHelper.setAllTask()
                 //   SocketHelper().createLocalNotification(title: "\"\(task.TaskTitle)\" completed", body: task.Description, info: ["message_info":""])
                    //TaskHelper.prepareRequestAssignFolder(task.FolderName)
                }
            }
          //  SocketHelper().createLocalNotification(title: "\"\(task.TaskTitle)\" completed", body: task.Description, info: ["message_info":""])

        }else if eventName == "AddComment" {
            if dataDict[Keys.returnValue.key].boolValue {
                if let dataUser = dataDict["Data"].dictionaryObject as? [String : Any] {
                    if let comment = Mapper<Comment>().map(JSONObject: dataUser){
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(comment, update: true)
                        }
                        let arrUsers = realm.objects(UserResponseModel.self).filter({$0.UserId == comment.userID})
                        let arrTask = realm.objects(Task.self).filter({$0.TaskLocalId == comment.taskID})

                        let username = arrUsers.count > 0 ? arrUsers[0].UserName : ""
                        let tasktitle = arrTask.count > 0 ? arrTask[0].TaskTitle : ""

                        SocketHelper().createLocalNotification(title: "\(username) has commented on task \(tasktitle)", body: comment.commentText, info: ["message_info":"Comment"])

                    }
                }
            }
        }
        else if eventName == "TaskStatus" {
            if let dataTask = data.dictionaryObject {
                if let task = Mapper<Task>().map(JSON: dataTask) {
                    if task.Reviewer.count > 0 {
                        if task.Reviewer[0].UserId == getUserID() {
                            try! realm.write {
                                realm.add(task, update: true)
                            }
                            SocketHelper().createLocalNotification(title: "\"\(task.TaskTitle)\" is given you for review purpose", body: task.Description, info: ["message_info":""])
                            TaskHelper.prepareRequestAssignFolder(task.FolderName)
                        }
                    }
                   
                }
            }
        }
        
    }
    //MARK:- Local Notification
    func createLocalNotification(title: String, body: String, info: [String: String]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        //  content.userInfo = ["message_detail": info]
        content.sound = .default
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest.init(identifier: UUID.init().uuidString, content: content, trigger: trigger)
        
        // Schedule the notification.
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("We had an error in Local notification: \(error)")
            }
        }
    }
    
//    static func emitWithAckWithoutEncrypt(param: [String : Any], completion: @escaping (Any) -> ()) {
//        print(JSON(param).stringValue)
//        if Rechability.isConnectedToNetwork() {
//            print("Sending data : \(param.toJSONString()!)")
//            if socket.status == .connected {
//                socket.emitWithAck("req", with: [param]).timingOut(after: 0) { (data) in
//                    guard let dataF = (data).first else { return }
//                    let strResponse = dataF as! String
//                    let responseString = SocketHelper.decryptReponse(strToDecrypt: strResponse.replacingOccurrences(of: "SUCCESS:", with: ""))
//                    if responseString != "" {
//                        let result = JSON(responseString.convertToDictionary()!)
//                        if (!result[Keys.returnValue.key].boolValue && result[Keys.returnCode.key].intValue == 502){
//                            SocketHelper.logoutFromApp()
//                        } else{
//                            completion(result)
//                        }
//                        print("responce data : \(result)")
//                        //    completion(result)
//                    }
//                }
//            }
//        }
//    }
   
    static func emitWithAck<T: Codable>(param: T,eventName:String, completion: @escaping ([String:Any]?) -> ()) {
        
        if Rechability.isConnectedToNetwork() {
            if socket.status == .connected {
                let encoder = JSONEncoder()
                let jsonData = try! encoder.encode(param)
                let parameters = try! JSON(data: jsonData).dictionaryObject
                print(parameters)
                socket.emitWithAck("req", with: [parameters as Any]).timingOut(after: 0) { (data) in
                    guard let dataF = (data).first else { return }
                    if dataF != nil {
                        let result = JSON(dataF)
                        if result.count > 0 {
                        if (!result[Keys.returnValue.key].boolValue && result[Keys.returnCode.key].intValue == 502){
                            SocketHelper.logoutFromApp()
                        } else{
                            completion(result.dictionaryObject!)
                        }
                        }
                    }
                }
            } else {
                self.connectSocket()
                let kURL = webUrls.baseURL() + eventName
                ServiceManager().request(url: kURL, inputModel: param) { (response) in
                    if response!.count > 0 {
                        if (!(response![Keys.returnValue.key]! as AnyObject).boolValue && ((response![Keys.returnCode.key]! as AnyObject).intValue == 502)){
                        TaskHelper.logout()
                    } else{
                            completion(response!)
                    }
                  }
                }
                
                
//                ServiceRequest.makeRequest1(url: kURL, method: .post, param: encriptedString) { (jsonData) in
//                    let result = jsonData.dictionaryValue
//                    if result.count > 0 {
//                    if (!result[Keys.returnValue.key]!.boolValue && (result[Keys.returnCode.key]!.intValue == 502)){
//                        SocketHelper.logoutFromApp()
//                    } else{
//                        completion(result)
//                    }
//                    }
//                   // completion(result)
//                }
            }
        } else {
//             let arrayEventsToSkip = ["Event"]
//             if arrayEventsToSkip.contains(eventName) {
//                let pendingRequest =  PendingRequest()
//                pendingRequest.eventName = eventName
//                pendingRequest.request = param.toJSONString() ?? ""
//                try? realm.write {
//                    realm.add(pendingRequest)
//                }
//            }
        }
    }
    
    
    static func logoutFromApp() {
        SocketHelper.disconnectSocket()
        
        // Remove userdefaults
        [Keys.access_token(), Keys.userId(), Keys.user_detail(), Keys.userData(), Keys.isUserLogIn(), Keys.roleType(), Keys.isJobDataFound(), Keys.myProfileDetail(), Keys.multiLoginID(), Keys.isoCode(), Keys.socket_id(), Keys.recentChatCalled()].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
        //Remove all delivered notification
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        
        // Unregister for remote notification
        UIApplication.shared.unregisterForRemoteNotifications()
        // Clear all FileManager files
        FileManagerHelper.clearAllFile()
        // Redirect to Login screen
        
    }
    
    static func getParam(event: String, param: [String : Any]) -> Parameters {
        return [Keys.data.key : param, "EventName" : event, Keys.uniqueId() : multiLoginID(), Keys.token.key : getAccessToken()]
    }
    
   
    
   
    
  
    
    //MARK:- Crypto Swift
   static func encryptRequest(strToEncrypt:String)->String {
        do {
            let aes = try AES(key: Array("QDtaG8TwNb1tIj2Q".utf8), blockMode:CBC(iv: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]) as BlockMode)
            let ciphertext = try aes.encrypt(Array(strToEncrypt.utf8))
            let txt = ciphertext.toBase64()
            return txt ?? ""

        } catch {
            return ""
        }

    }
   static func decryptReponse(strToDecrypt:String)->String {
        do {
            let aes = try AES(key: Array("QDtaG8TwNb1tIj2Q".utf8), blockMode:CBC(iv: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]) as BlockMode)
            let base64 = try strToDecrypt.decryptBase64ToString(cipher: aes)
            return base64
        } catch {
            return ""
        }
    }
}
