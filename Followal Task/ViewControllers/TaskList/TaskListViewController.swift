//
//  TaskListViewController.swift
//  followal
//
//  Created by Vivek Gadhiya on 08/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import ObjectMapper
import SwiftyJSON
import KSPhotoBrowser
import DropDown
class TaskListViewController: UIViewController {
    
    //MARK:- Outlet -
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnAddTask: UIBarButtonItem!
    
    @IBOutlet weak var btnSortTask: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSearchTask: UIBarButtonItem!
    
    //MARK:- Variable
    var disposeBag = DisposeBag()
    let searchController = UISearchController(searchResultsController: nil)
    var arrTask = [Task]()
    var overDueCount = 0
    var isCompleted = false
    var selectedFolder :FolderResponseModel?
    var sortByOption:SortBy = .none
    
    //MARK:- UIView Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Localization.inbox.key.localized
        if selectedFolder == nil{
            let folderArray = Array(realm.objects(FolderResponseModel.self).filter({$0.FolderName == "Inbox"}))
            if folderArray.count > 0 {
                selectedFolder = folderArray[0]
            }
        }
        setupUI()
        addObserver()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK:- Setup UI, Observer
    func setupUI() {
        self.navigationItem.hidesBackButton = true
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.searchBarStyle = .prominent
        searchController.searchResultsUpdater = self
        self.navigationItem.hidesSearchBarWhenScrolling = true
        tableView.register(UINib(resource: nibs.taskListTableViewCell), forCellReuseIdentifier: CellIdentifiers.cell)
        tableView.register(UINib.init(resource: nibs.taskListHeaderTableViewCell), forCellReuseIdentifier: CellIdentifiers.headerCell)
        tableView.tableFooterView = UIView(frame: .zero)
        
        arrTask = getTaskData()
        // realmObserver()
        
        //        for task in arrTask {
        //            print(Date(milliseconds: Int64(task.Schedule.StartDate)!))
        //        }
        let req = FolderList()
        let request = RequestBaseModel<FolderList>()
        request.data = req
        request.eventName = "MyTaskList"
        request.accessToken = getAccessToken()
        
        self.taskList(request: request)
        let reqFolder = FolderList()
        let requestFolder = RequestBaseModel<FolderList>()
        requestFolder.data = reqFolder
        requestFolder.eventName = "MyFolderList"
        self.folderList(request: requestFolder)
    }
    
    
    func getTaskData() -> [Task] {
        
        
        
        let status:TaskStatus = self.isCompleted ? .done : .pending
        var arrTask = Array(realm.objects(Task.self).filter({$0.IsDone == status}))
        let searchText = searchController.searchBar.text ?? ""
        if !searchText.isEmpty {
            arrTask = Array(realm.objects(Task.self).filter({$0.IsDone == status}).filter({$0.TaskTitle.lowercased().contains(searchText.lowercased())}))
        }
        if  let objFolder = selectedFolder {
            if objFolder.FolderName == "Completed" {return arrTask }
            else if objFolder.FolderName == "All" {
                arrTask = Array(realm.objects(Task.self))
                if !searchText.isEmpty {
                    arrTask = Array(realm.objects(Task.self).filter({$0.TaskTitle.lowercased().contains(searchText.lowercased())}))
                }
            } else if objFolder.FolderName == "Assign" {
                arrTask = Array(realm.objects(Task.self).compactMap({ (task) -> Task? in
                    if task.Assigned.count > 0 {
                        if task.Assigned[0].UserId == getUserID() {
                            return task
                        }
                        return nil
                        
                    }
                    return nil
                    
                }))
                if !searchText.isEmpty {
                    arrTask = Array(realm.objects(Task.self).compactMap({ (task) -> Task? in
                        if task.Assigned.count > 0 {
                            if task.Assigned[0].UserId == getUserID() {
                                return task
                            }
                            return nil
                            
                        }
                        return nil
                        
                    }).filter({$0.TaskTitle.lowercased().contains(searchText.lowercased())}))
                }
            } else if objFolder.FolderName == "Review" {
                arrTask = Array(realm.objects(Task.self).compactMap({ (task) -> Task? in
                    if task.Reviewer.count > 0 {
                        if task.Reviewer[0].UserId == getUserID() {
                            return task
                        }
                        return nil
                        
                    }
                    return nil
                    
                }))
                if !searchText.isEmpty {
                    arrTask = Array(realm.objects(Task.self).compactMap({ (task) -> Task? in
                        if task.Reviewer.count > 0 {
                            if task.Reviewer[0].UserId == getUserID() {
                                return task
                            }
                            return nil
                        }
                        return nil
                    }).filter({$0.TaskTitle.lowercased().contains(searchText.lowercased())}))
                }
            } else {
                arrTask = Array(realm.objects(Task.self).filter({$0.FolderName == objFolder.FolderId }).filter({$0.IsDone == status}))
                if !searchText.isEmpty {
                    arrTask = Array(realm.objects(Task.self).filter({$0.FolderName == objFolder.FolderId }).filter({$0.IsDone == status}).filter({$0.TaskTitle.lowercased().contains(searchText.lowercased())}))
                }
                
            }
        }
        if sortByOption == .none {
            var tempTaskDueIncoming = arrTask.filter({Date(milliseconds: Int64($0.Schedule.DueDateAndTime)!) > Date()})
            tempTaskDueIncoming.sort(by: { Date(milliseconds: Int64($0.Schedule.StartDate)!).compare(Date(milliseconds: Int64($1.Schedule.StartDate)!)) == .orderedAscending })
            
            var tempTaskDueGone = arrTask.filter({Date(milliseconds: Int64($0.Schedule.DueDateAndTime)!) < Date()})
            tempTaskDueGone.sort(by: { Date(milliseconds: Int64($0.Schedule.DueDateAndTime)!).compare(Date(milliseconds: Int64($1.Schedule.DueDateAndTime)!)) == .orderedAscending })
            overDueCount = tempTaskDueGone.count
            arrTask = tempTaskDueGone + tempTaskDueIncoming
        } else if sortByOption == .startDate {
            let tempTaskStartDate = arrTask.sorted(by: { Date(milliseconds: Int64($0.Schedule.StartDate)!).compare(Date(milliseconds: Int64($1.Schedule.StartDate)!)) == .orderedAscending })
            arrTask = tempTaskStartDate
        } else if sortByOption == .dueDate {
            let tempTaskStartDate = arrTask.sorted(by: { Date(milliseconds: Int64($0.Schedule.DueDateAndTime)!).compare(Date(milliseconds: Int64($1.Schedule.DueDateAndTime)!)) == .orderedAscending })
            arrTask = tempTaskStartDate
        }
        
        return arrTask
    }
    
    
    //    func getRemindDate(_ task: ScheduleTask) -> String {
    //
    //        let type = task.IntervalType.textValue
    //        print(type)
    //        var remindDate:Date?
    //        var currentDate:DateComponents = Calendar.current.dateComponents([.year,.weekday,.month,.day,.hour,.minute,.second], from: Date())
    //        var taskDueDate = Calendar.current.dateComponents([.year,.weekday,.month,.day,.hour,.minute,.second], from: Date(milliseconds: Int64(task.DueDateAndTime)!))
    //        var taskStopDate = Calendar.current.dateComponents([.year,.weekday,.month,.day,.hour,.minute,.second], from: Date(milliseconds: Int64(task.StopReminder)!))
    //        let totalWeekDasys = 7
    //        var arrayDate = [Date]()
    //
    //
    //        if type == "Day" { //Handle Custom Day
    //
    //            if currentDate.date! < taskDueDate.date! {
    //               remindDate = taskDueDate.date!.addingTimeInterval(TimeInterval(task.IntervalDays.toArray()[0]*84600))
    //            } else {
    //                var nextDate = taskDueDate.date!.addingTimeInterval(TimeInterval(task.IntervalDays.toArray()[0]*84600))
    //                for i in task.IntervalDays.toArray(){
    //                    if nextDate > Date(){
    //                    remindDate = nextDate
    //                    break
    //                } else {
    //                 repeat {
    //                    nextDate = nextDate.addingTimeInterval(TimeInterval(i*84600))
    //                 }while nextDate < currentDate.date!
    //              }
    //            }
    //                remindDate = nextDate
    //            }
    //        } else if type == "Week" { // Handle Custom Week
    //
    //            let weekDateSet = task.IntervalDays
    //            if currentDate.date! < taskDueDate.date! {
    //                if weekDateSet.contains(taskDueDate.weekday!) {
    //                    remindDate = taskDueDate.date!
    //                } else{
    //                    let interval = (totalWeekDasys - taskDueDate.weekday! ) + weekDateSet[0]
    //                    remindDate = taskDueDate.date!.addingTimeInterval(TimeInterval(interval*84600))
    //                }
    //            } else {
    //
    //                if weekDateSet.contains(currentDate.weekday!) {
    //                    if weekDateSet.last == currentDate.weekday {
    //                        let interval = (totalWeekDasys - currentDate.weekday! ) + weekDateSet[0]
    //                        remindDate = currentDate.date!.addingTimeInterval(TimeInterval(interval*84600))
    //                    } else{
    //                        if let index = weekDateSet.index(of: currentDate.weekday!) {
    //                            let interval = (totalWeekDasys - currentDate.weekday! ) + weekDateSet[index + 1]
    //                            remindDate = currentDate.date!.addingTimeInterval(TimeInterval(interval*84600))
    //                        }
    //                    }
    //                }
    //            }
    //        } else if type == "Month" { // Handle Custom Month
    //            let components = task.IntervalDays.toArray().compactMap { (value) -> DateComponents? in
    //                var component = DateComponents()
    //                component.month = value
    //                return component
    //            }
    //            let daysName = components.compactMap( { $0.day }).map { $0.description }
    //            print(daysName)
    //
    //        } else if type == "Year" {
    //
    //            let components = task.IntervalMonths.toArray().compactMap { (value) -> DateComponents? in
    //                var component = DateComponents()
    //                component.month = value
    //                return component
    //            }
    //            let daysName = Set(components.compactMap( { $0.month }).map { ArrayOfMonths[$0 - 1] })
    //            print(daysName)
    //
    //
    //        }
    //        if remindDate != nil {
    //            return remindDate!.datePhraseTime(withFormat: DateFormats.DFhhmmaddmmyyyy)
    //        }
    //        return ""
    //    }
    
