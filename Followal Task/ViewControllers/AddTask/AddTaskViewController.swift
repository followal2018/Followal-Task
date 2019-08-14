//
//  AddTaskViewController.swift
//  followal
//
//  Created by Vivek Gadhiya on 08/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DKImagePickerController
import Alamofire
import SwiftyJSON
import ObjectMapper
import RealmSwift


class AddTaskViewController: UIViewController {
    
    //MARK:- Outlet
    @IBOutlet weak var controls: AddTaskControls!
    
    //MARK:- Variables
    var subTasks = BehaviorRelay<[CreateSubTask]>(value: [])
    var arrUpdatesubTasks = BehaviorRelay<[CreateSubTask]>(value: [])

    var isEditMode = false
    var task: Task!
    var arrayImages = [UIImage]()
    var arrayUpdateImages = [UIImage]()

    var selectedFolder: FolderResponseModel?
    var arrAssigner = BehaviorRelay<[AssignUserResponseModel]>(value: [])
    var arrReviewer = BehaviorRelay<[UserResponseModel]>(value: [])
    var startDate:Date!
    var dueDate:Date!
    var RepeatDate:Date!
    var stopDate:Date!
    var isAssigner = false
    var selectedDays: [DateComponents] = []
    var customData: [String : Any] = [:]
    var isCustomRepeat = false
    let disposeBag = DisposeBag()
    var repeatIntervalType:RepeatIntervalType = .never
    var arryOfDays: [Int] = []
    var arrayOfMonths: [Int] = []
    var addNewTask = Task()
    
    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        controls.setupUI()
        setupUI()
        setObserver()
        if isEditMode {
            setDetai(task)
            //subTasks.accept(task.SubTask.toArray())
//            assignUsers.accept(task.contacts.toArray())
//            reviewer.accept(task.reviewer.toArray())
//            supporters.accept(task.supporter.toArray())
        }
    }
    
    
    func setDetai(_ task: Task) {
        controls.txtTitle.text = task.TaskTitle
        controls.txtDescription.text = task.Description
        if let folder = realm.objects(FolderResponseModel.self).filter({$0.FolderId == task.FolderName}).first {
            controls.txtFolder.text = folder.FolderName
            selectedFolder = folder
        }
        startDate = Date(milliseconds: Int64(task.Schedule.StartDate)!)
        dueDate = Date(milliseconds: Int64(task.Schedule.DueDateAndTime)!)
        controls.txtStartDate.text = startDate.datePhrasedate(withFormat: DateFormats.DFyyyyMMddhhmma)
        controls.txtDueDate.text = dueDate.datePhrasedate(withFormat: DateFormats.DFyyyyMMddhhmma)
        if task.Schedule.StopReminder == "" || task.Schedule.StopReminder == "Never" {
            controls.txtStopRemider.text = "Never"
        } else{
            stopDate = Date(milliseconds: Int64(task.Schedule.StopReminder)!)
            controls.txtStopRemider.text = stopDate.datePhrasedate(withFormat: DateFormats.DFyyyyMMddhhmma)
        }
        repeatIntervalType = task.Schedule.IntervalType
        if repeatIntervalType == .day || repeatIntervalType == .month || repeatIntervalType == .week {
            arryOfDays = task.Schedule.IntervalDays.toArray()
        } else{
            arryOfDays = task.Schedule.IntervalDays.toArray()
            arrayOfMonths = task.Schedule.IntervalMonths.toArray()
        }
        controls.txtRepeatReminder.text = getRepeatReminder(task.Schedule)
        for subTask in task.SubTask.toArray() {
            let createSubtask = CreateSubTask()
            createSubtask.Task = subTask.Task
            createSubtask.IsDone = subTask.IsDone.intValue
            self.subTasks.acceptAppending(createSubtask)
           
        }
        for assigner in task.Assigned.toArray() {
           self.arrAssigner.acceptAppending(assigner)
             self.controls.tblAssignUser.reloadData()
        }
        for reviewer in task.Reviewer.toArray() {
            self.arrReviewer.acceptAppending(reviewer)
            self.controls.tblReviewer.reloadData()
        }
        for file in task.Files.toArray() {
            file.getImage(completionHandler: { (img) in
                self.arrayImages.append(img)
                 self.controls.collectionView.reloadData()
            })
        }

    }
    //MARK:- Set up UI, Set observer

    func setupUI() {
        self.title = isEditMode ? Localization.editTask.key.localized : Localization.addTask.key.localized
        controls.btnAddTask.setTitle(isEditMode ? Localization.updateTask.key.localized : Localization.addTask.key.localized, for: .normal)
        
        [controls.btnAddReviewer,controls.btnAddFiles,controls.btnAssignToUser].forEach { (button) in
            button?.applyCornerRadiusTwoSide(20.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        [controls.btnAddTask].forEach { (button) in
            button?.setGradientBackground()
            
        }
    }
    
    func setObserver() {
        controls.btnAddTask.rx.tap.subscribe(onNext: {
            self.addTask()
            
        }).disposed(by: controls.disposeBag)
        [controls.txtStartDate, controls.txtDueDate, controls.txtRepeatReminder, controls.txtStopRemider].forEach { $0?.delegate = self }
        controls.btnAddSubTask.rx.tap.subscribe(onNext: {
            if self.controls.txtSubTask.text! != "" {
                let task = CreateSubTask()
                task.Task = self.controls.txtSubTask.text!
                task.IsDone = 0
                task.SubtaskId = UUID.init().uuidString
                self.subTasks.acceptAppending(task)
                if self.isEditMode {
                    self.arrUpdatesubTasks.acceptAppending(task)
                }
                self.controls.txtSubTask.text = ""
            }
           
        }).disposed(by: controls.disposeBag)
        controls.btnBack.rx.tap.subscribe(onNext: {
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: controls.disposeBag)
        
        subTasks.asObservable().bind(to: controls.tblTask.rx.items(cellIdentifier: CellIdentifiers.cell, cellType: SubTaskTableViewCell.self)) { (row, element, cell) in
            cell.lblName.text = element.Task
            cell.btnCheck.isSelected = element.IsDone == 0 ? false : true
            cell.btnCheck.isHidden = true
            cell.btnCheck.rx.tap.subscribe(onNext: {
                self.subTasks.value[row].IsDone =  self.subTasks.value[row].IsDone == 0 ? 1 : 0
                self.controls.tblTask.reloadData()
            }).disposed(by: cell.disposeBag)
            
            cell.btnCancel.rx.tap.subscribe(onNext: {
                self.subTasks.remove(at: row)
                try! realm.write {
                    self.task.SubTask.remove(at: row)
                }
                self.controls.tblTask.reloadData()
            }).disposed(by: cell.disposeBag)
        }.disposed(by: controls.disposeBag)
        
        controls.viewUsers.sort(by: { $0.tag < $1.tag })
        
        arrAssigner.subscribe(onNext: { users in
            self.controls.viewUsers[0].isHidden = users.isEmpty
        }).disposed(by: controls.disposeBag)
        
        arrAssigner.asObservable().bind(to: controls.tblAssignUser.rx.items(cellIdentifier: CellIdentifiers.cell, cellType: TaskAssignTableViewCell.self)) { (row, element, cell) in
                if let user = self.arrReviewer.value.first {
                    if user.UserId == element.UserId {
                        self.showToast("Please choose different person than reviewer")
                        return
                    }
                }
            cell.setDetail(element)
            cell.btnCancel.rx.tap.subscribe(onNext: {
                self.arrAssigner.remove(at: row)
            }).disposed(by: cell.disposeBag)
        }.disposed(by: controls.disposeBag)
        
        arrReviewer.subscribe(onNext: { users in
           self.controls.viewUsers[1].isHidden = users.isEmpty
        }).disposed(by: controls.disposeBag)
        
        arrReviewer.asObservable().bind(to: controls.tblReviewer.rx.items(cellIdentifier: "cell", cellType: TaskAssignTableViewCell.self)) { (row, element, cell) in
            if let user = self.arrAssigner.value.first {
                if user.UserId == element.UserId {
                    self.showToast("Please choose different person than assigner")
                    return
                }
            }
            cell.setDetail(element)
            cell.btnCancel.rx.tap.subscribe(onNext: {
                self.arrReviewer.remove(at: row)
            }).disposed(by: cell.disposeBag)
        }.disposed(by: controls.disposeBag)
        
//        supporters.subscribe(onNext: { users in
//            self.controls.viewUsers[2].isHidden = users.isEmpty
//        }).disposed(by: controls.disposeBag)
//        supporters.asObservable().bind(to: controls.tblSupporter.rx.items(cellIdentifier: "cell", cellType: TaskAssignTableViewCell.self)) { (row, element, cell) in
//            cell.setDetail(element)
//            cell.btnCancel.rx.tap.subscribe(onNext: {
//                self.supporters.remove(at: row)
//            }).disposed(by: cell.disposeBag)
//        }.disposed(by: controls.disposeBag)
    }
    func isValidAllFields()->Bool {
        var isValid = false
        if controls.txtFolder.text!.isEmpty {
            showToast("Please select folder")
        } else if controls.txtTitle.text!.isEmpty {
            showToast("Please enter task title")
        } else if controls.txtStartDate.text!.isEmpty {
            showToast("Please select start date")
        } else if controls.txtDueDate.text!.isEmpty {
            showToast("Please select due date")
        } else if dueDate.compare(startDate) == .orderedAscending {
            showToast("Please select due date is greater than start date")
        } else if stopDate != nil {
            if stopDate.compare(dueDate) == .orderedAscending {
                showToast("Please select stop date is greater than due date")
            }
            else{
                isValid = true
            }
        }
//        else if controls.txtRepeatReminder.text!.isEmpty {
//            showToast("Please select repeat reminder date")
//        }
//        else if controls.txtStopRemider.text!.isEmpty {
//            showToast("Please select stop reminder date")
//        }
//        else if arrAssigner.value.count == 0 {
//            showToast("Please choose one member to assign task")
//        } else if arrReviewer.value.count == 0 {
//            showToast("Please choose one member to review task")
//        }
        else{
            isValid = true
        }
        return isValid
        
    }
    
    
    
    //MARK:- UIbutton Actions
    @IBAction func btnAddFilesTapped(_ sender: UIButton) {
       
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = noOfPhotoSelections
        pickerController.assetType = .allPhotos
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            assets.forEach({ (asset) in
                if let img = asset.originalAsset?.getUIImage() {
                self.arrayImages.append(img)
                    if self.isEditMode {
                        self.arrayUpdateImages.append(img)
                    }
                }
                self.controls.collectionView.reloadData()

            })
        }
        self.present(pickerController, animated: true) {}
    }
   
    @IBAction func btnAddUserTapped(_ sender: UIButton) {
        isAssigner = sender.tag == 100 ? true : false
        let vc = board.task.userAssignVC()!
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setCustomData(_ customData: [String : Any]) {
        if let type = customData["type"] as? String {
            print(type)
            if type == "Day" { //Handle Custom Day
                if let interval = customData["value"] as? Int {
                    let day = interval / 86400
                    if day == 1 {
                        self.controls.txtRepeatReminder.text = "Repeat at Everyday"
                    } else {
                        self.controls.txtRepeatReminder.text = "Repeat at Every \(day) Days"
                    }
                }
            } else if type == "Week" { // Handle Custom Week
                if let components = customData["value"] as? [DateComponents] {
                    let daysName = components.map( { Calendar.current.standaloneWeekdaySymbols[$0.weekday! - 1].prefix(3) })
                    print(daysName)
                    self.controls.txtRepeatReminder.text = "Repeat on \(daysName.joined(separator: ", "))"
                }
            } else if type == "Month" { // Handle Custom Month
                if let components = customData["value"] as? [DateComponents] {
                    let daysName = components.compactMap( { $0.day }).map { $0.description }
                    print(daysName)
                    self.controls.txtRepeatReminder.text = "Monthly - \(daysName.joined(separator: ", "))"
                }
            } else if type == "Year" {
                if let components = customData["value"] as? [DateComponents] {
                    let daysName = Set(components.compactMap( { $0.month }).map { ArrayOfMonths[$0 - 1] })
                    print(daysName)
                    self.controls.txtRepeatReminder.text = "Yearly - \(daysName.joined(separator: ", "))"
                }
            }
        }
    }
}
extension AddTaskViewController: UserListViewControllerDelegate {
    func didSelectUser(_ obj: UserResponseModel) {
        if isAssigner {
            let assignObj = AssignUserResponseModel()
            assignObj.EmailAddress = obj.EmailAddress
            assignObj.UserId = obj.UserId
            assignObj.UserName = obj.UserName
            assignObj.Profile = obj.Profile
            if arrAssigner.value.count > 0 {
                arrAssigner.replace(assignObj, index: 0)}
            else{
                arrAssigner.acceptAppending(assignObj)
            }
        }else{
            if arrReviewer.value.count > 0 {
                arrReviewer.replace(obj, index: 0)}
            else{
                arrReviewer.acceptAppending(obj)
            }
        }
    }
}
extension AddTaskViewController: RepeatAlarmViewControllerDelegate {
    func didSelectRepeatReminder(_ str:String,type:RepeatIntervalType, days:[Int], months:[Int]){
        controls.txtRepeatReminder.text = str
        repeatIntervalType = type
        arryOfDays.removeAll()
        arrayOfMonths.removeAll()
        arryOfDays = days.sorted()
        if repeatIntervalType == .year {
            arrayOfMonths = months.sorted()
        }
    }
}

//MARK:- UITextFieldDelegate
extension AddTaskViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == controls.txtFolder {
            self.showFolderVC()
        } else if textField == controls.txtStartDate {
            setDatePicker(on: controls.txtStartDate, dateFormat: DateFormats.DFyyyyMMddhhmma)
        } else if textField == controls.txtDueDate {
            setDatePicker(on: self.controls.txtDueDate, dateFormat: DateFormats.DFyyyyMMddhhmma)
        } else if textField == controls.txtRepeatReminder {
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
                    self.controls.txtRepeatReminder.text = "Never"
                    self.repeatIntervalType = .never
                    
                } else {
                    let daysName = components.map( { Calendar.current.standaloneWeekdaySymbols[$0.weekday! - 1].prefix(3) })
                    print(daysName)
                    self.controls.txtRepeatReminder.text = "Repeat on \(daysName.joined(separator: ", "))"
                    
                }
            }).disposed(by: disposeBag)
            vc.customDataObserver.subscribe(onNext: { (customData) in
                self.isCustomRepeat = true
                vc.navigationController?.popViewController(animated: true)
                self.customData = customData
                self.setCustomData(customData)
            }).disposed(by: disposeBag)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if textField == controls.txtStopRemider {
            setDatePicker(on: controls.txtStopRemider, dateFormat: DateFormats.DFyyyyMMddhhmma)
        }
        return false
    }
    
    
    
    func setDatePicker(on textField: UITextField, dateFormat: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let vc = board.task.selectTimeViewController()!
        vc.datePicketMode = .dateAndTime
        vc.currentDate = dateFormatter.date(from: textField.text!)
        vc.selectedDate.subscribe(onNext: { (date) in
            print(date)
            textField.text = dateFormatter.string(from: date)
            if textField == self.controls.txtStartDate {
                self.startDate = date
            } else if textField == self.controls.txtDueDate {
                self.dueDate = date
            } else if textField == self.controls.txtStopRemider {
                self.stopDate = date
            }
        }).disposed(by: controls.disposeBag)
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }

    
    func showFolderVC(){
        let vc = board.task.selectFolderViewController()!
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .flipHorizontal
        vc.delegate = self
        vc.selectedObject = selectedFolder
        self.present(vc, animated: false, completion: nil)
    }
 
    func addTask() {
        if !isValidAllFields() {
            return
        }
        var parameters:[String:Any]
       
        var arrSubTasks = [[String:Any]]()
       // let arrSub = isEditMode ? arrUpdatesubTasks.value : subTasks.value
        let arrSub = subTasks.value

        for task in arrSub {
            let dict = ["SubtaskId":task.SubtaskId,"Task": task.Task,"IsDone":task.IsDone] as [String : Any]
            arrSubTasks.append(dict)
        }
        var arrayAssigner = [[String:Any]]()
        for user in arrAssigner.value {
            let dict = ["_id": user.UserId,"UserName":user.UserName,"Profile":user.Profile,"EmailAddress":user.EmailAddress] as [String : Any]
            arrayAssigner.append(dict)
        }
        var arrayReviewer = [[String:Any]]()
        for user in arrReviewer.value {
            let dict = ["_id": user.UserId,"UserName":user.UserName,"Profile":user.Profile,"EmailAddress":user.EmailAddress] as [String : Any]
            arrayReviewer.append(dict)
        }
        let stopReminder = stopDate != nil ? "\(stopDate.millisecondsSince1970)" : ""
        var url = webUrls.baseURL() + webUrls.createTask()
        var taskID = UUID.init().uuidString
        if isEditMode {
            url = webUrls.baseURL() + webUrls.updateTask()
            taskID = task.TaskLocalId
        }
        parameters = [
            "FolderName" :        selectedFolder?.FolderId ?? "",
            "TaskTitle":          controls.txtTitle.text ?? "" ,
            "Description":        controls.txtDescription.text ?? "",
            "Schedule":["StartDate" :         "\(startDate.millisecondsSince1970)",
                "DueDateAndTime":     "\(dueDate.millisecondsSince1970)",
                "IntervalType":repeatIntervalType.textValue,
                "IntervalDays":arryOfDays,
                "IntervalMonths":arrayOfMonths,
                "StopReminder" :  stopReminder],
            "TaskLocalId":        taskID ,
            "SubTask":           arrSubTasks,
            "Assigned":          arrayAssigner,
            "Reviewer":          arrayReviewer,
            "IsDone":          false,
            
            ] as [String : Any]
        if isEditMode {
           parameters["OldImages"] = task.Files.toArray()
        }
        if arrAssigner.value.count == 0 {
            startLoader()
            if let dataTask = parameters as? [String : Any]{
                if let task = Mapper<Task>().map(JSON:dataTask) {
                    try! realm.write {
                        task.IsDone = .pending
                        realm.add(task, update: true)
                    }
                }
            }
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    //    multipartFormData.append(imageData, withName: "user", fileName: "user.jpg", mimeType: "image/jpeg")
                    
                    for (key, value) in parameters {
                        if let value = value as? String {
                            multipartFormData.append((value).data(using:String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                        } else if let value1 = value as? Array<Any> {
                            multipartFormData.append((self.getData(from: value1)!), withName: key)
                        } else if let value2 = value as? Dictionary<String, Any> {
                            multipartFormData.append((self.getData(from: value2)!), withName: key)

                            
                        }
                    }
                    
                    let arrOfImages = self.isEditMode ? self.arrayImages : self.arrayUpdateImages
                    for i in 0..<arrOfImages.count {
                        //if let img = tempImg {
                        let imgData = arrOfImages[i].jpegData(compressionQuality: 0.7)
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
                                            realm.add(task, update: true)
                                        }
                                        TaskHelper.setAllTask()
                                        self.navigationController?.popViewController(animated: true)
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
        } else{
            self.navigateToNext(parameters)
        }
    }
    
    func navigateToNext(_ parameters:[String:Any]) {
        let taskRemiderVC = R.storyboard.task.taskRemiderVC()!
        taskRemiderVC.dueDate = dueDate
        taskRemiderVC.stopDate = stopDate
        
        taskRemiderVC.arrayOfMonths = arrayOfMonths
        taskRemiderVC.arryOfDays = arryOfDays
        
        taskRemiderVC.repeatIntervalType = repeatIntervalType
        taskRemiderVC.strRepeat = controls.txtRepeatReminder.text ?? ""
        taskRemiderVC.startDate = startDate
        taskRemiderVC.arrayImages = isEditMode ? arrayUpdateImages : arrayImages
        taskRemiderVC.parameters = parameters
        taskRemiderVC.selectedDays = selectedDays
        taskRemiderVC.isUpdate = isEditMode
        
        self.navigationController?.pushViewController(taskRemiderVC, animated: true)
    }
    
    
}

extension UIViewController {
    func getData(from object:Any)-> Data? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return data
    }
}

extension AddTaskViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.cell, for: indexPath) as! TaskFilesCollectionViewCell
        cell.viewAttachFile.isHidden = true
        cell.imgThumb.image = arrayImages[indexPath.row]
        cell.imgThumb.alpha = 1.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 100)
    }
    
}

//MARK:- FolderSelectionDelegate

extension AddTaskViewController: FolderSelectionDelegate {
    func didselectFolder(_ obj: FolderResponseModel) {
        self.selectedFolder = obj
        controls.txtFolder.text = obj.FolderName
    }
}
