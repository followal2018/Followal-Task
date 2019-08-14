//
//  TaskFolderListViewController.swift
//  followal
//
//  Created by Vivek Gadhiya on 08/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import SwiftyJSON


class TaskFolderListViewController: UIViewController {
    //MARK:- Outlet
    @IBOutlet weak var btnSearchFolder: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnAddFolder: UIBarButtonItem!

    //MARK:- Variable
    var disposeBag = DisposeBag()
    let searchController = UISearchController(searchResultsController: nil)
    let folderSelected = PublishSubject<FolderResponseModel?>()
    var arrFolders = [FolderResponseModel]()
    var arrTasks = [Task]()
    var isAssignFolderSelected = 0
    
    //MARK:- UIView Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setObserver()
        realmObserver()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arrFolders = setFolderNameWise()
        tableView.reloadData()
    }
    //MARK:- Setup UI, Observer
    func setupUI() {
        self.title = "\(Localization.task.key.localized) \(Localization.folder.key.localized)"
        self.navigationItem.hidesBackButton = true
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.searchBarStyle = .prominent
        searchController.searchResultsUpdater = self
        self.navigationItem.hidesSearchBarWhenScrolling = true
        tableView.register(UINib(resource: nibs.taskFolderListTableViewCell), forCellReuseIdentifier: CellIdentifiers.cell)
        tableView.tableHeaderView = UIView(frame: .zero)
        arrTasks = Array(realm.objects(Task.self))
        arrFolders = setFolderNameWise()
    }

    func setFolderNameWise()->[FolderResponseModel] {
        let arrFolders = Array(realm.objects(FolderResponseModel.self))
        let arrTask = Array(realm.objects(Task.self))
        
        var arrFoldersName = ["Inbox","All","Assign","Review","Completed"]
        let result1 = arrFolders.filter({$0.FolderName == arrFoldersName[0]}) + arrFolders.filter({$0.FolderName == arrFoldersName[1]}) + arrFolders.filter({$0.FolderName == arrFoldersName[2]}) + arrFolders.filter({$0.FolderName == arrFoldersName[3]})
        print(result1)
        
        let result2 = arrFolders.filter({!arrFoldersName.contains($0.FolderName)})
        let result3 = arrFolders.filter({$0.FolderName == "Completed"})
        let finalResult = (result1 + result2 + result3)
        var finalFilterResult = finalResult
        if isAssignFolderSelected  == 1{
            let arrFilterTasks =  arrTask.compactMap({ (task) -> String? in
                if task.Assigned.count > 0 {
                    if task.Assigned[0].UserId == getUserID() {
                        return task.FolderName
                    }
                    return nil
                    
                }
                return nil
                
            })
            finalFilterResult = finalResult.filter({arrFilterTasks.contains($0.FolderId) })
        } else if isAssignFolderSelected  == 2 {
            let arrFilterTasks =  arrTask.compactMap({ (task) -> String? in
                if task.Reviewer.count > 0 {
                    if task.Reviewer[0].UserId == getUserID() {
                        return task.FolderName
                    }
                    return nil
                    
                }
                return nil
                
            })
            finalFilterResult = finalResult.filter({arrFilterTasks.contains($0.FolderId) })

        } else {
            finalFilterResult = finalResult.filter({$0.UserId == getUserID() })
        }
        
        return finalFilterResult
        
        
    }
    
    var notificationToken: NotificationToken? = nil
    
    func realmObserver() {
        
        // Observe Results Notifications
        let results = realm.objects(FolderResponseModel.self)
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
                self!.arrFolders = self!.setFolderNameWise()
                //   tableView.kostylAgainstJumping {
                //  self!.offset = (self!.tableView.contentSize.height - self!.tableView.contentOffset.y)
                UIView.performWithoutAnimation {
                    
                    tableView.performBatchUpdates({
                        tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                             with: .none)
                        tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                             with: .none)
                        tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                             with: .none)
                    }, completion: { (success) in
                    })
                }
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func setObserver() {
        
        btnAddFolder.rx.tap
            .subscribe(onNext: {
                let viewController = board.task.createFolderVC()!
                self.navigationController?.pushViewController(viewController, animated: true)
            }).disposed(by: disposeBag)
        btnBack.rx.tap
            .subscribe(onNext: {
                self.redirectToTask(with: nil)
               // self.navigationController?.popToRootViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
   
}

//MARK:- UITableViewDataSource, UITableViewDelegate

extension TaskFolderListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFolders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cell) as! TaskFolderListTableViewCell
        let item = arrFolders[indexPath.row]
        
        cell.lblFolderName.text = item.FolderName
        
        var taskCount = arrTasks.filter({$0.FolderName == item.FolderId && $0.IsDone == .pending}).count
        var taskOverDueCount = arrTasks.filter({$0.FolderName == item.FolderId && $0.IsDone == .pending }).filter({Date(milliseconds: Int64($0.Schedule.DueDateAndTime )!)<Date()}).count
        
        if item.FolderName == "All" {
             taskCount = arrTasks.count
             taskOverDueCount = arrTasks.filter({Date(milliseconds: Int64($0.Schedule.DueDateAndTime )!)<Date() && $0.IsDone == .pending}).count
        }else if item.FolderName == "Completed" {
            taskCount = arrTasks.filter({ $0.IsDone == .done}).count
            taskOverDueCount = arrTasks.filter({Date(milliseconds: Int64($0.Schedule.DueDateAndTime )!)<Date() && $0.IsDone == .done}).count
        } else if item.FolderName == "Assign"  {
           //let selectedDays = schedule.IntervalDays.toArray().compactMap { (value) -> DateComponents? in

            taskCount = arrTasks.compactMap({ (task) -> Task? in
                if task.Assigned.count > 0 {
                    if task.Assigned[0].UserId == getUserID() {
                        return task
                    }
                    return nil

                }
                return nil

            }).count
                //.filter({ $0.Assigned[0]?.UserId == getUserID()}).count
            taskOverDueCount = arrTasks.compactMap({ (task) -> Task? in
                if task.Assigned.count > 0 {
                    if task.Assigned[0].UserId == getUserID() {
                        return task
                    }
                    return nil

                }
                return nil

            }).filter({Date(milliseconds: Int64($0.Schedule.DueDateAndTime )!)<Date() && $0.IsDone == .pending}).count

        }  else if item.FolderName == "Review"  {
            //let selectedDays = schedule.IntervalDays.toArray().compactMap { (value) -> DateComponents? in
            
            taskCount = arrTasks.compactMap({ (task) -> Task? in
                if task.Reviewer.count > 0 {
                    if task.Reviewer[0].UserId == getUserID() {
                        return task
                    }
                    return nil

                }
                return nil

            }).count
            //.filter({ $0.Assigned[0]?.UserId == getUserID()}).count
            taskOverDueCount = arrTasks.compactMap({ (task) -> Task? in
                if task.Reviewer.count > 0 {
                    if task.Reviewer[0].UserId == getUserID() {
                        return task
                    }
                    return nil

                }
                return nil

            }).filter({Date(milliseconds: Int64($0.Schedule.DueDateAndTime )!)<Date() && $0.IsDone == .pending}).count
            
        }
        cell.lblOverDueCount.text = taskOverDueCount == 0 ? "" : taskCount == 0 ? "" : "\(taskOverDueCount)"
        cell.lblTaskCount.text = taskCount == 0 ? "" : "\(taskCount) Task"
        cell.lblOverDueCount.isHidden = taskOverDueCount == 0 ? true : taskCount == 0 ? true : false
        cell.lblTaskCount.isHidden = taskCount == 0 ? true : false
        cell.imgFolderType.image = images.ic_folders()
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let folderArray = Array(realm.objects(FolderResponseModel.self).filter({$0.FolderName == "Inbox"}))
        if folderArray.count > 0 {
            redirectToTask(with: folderArray[0])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrFolders[indexPath.row]
       // let folderName = item.FolderName
        redirectToTask(with: item)
    }
    
    func redirectToTask(with name: FolderResponseModel?) {
        let transition = CATransition()
        transition.duration = 0.45
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
        folderSelected.onNext(name)
    }
  
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let folder = arrFolders[indexPath.row]
        let arrFolders = ["Inbox","All","Assign","Completed","Review"]
        if arrFolders.contains(folder.FolderName) {
            return false
        }
        return true

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let req = DeleteFolderRequest()
            req.folderID = arrFolders[indexPath.row].FolderId ?? ""
            let request = RequestBaseModel<DeleteFolderRequest>()
            request.data = req
            request.eventName = "DeleteFolder"
            request.accessToken = getAccessToken()
            self.deleteFolder(request: request, index: indexPath.row)
//            let item = arrFolders[indexPath.row]
//            try! realm.write {
//                realm.delete(item)
//            }
        }
    }
    
    //MARK:- API Call
    func deleteFolder(request: RequestBaseModel<DeleteFolderRequest>,index:Int) {
        
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
                        realm.delete(self.arrTasks.filter({$0.FolderName == self.arrFolders[index].FolderId}))
                        realm.delete(self.arrFolders[index])
                    }
                    TaskHelper.setAllTask()
                } else{
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: self)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: self)
            }
           
        }
    }
    
}
//MARK:- UISearchResultsUpdating

extension TaskFolderListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text)
        if searchController.searchBar.text!.isEmpty {
            arrFolders = setFolderNameWise()
        } else{
            arrFolders = Array(realm.objects(FolderResponseModel.self)).filter({$0.FolderName.lowercased().contains(searchController.searchBar.text?.lowercased() ?? "")})

        }
        tableView.reloadData()
    }
}


class TaskNavigationController: UINavigationController {
    
}