    func getRemindDate(_ task: ScheduleTask) -> String {
        
        let type = task.IntervalType.textValue
        print(type)
        var remindDate:Date?
        
        let taskDueDate = Date(milliseconds: Int64(task.DueDateAndTime)!)
        let currentDate = Date()
        var currentDateComponent:DateComponents = Calendar.current.dateComponents([.year,.weekday,.month,.day,.hour,.minute,.second], from: Date())
        var taskDueDateComponent = Calendar.current.dateComponents([.year,.weekday,.month,.day,.hour,.minute,.second], from: Date(milliseconds: Int64(task.DueDateAndTime)!))
        let range =  Calendar.current.range(of: .day, in: .month, for: Date())
        let totalMonthDasys =  range!.count
        // var taskDueDate = Calendar.current.dateComponents([.year,.weekday,.month,.day,.hour,.minute,.second], from: Date(milliseconds: Int64(task.DueDateAndTime)!))
        let totalWeekDasys = 7
        
        
        if type == "Day" { //Handle Custom Day
            let daySet = task.IntervalDays.toArray()
            if daySet.count == 0{
                return ""
            }
            if currentDate < taskDueDate {
                remindDate = taskDueDate.addingTimeInterval(TimeInterval(daySet[0]*84600))
            } else {
                var nextDate = taskDueDate.addingTimeInterval(TimeInterval(daySet[0]*84600))
                for i in daySet{
                    if nextDate > Date(){
                        remindDate = nextDate
                        break
                    } else {
                        repeat {
                            nextDate = nextDate.addingTimeInterval(TimeInterval(i*84600))
                        }while nextDate < currentDate
                    }
                }
                remindDate = nextDate
            }
        } else if type == "Week" { // Handle Custom Week
            
            let weekDateSet = task.IntervalDays.toArray()
            if weekDateSet.count == 0{
                return ""
            }
            if currentDate < taskDueDate {
                if weekDateSet.contains(taskDueDateComponent.weekday!) {
                    remindDate = taskDueDate
                } else{
                    let interval = (totalWeekDasys - taskDueDateComponent.weekday! ) + weekDateSet[0]
                    remindDate = taskDueDate.addingTimeInterval(TimeInterval(interval*84600))
                }
            } else {
                
                if weekDateSet.contains(currentDateComponent.weekday!) {
                    if weekDateSet.last == currentDateComponent.weekday {
                        let interval = (totalWeekDasys - currentDateComponent.weekday! ) + weekDateSet[0]
                        remindDate = currentDate.addingTimeInterval(TimeInterval(interval*84600))
                    } else{
                        if let index = weekDateSet.firstIndex(of: currentDateComponent.weekday!) {
                            let interval = (totalWeekDasys - currentDateComponent.weekday! ) + weekDateSet[index + 1]
                            remindDate = currentDate.addingTimeInterval(TimeInterval(interval*84600))
                        }
                    }
                } else {
                    let indexWeek = weekDateSet.filter({$0 > currentDateComponent.weekday!})
                    if indexWeek.count > 0 {
                        let interval =  indexWeek[0] - currentDateComponent.weekday!
                        remindDate = currentDate.addingTimeInterval(TimeInterval(interval*84600))
                    } else {
                        let interval = (totalWeekDasys - currentDateComponent.weekday! ) + weekDateSet[0]
                        remindDate = currentDate.addingTimeInterval(TimeInterval(interval*84600))
                    }
                }
            }
        } else if type == "Month" { // Handle Custom Week
            
            let monthlyDateSet = task.IntervalDays.toArray()
            if monthlyDateSet.count == 0{
                return ""
            }
            if currentDate < taskDueDate {
                if monthlyDateSet.contains(taskDueDateComponent.day!) {
                    remindDate = taskDueDate
                } else{
                    let indexDay = monthlyDateSet.filter({$0 > taskDueDateComponent.day!})
                    if indexDay.count > 0 {
                        let interval =  indexDay[0] - taskDueDateComponent.day!
                        remindDate = taskDueDate.addingTimeInterval(TimeInterval(interval*84600))
                    } else {
                        let interval = (totalMonthDasys - taskDueDateComponent.day! ) + monthlyDateSet[0]
                        remindDate = currentDate.addingTimeInterval(TimeInterval(interval*84600))
                    }
                }
            } else {
                let indexDay = monthlyDateSet.filter({$0 > currentDateComponent.day!})
                if indexDay.count > 0 {
                    let interval =  indexDay[0] - currentDateComponent.day!
                    remindDate = taskDueDate.addingTimeInterval(TimeInterval(interval*84600))
                } else {
                    let interval = (totalMonthDasys - currentDateComponent.day! ) + monthlyDateSet[0]
                    remindDate = currentDate.addingTimeInterval(TimeInterval(interval*84600))
                }
            }
            
        } else if type == "Year" { // Handle Custom Week
            
            let monthlyDateSet = task.IntervalDays.toArray()
            let yearlyMonthSet = task.IntervalMonths.toArray()
            
            
            if monthlyDateSet.count == 0 || yearlyMonthSet.count == 0 {
                return ""
            }
            
            if currentDate < taskDueDate {
                if yearlyMonthSet.contains(taskDueDateComponent.month!) {
                    if monthlyDateSet.contains(taskDueDateComponent.day!) {
                        remindDate = taskDueDateComponent.date
                    } else{
                        let indexDay = monthlyDateSet.filter({$0 > taskDueDateComponent.day!})
                        if indexDay.count > 0 {
                            let interval =  indexDay[0] - taskDueDateComponent.day!
                            remindDate = taskDueDate.addingTimeInterval(TimeInterval(interval*84600))
                        } else {
                            var startMonth = taskDueDateComponent.month!
                            var startYear = taskDueDateComponent.year!
                            repeat {
                                if startMonth == 12 {
                                    startMonth = 1
                                    startYear = startYear + 1
                                } else {
                                    startMonth = startMonth + 1
                                }
                            }while yearlyMonthSet.contains(startMonth)
                            var nextDate = DateComponents()
                            nextDate.day = monthlyDateSet[0]
                            nextDate.month = startMonth
                            nextDate.year = startYear
                            nextDate.hour = taskDueDateComponent.hour
                            nextDate.minute = taskDueDateComponent.minute
                            if let nextFinaldate  = nextDate.date {
                                remindDate = nextFinaldate
                            }
                        }
                    }
                    
                } else {
                    var startMonth = taskDueDateComponent.month!
                    var startYear = taskDueDateComponent.year!
                    repeat {
                        if startMonth == 12 {
                            startMonth = 1
                            startYear = startYear + 1
                        } else {
                            startMonth = startMonth + 1
                        }
                    }while yearlyMonthSet.contains(startMonth)
                    var nextDate = DateComponents()
                    nextDate.day = monthlyDateSet[0]
                    nextDate.month = startMonth
                    nextDate.year = startYear
                    nextDate.hour = taskDueDateComponent.hour
                    nextDate.minute = taskDueDateComponent.minute
                    if let nextFinaldate  = nextDate.date {
                        remindDate = nextFinaldate
                    }
                }
            } else {
                if yearlyMonthSet.contains(currentDateComponent.month!) {
                    if monthlyDateSet.contains(currentDateComponent.day!) {
                        remindDate = currentDateComponent.date
                    } else{
                        let indexDay = monthlyDateSet.filter({$0 > currentDateComponent.day!})
                        if indexDay.count > 0 {
                            let interval =  indexDay[0] - currentDateComponent.day!
                            remindDate = taskDueDate.addingTimeInterval(TimeInterval(interval*84600))
                        } else {
                            var startMonth = currentDateComponent.month!
                            var startYear = currentDateComponent.year!
                            repeat {
                                if startMonth == 12 {
                                    startMonth = 1
                                    startYear = startYear + 1
                                } else {
                                    startMonth = startMonth + 1
                                }
                            }while yearlyMonthSet.contains(startMonth)
                            var nextDate = DateComponents()
                            nextDate.day = monthlyDateSet[0]
                            nextDate.month = startMonth
                            nextDate.year = startYear
                            nextDate.hour = taskDueDateComponent.hour
                            nextDate.minute = taskDueDateComponent.minute
                            if let nextFinaldate  = nextDate.date {
                                remindDate = nextFinaldate
                            }
                        }
                    }
                    
                } else {
                    var startMonth = currentDateComponent.month!
                    var startYear = currentDateComponent.year!
                    repeat {
                        if startMonth == 12 {
                            startMonth = 1
                            startYear = startYear + 1
                        } else {
                            startMonth = startMonth + 1
                        }
                    }while yearlyMonthSet.contains(startMonth)
                    var nextDate = DateComponents()
                    nextDate.day = monthlyDateSet[0]
                    nextDate.month = startMonth
                    nextDate.year = startYear
                    nextDate.hour = taskDueDateComponent.hour
                    nextDate.minute = taskDueDateComponent.minute
                    if let nextFinaldate  = nextDate.date {
                        remindDate = nextFinaldate
                    }
                }
            }
            //  let monthlyDateSet = task.IntervalDays
            //let yearlyMonthSet = task.IntervalMonths
        }
        if task.StopReminder != "" {
            let taskStopDate = Date(milliseconds: Int64(task.StopReminder)!)
            if remindDate != nil {
                if remindDate! > taskStopDate {
                    return ""
                }
            }
        }
        if remindDate != nil {
            return remindDate!.datePhrasedate(withFormat: DateFormats.DFhhmmaddmmyyyy)
        }
        return ""
    }
    
    
    func addObserver() {
        btnSearchTask.rx.tap.subscribe(onNext: {
            
        }).disposed(by: disposeBag)
        
        btnAddTask.rx.tap.subscribe(onNext: {
            let vc = board.task.addTaskVC()!
            vc.isEditMode = false
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        btnBack.rx.tap.subscribe(onNext: {
            let vc = board.task.folderListVC()!
            vc.folderSelected.subscribe(onNext: {
                self.selectedFolder = $0
                self.isCompleted = $0?.FolderName == "Completed" ? true : false
                self.title = $0 == nil ? Localization.inbox.key : $0?.FolderName
                self.arrTask.removeAll()
                self.tableView.reloadData()
                self.arrTask = self.getTaskData()
                self.tableView.reloadData()
                
            }).disposed(by: self.disposeBag)
            let transition = CATransition()
            transition.duration = 0.45
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(vc, animated: false)
        }).disposed(by: disposeBag)
        
        btnSortTask.rx.tap.subscribe(onNext: {
            let dropDown = DropDown()
            dropDown.anchorView = self.btnSortTask
            var options = ["Sort by Due date", "Sort By Start date", "Remove filter", "Logout"]
            if let obj = self.selectedFolder {
                if obj.FolderName == "Assign" || obj.FolderName == "Review" {
                    options = ["Sort by Folder Name", "Sort by Due date", "Sort By Start date", "Remove filter", "Logout"]
                }
            }
            dropDown.dataSource = options
            dropDown.cellHeight = 45.0
            dropDown.backgroundColor = .white
            dropDown.width = 200
            dropDown.show()
            dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView!.plainView.bounds.height)
            
            dropDown.selectionAction = { (index, item) in
                //self.navigationItem.searchController = nil
                
                if item == "Sort by Folder Name" {
                    let vc = board.task.folderListVC()!
                    vc.isAssignFolderSelected = self.title == "Assign" ?  1 : self.title == "Review" ?  2 : 0
                    vc.folderSelected.subscribe(onNext: {
                        self.selectedFolder = $0
                        self.isCompleted = $0?.FolderName == "Completed" ? true : false
                        self.title = $0 == nil ? Localization.inbox.key : $0?.FolderName
                        self.arrTask.removeAll()
                        self.tableView.reloadData()
                        self.arrTask = self.getTaskData()
                        self.tableView.reloadData()
                        
                    }).disposed(by: self.disposeBag)
                    let transition = CATransition()
                    transition.duration = 0.45
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
                    transition.type = CATransitionType.push
                    transition.subtype = CATransitionSubtype.fromLeft
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                else if item == "Sort by Due date" {
                    self.sortByOption = .dueDate
                    self.arrTask = self.getTaskData()
                    self.tableView.reloadData()
                }
                else if item == "Sort By Start date" {
                    self.sortByOption = .startDate
                    self.arrTask = self.getTaskData()
                    self.tableView.reloadData()
                }
                else if item == "Remove filter" {
                    self.sortByOption = .none
                    self.arrTask = self.getTaskData()
                    self.tableView.reloadData()
                }
                else if item == "Logout" { // New Group
                    self.popupAlert(title: nil, message: Localization.logoutMessage().localized, actionTitles: ["OK" , Localization.cancel.key.localized], actions: [ { action in
                        TaskHelper.logout()
                        }, { action2 in
                            
                        }])
                }
            }
            
        }).disposed(by: disposeBag)
        realmObserver()
    }
    
    var notificationToken: NotificationToken? = nil
    
    func realmObserver() {
        
        // Observe Results Notifications
        var results = realm.objects(Task.self).filter("IsDone == %@",self.isCompleted)
        if let objFolder = selectedFolder {
            if self.title == "All" {
                results = realm.objects(Task.self)
            } else if self.title == "Completed"{  }
            else {
                results = realm.objects(Task.self).filter("FolderName == %@", objFolder.FolderId).filter("IsDone == %@",self.isCompleted)
            }
        }
        
        // let results = realm.objects(Task.self)
        //  MessageHelper.syncMessage()
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                print(results)
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                self!.arrTask = self!.getTaskData()
                self?.tableView.reloadData()
                //                    tableView.performBatchUpdates({
                //                        tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                //                                             with: .none)
                //                        tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                //                                             with: .none)
                //                        tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                //                                             with: .none)
                //                      //  tableView.reloadData()
                //                    }, completion: { (success) in
                //                    })
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    //MARK:- API Call -
    
    func folderList(request: RequestBaseModel<FolderList>) {
        
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: self)
                return
            }
               TaskHelper.createDefaultAllFolder()
            //                let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            //                let responseModel = try decoder.decode(ResponseBaseModel<[FolderResponseModel]>.self, from: jsonData)
            //                if responseModel.returnValue {
            //                    try realm.write {
            //                        realm.add(responseModel.data!, update: true)
            //                    }
            
            //      TaskHelper.createDefaultAllFolder()
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
                    if let dataUser = jsonData["Data"].arrayObject as? [[String : Any]] {
                        let folder = Mapper<FolderResponseModel>().mapArray(JSONArray:dataUser)
                        let realm = try! Realm()
                        try realm.write {
                            realm.add(folder, update: true)
                        }
                    }
                    
                } else {
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: self)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: self)
            }
            
        }
    }
    
    func taskList(request: RequestBaseModel<FolderList>) {
        
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: self)
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
                    if let dataUser = jsonData["Data"].arrayObject as? [[String : Any]] {
                        let user = Mapper<Task>().mapArray(JSONArray:dataUser)
                        let realm = try! Realm()
                        try realm.write {
                            realm.add(user, update: true)
                        }
                        TaskHelper.setAllTask()
                        //self.arrTask = Array(realm.objects(Task.self))
                        //self.tableView.reloadData()
                    }
                    
                } else{
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: self)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: self)
            }
            
            
        }
    }
    
    
    
    func deleteTask(request: RequestBaseModel<DeleteTaskRequest>,index:Int) {
        
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: self)
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
                    let realm = try! Realm()
                    try realm.write {
                        realm.delete(self.arrTask[index])
                    }
                    TaskHelper.setAllTask()
                    self.arrTask = self.getTaskData()
                    self.tableView.reloadData()
                    
                    
                } else{
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: self)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: self)
            }
            
            
        }
    }
    
}



