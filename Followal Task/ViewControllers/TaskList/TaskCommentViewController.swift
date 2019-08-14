//
//  TaskCommentViewController.swift
//  Followal Task
//
//  Created by iMac on 03/08/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import KMPlaceholderTextView
import ObjectMapper
import SwiftyJSON


class TaskCommentViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tfComment: KMPlaceholderTextView!
    @IBOutlet weak var btnSend: UIButton!
    
    //MARK:- Variables
    var task:Task!
    var arrComments = [Comment]()
    let disposeBag = DisposeBag()
    
    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    func setupUI(){
        tblView.register(UINib.init(resource: nibs.commentTableViewCell), forCellReuseIdentifier: "Cell")
        self.title = task.TaskTitle + "'s " + "Comments"
        
        btnSend.rx.tap.subscribe(onNext: {
            if self.tfComment.text!.isEmpty {
                
            } else{
                let req = CommentRequest()
                req.taskId = self.task.TaskLocalId
                req.comment = self.tfComment.text ?? ""
                let request = RequestBaseModel<CommentRequest>()
                request.data = req
                request.eventName = "AddComment"
                request.accessToken = getAccessToken()
                self.createCommnet(request: request)
//                let comment = Comment()
//                comment.commentID = UUID.init().uuidString
//                comment.taskID = self.task.TaskLocalId
//                comment.commentText = self.tfComment.text ?? ""
//                comment.createTime = "\(Date().millisecondsSince1970)"
//                comment.userID = getUserID()
//                comment.userName = getUserDetail(forKey: "UserName") == "" ? getUserDetail(forKey: "EmailAddress") : getUserDetail(forKey: "UserName")
//
//                try! realm.write {
//                    realm.add(comment,update: true)
//                }
                self.scrollToBottom()
            }
        }).disposed(by: disposeBag)
        self.arrComments = Array(realm.objects(Comment.self).filter("taskID == %@",self.task.TaskLocalId))
        if arrComments.count == 0 {
            let req = CommentRequest()
            req.taskId = self.task.TaskLocalId
            let request = RequestBaseModel<CommentRequest>()
            request.data = req
            request.eventName = "GetCommentData"
            request.accessToken = getAccessToken()
            self.getAllCommnet(request: request)
        }
        realmObserver()
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            if !self.arrComments.isEmpty {
                let indexPath = IndexPath(row: self.arrComments.count - 1, section: 0)
                self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    //MARK:- Realm observer
    var notificationToken: NotificationToken? = nil
    
    func realmObserver() {
        
        // Observe Results Notifications
        let results = realm.objects(Comment.self).filter("taskID == %@",task.TaskLocalId)
      
        // let results = realm.objects(Task.self)
        //  MessageHelper.syncMessage()
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tblView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                print(results)
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                self!.arrComments = Array(realm.objects(Comment.self).filter("taskID == %@",self!.task.TaskLocalId))
                self!.tblView.reloadData()
//                tableView.performBatchUpdates({
//                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
//                                         with: .none)
//                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
//                                         with: .none)
//                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
//                                         with: .none)
//                  //  tableView.reloadData()
//                }, completion: { (success) in
//                })
                
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    //MARK:- API
    func createCommnet(request: RequestBaseModel<CommentRequest>) {
        
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
                    if let dataUser = jsonData["Data"].dictionaryObject as? [String : Any] {
                        if let comment = Mapper<Comment>().map(JSONObject: dataUser){
                        let realm = try! Realm()
                        try realm.write {
                            realm.add(comment, update: true)
                        }
                            self.tfComment.text = ""
                    }
                }
                } else{
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: self)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: self)
            }
            
            
        }
    }
    
    func getAllCommnet(request: RequestBaseModel<CommentRequest>) {
        
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
                        let comments = Mapper<Comment>().mapArray(JSONArray:dataUser)
                        let realm = try! Realm()
                        try realm.write {
                            realm.add(comments, update: true)
                        }
                    }
                    
                } else{
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: self)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: self)
            }
            
            
        }
    }
    func deleteComment(request: RequestBaseModel<DeleteCommentRequest>,index:Int) {
        
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
                        realm.delete(self.arrComments[index])
                    }
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

extension TaskCommentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommentTableViewCell
        let obj = arrComments[indexPath.row]
        cell.lblDesc.text = obj.commentText
        if obj.userID == getUserID() {
            cell.lblUserName.text =  "You"
            if let userProfileURL = getUserDetail(forKey: "Profile") as? String{
                let strURL =  userProfileURL
                cell.imgUsername.sd_setImage(with: URL(string: strURL), placeholderImage:images.ic_user_placeholder(), options: [.progressiveLoad], context: nil)
                
            }
            
        } else if let userData = task.Assigned.first {
            if userData.UserId == obj.userID {
                cell.lblUserName.text =  userData.UserName == "" ? userData.EmailAddress : userData.UserName
                cell.imgUsername.sd_setImage(with: URL(string: userData.Profile), placeholderImage:images.ic_user_placeholder(), options: [.progressiveLoad], context: nil)
                
            } else if let userDataReview = task.Reviewer.first {
                if userDataReview.UserId == obj.userID {
                    cell.lblUserName.text =  userDataReview.UserName == "" ? userDataReview.EmailAddress : userDataReview.UserName
                    cell.imgUsername.sd_setImage(with: URL(string:  userDataReview.Profile), placeholderImage:images.ic_user_placeholder(), options: [.progressiveLoad], context: nil)
                    
                }
            }
        }
        if obj.createTime != 0 {
            cell.lblHourAgo.text = Date(milliseconds:obj.createTime).datePhraseTime(withFormat: DateFormats.DFhhmmaddmmyyyy)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let obj = arrComments[indexPath.row]
        if obj.userID == getUserID() {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
            let deleteAction = UIContextualAction(style: .normal, title:  Localization.delete.key.localized, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                let req = DeleteCommentRequest()
                req.taskId = self.arrComments[indexPath.row].taskID
                req.commentId = self.arrComments[indexPath.row].commentID
                let request = RequestBaseModel<DeleteCommentRequest>()
                request.data = req
                request.eventName = "DeleteComment"
                request.accessToken = getAccessToken()
                self.deleteComment(request: request, index: indexPath.row)
                
                success(true)
            })
            deleteAction.backgroundColor = Colors.red
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
