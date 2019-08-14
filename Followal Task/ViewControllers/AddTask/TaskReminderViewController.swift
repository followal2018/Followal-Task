//
//  TaskReminderViewController.swift
//  followal
//
//  Created by Vivek Gadhiya on 10/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import SwiftyJSON
import ObjectMapper
import Alamofire
class TaskReminderViewController: UIViewController {
    
    //MARK:- Outlet
    @IBOutlet weak var txtDueDate: UITextField!
    @IBOutlet weak var txtRemindDate: UITextField!
    @IBOutlet weak var txtRepeatReminder: UITextField!
    @IBOutlet weak var txtStopRemider: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    var dueDate : Date!
    var startDate : Date!
    var stopDate : Date!
    var repeatReminderDate : Date!
    var selectedDays: [DateComponents] = []
    var customData: [String : Any] = [:]
    var isCustomRepeat = false
    var repeatIntervalType:RepeatIntervalType = .never
    var strRepeat:String = ""

    var arryOfDays: [Int] = []
    var arrayOfMonths: [Int] = []
    
    //MARK:- Variable
    var disposeBag = DisposeBag()
    var remiderCompletion = PublishSubject<()>()
    var parameters:[String:Any]!
    var arrayImages = [UIImage]()
    var isUpdate = false

    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormats.DFyyyyMMddhhmma
        txtDueDate.text = dateFormatter.string(from: dueDate)
        if stopDate != nil {
            txtStopRemider.text = dateFormatter.string(from: stopDate)
        }
        txtRepeatReminder.text = strRepeat
        [txtDueDate, txtRemindDate, txtRepeatReminder, txtStopRemider].forEach { $0?.delegate = self }
         self.title = Localization.setAssignReminder.key
        btnAdd.setTitle(isUpdate ? "Update":"Add", for: .normal)
        btnAdd.rx.tap.subscribe(onNext: {
                     self.addTask()
                   }).disposed(by: disposeBag)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        btnAdd.setGradientBackground()

    }
}


//MARK:- UITextFieldDelegate
extension TaskReminderViewController: UITextFieldDelegate {
    
    func  textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtDueDate {
            setDatePicker(on: txtDueDate, dateFormat: DateFormats.DFyyyyMMddhhmma)
        } else if textField == txtRemindDate {
            setDatePicker(on: self.txtRemindDate, dateFormat: DateFormats.DFyyyyMMddhhmma)
        } else if textField == txtRepeatReminder {
            let vc = board.task.repeatAlarmViewController()!
            vc.delegate = self
            let days = selectedDays.map { $0.weekday! }
            vc.isCustomRepeat = isCustomRepeat
            vc.customData = self.customData
            vc.selectedDayIndex = days.isEmpty ? [0] : days
            vc.selectedDays.subscribe(onNext: { (components) in
                self.customData = [:]
                self.isCustomRepeat = false
                vc.navigationController?.popViewController(animated: true)
                print(components)
                self.selectedDays = components
                if components.isEmpty {
                    self.txtRepeatReminder.text = "Never"
                    self.repeatIntervalType = .never
                } else {
                    let daysName = components.map( { Calendar.current.standaloneWeekdaySymbols[$0.weekday! - 1].prefix(3) })
                    print(daysName)
                    self.txtRepeatReminder.text = "Repeat on \(daysName.joined(separator: ", "))"
                    
                }
            }).disposed(by: disposeBag)
            vc.customDataObserver.subscribe(onNext: { (customData) in
                self.isCustomRepeat = true
                vc.navigationController?.popViewController(animated: true)
                self.customData = customData
                self.txtRepeatReminder.text = self.setCustomData(customData)
            }).disposed(by: disposeBag)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if textField == txtStopRemider {
            setDatePicker(on: txtStopRemider, dateFormat: DateFormats.DFyyyyMMddhhmma)
        }
        return false
    }
    func setCustomData(_ customData: [String : Any]) -> String {
        if let type = customData["type"] as? String {
            print(type)
            if type == "Day" { //Handle Custom Day
                if let interval = customData["value"] as? Int {
                    let day = interval / 86400
                    if day == 1 {
                       return "Repeat at Everyday"
                    } else {
                        return "Repeat at Every \(day) Days"
                    }
                }
            } else if type == "Week" { // Handle Custom Week
                if let components = customData["value"] as? [DateComponents] {
                    let daysName = components.map( { Calendar.current.standaloneWeekdaySymbols[$0.weekday! - 1].prefix(3) })
                    print(daysName)
                    return "Repeat on \(daysName.joined(separator: ", "))"
                }
            } else if type == "Month" { // Handle Custom Month
                if let components = customData["value"] as? [DateComponents] {
                    let daysName = components.compactMap( { $0.day }).map { $0.description }
                    print(daysName)
                    return "Monthly - \(daysName.joined(separator: ", "))"
                }
            } else if type == "Year" {
                if let components = customData["value"] as? [DateComponents] {
                    let daysName = Set(components.compactMap( { $0.month }).map { ArrayOfMonths[$0 - 1] })
                    print(daysName)
                    return "Yearly - \(daysName.joined(separator: ", "))"
                }
            }
        }
        return ""
    }
    