//MARK:- UITableViewDataSource, UITableViewDelegate

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cell) as! TaskListTableViewCell
        let obj = arrTask[indexPath.row]
        let isSepNeeded = isTimeSeperatorNeededAt(index: indexPath.row)
        if isSepNeeded {
            cell.constraintHeaderHeight.constant = 45
            
        } else{
            cell.constraintHeaderHeight.constant = 0
        }
        let currentDate = Date()
        cell.lblTaskName.text = obj.TaskTitle
        let schedule = TaskHelper.getScheduleFromTask(obj)
        let miliSecStart = Int64(schedule.StartDate ?? "0")
        if let miliSecDue = Int64(schedule.DueDateAndTime ?? "0") {
            let dueDate =  Date(milliseconds: miliSecDue)
            cell.lblDueDate.text =  dueDate.convertDate(toFormat: DateFormats.DFdd_MM_yyyy)
            if isSepNeeded {
                if sortByOption == .none {
                    cell.lblHeaderDate.text = indexPath.row == 0 ? Date().datePhrase(withFormat: DateFormats.DFddMMMYYYY) : Date(milliseconds: miliSecStart!).toLocal().convertDate(toFormat: DateFormats.DFddMMMYYYY)
                    cell.lblHeaderOverdue.text = indexPath.row == 0 ? (overDueCount == 0 ? "" : "\(overDueCount) Overdue") : ""
                } else if sortByOption == .startDate {
                    if miliSecStart != nil {
                    cell.lblHeaderDate.text =  Date(milliseconds: miliSecStart!).toLocal().convertDate(toFormat: DateFormats.DFddMMMYYYY)
                    }
                    cell.lblHeaderOverdue.text = ""
                    
                } else if sortByOption == .dueDate {
                    cell.lblHeaderDate.text =  Date(milliseconds: miliSecDue).toLocal().convertDate(toFormat: DateFormats.DFddMMMYYYY)
                    cell.lblHeaderOverdue.text = ""
                    
                }
            }
            cell.lblDueDate.textColor =  currentDate > dueDate ? UIColor(hexString: HexString.hex_startcolor) : Colors.blackTheme.withAlphaComponent(0.6)
            cell.imgDueDate.image =  currentDate > dueDate ? images.ic_calender_selected() : images.ic_calender()
            cell.lblReminderDate.textColor =  currentDate > dueDate ? UIColor(hexString: HexString.hex_startcolor) : Colors.blackTheme.withAlphaComponent(0.6)
            cell.imgReminderDate.image =  currentDate > dueDate ? images.ic_notification_selected() : images.ic_notification_unseleted()
        }
        cell.lblUserCount.text = "\(obj.SubTask.count)"
        cell.lblAttchmentCount.text = "\(obj.Files.count)"
        let commentCount = realm.objects(Comment.self).filter({$0.taskID == obj.TaskLocalId}).count
        cell.lblCommentCount.text = "\(commentCount)"
        if let remindDate = getRemindDate(schedule) as? String{
            print("RemindDate******",remindDate)
            cell.lblReminderDate.text = remindDate
            cell.imgReminderDate.isHidden = remindDate.isEmpty ? true : false
        }
        cell.btnCheck.isSelected = obj.IsDone == .pending ? false : true
        cell.btnCheck.rx.tap.subscribe(onNext: {
            let arrSubtask = obj.SubTask.filter({$0.IsDone == .pending})
            if arrSubtask.count == 0 {
                cell.btnCheck.isSelected = !cell.btnCheck.isSelected
                print("Check Tapped")
                let status = obj.IsDone == .pending ? 1 : 0
                TaskHelper.taskStatus(task: obj, status: status)
                try! realm.write {
                    self.arrTask[indexPath.row].IsDone = obj.IsDone == .pending  ? .done : .pending
                }
                self.arrTask = self.getTaskData()
                TaskHelper.setAllTask()
                self.tableView.reloadData()
            } else{
                self.showToast("Before complete this, Please complete all subtask of this task ")
            }
        }).disposed(by: cell.disposeBag)
        
        cell.btnBookMark.rx.tap.subscribe(onNext: {
            cell.btnBookMark.isSelected = cell.btnBookMark.isSelected
        }).disposed(by: cell.disposeBag)
        
        cell.btnAttachment.rx.tap.subscribe(onNext: {
            
            if obj.Files.toArray().count > 0{
                let vc = board.task.attachmentVC()!
                vc.task = self.arrTask[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            } else{
                self.showToast("No attachments")
            }
        }).disposed(by: cell.disposeBag)
        
        cell.btnSubTaskList.rx.tap.subscribe(onNext: {
            if obj.SubTask.toArray().count > 0{
                let vc = board.task.subTaskListVC()!
                vc.task = self.arrTask[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            } else{
                self.showToast("No Subtasks")
            }
        }).disposed(by: cell.disposeBag)
        
        cell.btnComment.rx.tap.subscribe(onNext: {
            let vc = board.task.taskCommentVC()!
            vc.task = self.arrTask[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: cell.disposeBag)
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.headerCell) as! TaskListHeaderTableViewCell
    //        cell.lblDatePhrase.text = "April - 2019"
    //        cell.lblOverdueCount.text = "\(section + 1) \(Localization.overdue.key.localized)"
    //        return cell.contentView
    //    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = board.task.taskDetailVC()!
        vc.task = arrTask[indexPath.row]
        vc.isEditMode = indexPath.row % 2 == 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 50
    //    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = self.arrTask[indexPath.row]

        let editAction = UIContextualAction(style: .normal, title:  Localization.edit.key.localized, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let vc = board.task.addTaskVC()!
            vc.task = task
            vc.isEditMode = true
            self.navigationController?.pushViewController(vc, animated: true)
            success(true)
        })
        let taskUserID = task.UserId
        var actions = [UIContextualAction]()
        if taskUserID == getUserID() {
            actions.append(editAction)
        }
        editAction.backgroundColor = Colors.lightGray
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = self.arrTask[indexPath.row]
        let infoAction = UIContextualAction(style: .normal, title:  Localization.info.key.localized, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let vc = board.task.taskDetailVC()!
            vc.task = task
            vc.isEditMode = false
            self.navigationController?.pushViewController(vc, animated: true)
            success(true)
        })
        infoAction.backgroundColor = Colors.blueTheme
        
        let deleteAction = UIContextualAction(style: .normal, title:  Localization.delete.key.localized, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let req = DeleteTaskRequest()
            req.taskLocalId = task.TaskLocalId
            let request = RequestBaseModel<DeleteTaskRequest>()
            request.data = req
            request.eventName = "DeleteTask"
            request.accessToken = getAccessToken()
            self.deleteTask(request: request, index: indexPath.row)
            
            success(true)
        })
        deleteAction.backgroundColor = Colors.red
        let taskUserID = task.UserId
        var actions = [infoAction]
        if taskUserID == getUserID() {
            actions.append(deleteAction)
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    
    func isTimeSeperatorNeededAt(index:Int) -> Bool {
        var addTimeSeparator = false
        if index == 0 {
            addTimeSeparator = true
        } else{
            let calendar = Calendar.current
            let current = arrTask[index]
            let prev: Task? = (index > 0) ? arrTask[index - 1] : nil
            //let next: Task? = (index + 1 < arrTask.count) ? arrTask[index + 1] : nil
            if let prev = prev {
                let currentDate = Date()
                let currentMessageDate = Date(milliseconds: Int64(current.Schedule.StartDate)!)
                let currentDueMessageDate = Date(milliseconds: Int64(current.Schedule.DueDateAndTime)!)
                let nextMessageDate = Date(milliseconds: Int64(prev.Schedule.StartDate)!)
                let nextDueMessageDate = Date(milliseconds: Int64(prev.Schedule.DueDateAndTime)!)
                if sortByOption == .none {
                    if currentDate < currentDueMessageDate {
                        addTimeSeparator = !calendar.isDate(currentMessageDate, inSameDayAs: nextMessageDate)
                    }
                    if currentDate > currentMessageDate {
                        addTimeSeparator = false
                    }
                } else if sortByOption == .startDate {
                    addTimeSeparator = !calendar.isDate(currentMessageDate, inSameDayAs: nextMessageDate)
                } else if sortByOption == .dueDate {
                    addTimeSeparator = !calendar.isDate(currentDueMessageDate, inSameDayAs: nextDueMessageDate)
                }
            } else {
                addTimeSeparator = true
            }
        }
        
        return addTimeSeparator
    }
}

//MARK:- UISearchResultsUpdating
extension TaskListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text)
        self.arrTask = getTaskData()
        tableView.reloadData()
    }
}
