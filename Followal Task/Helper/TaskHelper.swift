//
//  swift
//  task Module
//
//  Created by Vivek Gadhiya on 06/07/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import UserNotifications
import ObjectMapper
import RealmSwift
import SwiftyJSON
extension Date {
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
}

class TaskHelper {
    
    static func setAllTask() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().cleanRepeatingNotifications()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let realm = try! Realm()
        let tasks = realm.objects(Task.self).toArray()
        print("task Object \(tasks.count)")
        let date = Date()
        for task in tasks {
            if task.IsDone == .pending{
                prepareTask(task, dateToday: date)
            }
        }
        checkIfRequestAvailable(date: date)
    }
    
    static func checkIfRequestAvailable(date:Date) {
        for i in 1...365 {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.getPendingNotificationRequests { (requests) in
                if requests.count < 64 {
                    DispatchQueue.main.sync {
                        let realm = try! Realm()
                        let tasks = realm.objects(Task.self).toArray()
                        let date1Added = date.addingTimeInterval(TimeInterval(84600*i))
                        print("NextDate:\(date1Added)\nRequest Count:\(requests.count)")
                        
                        for task in tasks {
                            prepareTask(task, dateToday: date1Added)
                        }
                    }
                    // checkIfRequestAvailable(date: date.addingTimeInterval(84600))
                } else {
                    return
                }
            }
        }
    }
    
    static func prepareTask(_ task: Task, dateToday:Date) {
        let schedule = task.Schedule!
        let startDate = Date(milliseconds: Int64(schedule.StartDate)!)
        let dueDate = Date(milliseconds: Int64(schedule.DueDateAndTime)!)
        //   let dateAfter2Hour = Date().addingTimeInterval(7200)
        let dateAfterDay = dateToday.addingTimeInterval(86400)
        
        if startDate.isBetween(date: dateToday, andDate: dateAfterDay) {
            self.setStartDateNotification(task)
        }
        if dueDate.isBetween(date: dateToday, andDate: dateAfterDay) {
            self.setDueDateNotification(task)
        }
        if schedule.RepeatReminderDate != "" {
            let remindDate = Date(milliseconds: Int64(schedule.RepeatReminderDate)!)
            if remindDate.isBetween(date: dateToday, andDate: dateAfterDay) {
                self.setRemindDateNotification(task)
            }
            
        }
        if schedule.StopReminder != "" {
            let stopDate = Date(milliseconds: Int64(schedule.StopReminder)!)
            if dateToday.isBetween(date: dueDate, andDate: stopDate) {
                setAllNotifications(task, dateToday)
            }
        } else {
            setAllNotifications(task, dateToday)
        }
        
    }
    
    static func setAllNotifications(_ task:Task, _ todayDate:Date) {
        let taskID = task.TaskLocalId
        let schedule = getScheduleFromTask(task)
        
        let dueDate = Date(milliseconds: Int64(schedule.DueDateAndTime)!)
        let dueDateComponent = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute,.second], from: dueDate)
        
        if schedule.IntervalType == .day { // Schedule Custom Day Notification
            let delay30date = Calendar.current.date(byAdding: .day, value: 31, to: Date())!
            if todayDate < delay30date {
                for cmp in schedule.IntervalDays.toArray() {
                    self.fireIntervalLocalNotification(task, identifier: "\(taskID)_\(UUID.init().uuidString)", interval: cmp, isRepeat: true)
                }
            }
        } else if schedule.IntervalType == .week { // Schedule Custom Day Notification
            
            let delay7date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            if todayDate < delay7date {
                let selectedDays = schedule.IntervalDays.toArray().compactMap { (value) -> DateComponents? in
                    if Calendar.current.component(.weekday, from: todayDate) == value && todayDate.onlyTime() < dueDate.onlyTime() {
                        var component = DateComponents()
                        component.weekday = value
                        component.hour = dueDateComponent.hour
                        component.minute = dueDateComponent.minute
                        return component
                    }
                    return nil
                }
                for cmp in selectedDays {
                    self.fireLocalNotification(task, identifier: "\(taskID)_\(UUID.init().uuidString)", component: cmp, isRepeat: true)
                    
                }
            }
        } else if schedule.IntervalType == .month { // Schedule Custom Day Notification
            let delay30date = Calendar.current.date(byAdding: .day, value: 31, to: Date())!
            
            if todayDate < delay30date {
                let selectedDays = schedule.IntervalDays.toArray().compactMap { (value) -> DateComponents? in
                    if Calendar.current.component(.month, from: todayDate) == value && todayDate.onlyTime() < dueDate.onlyTime() {
                        var component = DateComponents()
                        component.day = value
                        component.hour = dueDateComponent.hour
                        component.minute = dueDateComponent.minute
                        return component
                    }
                    return nil
                }
                for cmp in selectedDays {
                    self.fireLocalNotification(task, identifier: "\(taskID)_\(UUID.init().uuidString)", component: cmp, isRepeat: true)
                    
                }
            }
        } else if schedule.IntervalType == .year { // Schedule Custom Day Notification
            var selectedDays = [DateComponents]()
            let delay12Monthdate = Calendar.current.date(byAdding: .month, value: 12, to: Date())!
            if todayDate < delay12Monthdate {
                
                for day in schedule.IntervalDays.toArray() {
                    selectedDays.append(contentsOf: schedule.IntervalMonths.toArray().compactMap { (value) -> DateComponents? in
                        if Calendar.current.component(.month, from: todayDate) == value && todayDate.onlyTime() < dueDate.onlyTime() {
                            var component = DateComponents()
                            component.month = value
                            component.day = day
                            component.hour = dueDateComponent.hour
                            component.minute = dueDateComponent.minute
                            return component
                        }
                        return nil
                    })
                }
                for cmp in selectedDays {
                    self.fireLocalNotification(task, identifier: "\(taskID)_\(UUID.init().uuidString)", component: cmp, isRepeat: true)
                }
            }
        }
        
    }
    
    
    
    static func fireIntervalLocalNotification(_ task: Task, identifier: String, interval: Int, isRepeat: Bool) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { (requests) in
            if requests.count < 64 {
                DispatchQueue.main.sync {
                    print("Notification count \(requests.count)")
                    let content = UNMutableNotificationContent()
                    content.title = task.TaskTitle
                    content.subtitle = "Your due date is gone."
                    content.sound = .default
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval*84600), repeats: true)
                    let request = UNNotificationRequest(identifier: "\(identifier)", content: content, trigger: trigger)
                    print("Title\(task.TaskTitle) Due Date Gone: \(trigger)")
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print("Error adding notification : " + error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    static func fireLocalNotification(_ task: Task, identifier: String, component: DateComponents, isRepeat: Bool) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { (requests) in
            if requests.count < 64 {
                DispatchQueue.main.sync {
                    print("Notification count \(requests.count)")
                    let content = UNMutableNotificationContent()
                    content.title = task.TaskTitle
                    content.subtitle = "Your due date is gone."
                    content.sound = .default
                    let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: isRepeat)
                    let request = UNNotificationRequest(identifier: "\(identifier)", content: content, trigger: trigger)
                    print("Title\(task.TaskTitle) Due Date Gone: \(trigger)")
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print("Error adding notification : " + error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    static func getDifference(startDate: Date, toDate: Date) -> Double {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "hh:mm a"
        let strDate = dateFmt.string(from: toDate)
        let date = dateFmt.date(from: strDate)!.toLocal()
        print(date)
        return startDate.timeIntervalSince(date)
    }
    
    static func removeNotifications(for task: Task) {
        let taskID = task.TaskLocalId
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            let ids = requests.filter({ $0.identifier.contains(taskID) }).map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        })
    }
    
    static func getScheduleFromTask(_ task:Task)->ScheduleTask {
        var schedule = task.Schedule!
        if task.UserId != getUserID() {
            if let assigner = task.Assigned.toArray().first {
                if assigner.UserId == getUserID() {
                    schedule = assigner.Schedule!
                }
            }
        }
        return schedule
    }
    
    static func setRemindDateNotification(_ task:Task) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { (requests) in
            if requests.count < 64 {
                DispatchQueue.main.sync {
                    print("Notification count \(requests.count)")
                    let content = UNMutableNotificationContent()
                    content.title = task.TaskTitle
                    
                    content.subtitle = "Just reminding you to complete task before due date"
                    content.sound =  .default
                    let schedule = getScheduleFromTask(task)
                    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: Date(milliseconds: Int64(schedule.RepeatReminderDate)!))
                    print("Title:\(task.TaskTitle) StartDate: \(triggerDate)")
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    let request = UNNotificationRequest(identifier: "\(task.TaskLocalId)_\(UUID.init().uuidString)", content: content, trigger: trigger)
                    
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print("Error adding notification : " + error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    static func setStartDateNotification(_ task:Task ) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { (requests) in
            if requests.count < 64 {
                DispatchQueue.main.sync {
                    print("Notification count \(requests.count)")
                    let content = UNMutableNotificationContent()
                    content.title = task.TaskTitle
                    
                    content.subtitle = "Start this task now"
                    content.sound =  .default
                    var schedule = getScheduleFromTask(task)
                    
                    if schedule.StopReminder != "" {
                        content.userInfo["endDate"] = Date(milliseconds: Int64(schedule.StopReminder)!)
                    }
                     schedule = task.Schedule!

                    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: Date(milliseconds: Int64(schedule.StartDate)!))
                    print("Title:\(task.TaskTitle) StartDate: \(triggerDate)")
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    let request = UNNotificationRequest(identifier: "\(task.TaskLocalId)_\(UUID.init().uuidString)", content: content, trigger: trigger)
                    
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print("Error adding notification : " + error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    
    static func setDueDateNotification(_ task:Task) {
        let notificationCenter = UNUserNotificationCenter.current()
        UIApplication.shared.scheduledLocalNotifications?.count
        notificationCenter.getPendingNotificationRequests { (requests) in
            if requests.count < 64 {
                
                DispatchQueue.main.sync {
                    print("Notification count \(requests.count)")
                    let content = UNMutableNotificationContent()
                    content.title = task.TaskTitle
                    
                    content.subtitle = "Due date is today"
                    content.sound =  .default
                    let schedule = getScheduleFromTask(task)
                    
                    if schedule.StopReminder != "" {
                        content.userInfo["endDate"] = Date(milliseconds: Int64(schedule.StopReminder)!)
                    }
                    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: Date(milliseconds: Int64(schedule.DueDateAndTime)!))
                    print("Title:\(task.TaskTitle) DueDate: \(triggerDate)")
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    let request = UNNotificationRequest(identifier: "\(task.TaskLocalId)_\(UUID.init().uuidString)", content: content, trigger: trigger)
                    
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print("Error adding notification : " + error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    //MARK:- Login/Logout
    static func login() {
        SocketHelper.connectSocket()
        let viewController = board.task.taskListVC()!
        let navVC = UINavigationController(rootViewController: viewController)
        navVC.isNavigationBarHidden = false
        UIApplication.shared.keyWindow?.rootViewController = navVC
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    
    static func logout() {
        SocketHelper.disconnectSocket()
        
        [Keys.isUserLogIn(), Keys.access_token(),  Keys.registerData()].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        try? realm.write {
            
            realm.deleteAll()
        }
        GIDSignIn.sharedInstance()?.signOut()
        let viewController = board.main.loginVC()!
        let navVC = UINavigationController(rootViewController: viewController)
        navVC.isNavigationBarHidden = true
        UIApplication.shared.keyWindow?.rootViewController = navVC
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    static func getFolderRequest(_ folderName:String) -> FolderRequest {
        
        let req = FolderRequest()
        req.folderName = folderName
        req.folderID =  UUID.init().uuidString
        return req
    }
    
    
    static func createDefaultAllFolder() {
        
        var arrFolders = ["Inbox","All","Assign","Completed","Review"]
        let arrayRemainingFolder = Array(realm.objects(FolderResponseModel.self).filter({arrFolders.contains($0.FolderName)})).map({$0.FolderName})
        arrFolders.removeAll(where: { arrayRemainingFolder.contains($0)})
        for folderName in arrFolders {
            let request = RequestBaseModel<FolderRequest>()
            request.data = getFolderRequest(folderName)
            request.eventName = "CreateFolder"
            request.accessToken = getAccessToken()
            
            self.createFolder(request: request)
        }
        
    }
    
    static func prepareRequestAssignFolder(_ folderId:String) {
        let req = DeleteFolderRequest()
        req.folderID = folderId
        let request = RequestBaseModel<DeleteFolderRequest>()
        request.data = req
        request.eventName = "GetFolderData"
        request.accessToken = getAccessToken()
        getAssignfolder(request: request)
    }
    
    
    //MARK:- API Call
    
    static func getAssignfolder(request: RequestBaseModel<DeleteFolderRequest>) {
        
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: appDelegte.window!.rootViewController!)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
                    if let dataUser = jsonData["Data"].dictionaryObject {
                        let folder = Mapper<FolderResponseModel>().map(JSONObject: dataUser)
                        let realm = try! Realm()
                        try realm.write {
                            realm.add(folder!, update: true)
                        }
                    }
                } else {
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: appDelegte.window!.rootViewController!)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: appDelegte.window!.rootViewController!)
            }
            
        }
    }
    
    
    static func createFolder(request: RequestBaseModel<FolderRequest>) {
        
        
        // let url = webUrls.baseURL() + webUrls.createFolder()
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
                    if let dataUser = jsonData["Data"].dictionaryObject {
                        let folder = Mapper<FolderResponseModel>().map(JSONObject: dataUser)
                        let realm = try! Realm()
                        try realm.write {
                            realm.add(folder!, update: true)
                        }
                    }
                } else {
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: appDelegte.window!.rootViewController!)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: appDelegte.window!.rootViewController!)
            }
        }
    }
    
    static func subTaskStatus(task:Task, subtask:SubTask, status:Int) {
        let req = SubtaskStatusRequest()
        req.TaskLocalId = task.TaskLocalId
        req.SubtaskId = subtask.SubtaskId
        req.IsDone = status

        let request = RequestBaseModel<SubtaskStatusRequest>()
        request.data = req
        request.eventName = "SubTaskStatus"
        request.accessToken = getAccessToken()
        
        // let url = webUrls.baseURL() + webUrls.createFolder()
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                return
            }
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
//                    if let dataUser = jsonData["Data"].dictionaryObject {
//                        let folder = Mapper<SubTask>().map(JSONObject: dataUser)
//                        let realm = try! Realm()
//                        try realm.write {
//                            realm.add(folder!, update: true)
//                        }
//                    }
                } else {
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: appDelegte.window!.rootViewController!)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: appDelegte.window!.rootViewController!)
            }
        }
    }
    
    
    static func taskStatus(task:Task, status:Int) {
        let req = TaskStatusRequest()
        req.TaskLocalId = task.TaskLocalId
        req.IsDone = status
        
        let request = RequestBaseModel<TaskStatusRequest>()
        request.data = req
        request.eventName = "TaskStatus"
        request.accessToken = getAccessToken()
        
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                return
            }
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
                    //                    if let dataUser = jsonData["Data"].dictionaryObject {
                    //                        let folder = Mapper<SubTask>().map(JSONObject: dataUser)
                    //                        let realm = try! Realm()
                    //                        try realm.write {
                    //                            realm.add(folder!, update: true)
                    //                        }
                    //                    }
                } else {
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: appDelegte.window!.rootViewController!)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: appDelegte.window!.rootViewController!)
            }
        }
    }
}