    func setDatePicker(on textField: UITextField, dateFormat: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let vc = board.task.selectTimeViewController()!
        vc.datePicketMode = .dateAndTime
        vc.currentDate = dateFormatter.date(from: textField.text!)
        vc.selectedDate.subscribe(onNext: { (date) in
            print(date)
            if textField == self.txtRemindDate {
                self.repeatReminderDate = date
            } else if textField == self.txtDueDate {
                self.dueDate = date
            } else if textField == self.txtStopRemider {
                self.stopDate = date
            }
            textField.text = dateFormatter.string(from: date)
        }).disposed(by: disposeBag)
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
    func isValidAllFields()->Bool {
        var isValid = false
        if dueDate.compare(startDate) == .orderedAscending {
            showToast("Please select due date is greater than start date")
        } else if stopDate != nil {
            if stopDate.compare(dueDate) == .orderedAscending {
                showToast("Please select stop date is greater than due date")
            } else {
                isValid = true
            }
        } else if repeatReminderDate != nil {
            if repeatReminderDate.compare(dueDate) == .orderedDescending {
                showToast("Please select repeat remind date is less than due date")
            } else {
                isValid = true
            }
        }
//        else if txtRepeatReminder.text!.isEmpty {
//            showToast("Please select repeat reminder date")
//        }
        else {
            isValid = true
        }
        return isValid
    }
    
    func addTask() {
        if !isValidAllFields() {
            return
        }
        self.startLoader()
        var url = webUrls.baseURL() + webUrls.createTask()
        if isUpdate {
            url = webUrls.baseURL() + webUrls.updateTask()
        }
        let stopReminder = stopDate != nil ? "\(stopDate.millisecondsSince1970)" : ""

        if let arrAssign = parameters["Assigned"] as? [[String:Any]]{
           if let dict = arrAssign.first {
                var dictAssign = dict
                        let dictShedule:[String:Any] = ["RepeatReminderDate" : "\(repeatReminderDate.millisecondsSince1970)",
                                                            "DueDateAndTime":     "\(dueDate.millisecondsSince1970)",
                                                            "IntervalType": repeatIntervalType.textValue,
                                                            "IntervalDays":arryOfDays,
                                                            "IntervalMonths":arrayOfMonths,
                                                            "StopReminder" : stopReminder]
                dictAssign["Schedule"] = dictShedule
                parameters["Assigned"] = [dictAssign]

            }
        }
        if let dataTask = parameters as? [String : Any] {
            if let task = Mapper<Task>().map(JSON:dataTask) {
                try! realm.write {
                    realm.add(task, update: true)
                }
            }
        }
        print("Params")
            print(parameters)
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    //    multipartFormData.append(imageData, withName: "user", fileName: "user.jpg", mimeType: "image/jpeg")
                    
                    for (key, value) in self.parameters {
                        if let value = value as? String {
                            multipartFormData.append((value).data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                        } else if let value1 = value as? Array<Any> {
                            multipartFormData.append((self.getData(from: value1)!), withName: key)
                        } else if let value2 = value as? Dictionary<String, Any> {
                            multipartFormData.append((self.getData(from: value2)!), withName: key)
                            
                            
                        }
                    }
                    for i in 0..<self.arrayImages.count {
                        //if let img = tempImg {
                        let imgData = self.arrayImages[i].jpegData(compressionQuality: 0.7)
                        multipartFormData.append(imgData!, withName: "Files", fileName:arc4random().description+"_image.png" , mimeType: "image/png")
                        // MultipartFormData.append(UIImageJPEGRepresentation(UIImage(named: "1.png")!, 1)!, withName: "photos[2]", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
                    }
                    
            }, to: url,headers: getGeneralAPIHeader()) { (result) in
                self.dismissLoader()
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        guard let response = response.value else {
                            showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: self)
                            return
                        }
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let jsonData = JSON(response)
                            if jsonData[Keys.returnValue.key].boolValue {
                                if let dataTask = jsonData["Data"].dictionaryObject {
                                    if let task = Mapper<Task>().map(JSON: dataTask) {
                                        try realm.write {
                                            task.IsDone = .pending
                                            realm.add(task, update: true)
                                        }
                                        TaskHelper.setAllTask()
                                        self.navigationController?.popToRootViewController(animated: true)
                                    }
                                    
                                }
                            } else{
                                showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: self)
                            }
                        } catch let error {
                            showAlertView(with: error.localizedDescription, viewController: self)
                        }
                    }
                case .failure(let encodingError): break
                print(encodingError)
                }
            }
        
    }
    
}
extension TaskReminderViewController: RepeatAlarmViewControllerDelegate {
    func didSelectRepeatReminder(_ str:String,type:RepeatIntervalType, days:[Int], months:[Int]){
        txtRepeatReminder.text = str
        arryOfDays.removeAll()
        arrayOfMonths.removeAll()
        repeatIntervalType = type
        arryOfDays = days.sorted()
        if repeatIntervalType == .year {
            arrayOfMonths = months.sorted()
        }
    }
}
