//
//  TaskDetailViewController.swift
//  followal
//
//  Created by Vivek Gadhiya on 11/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift

class TaskDetailViewController: UIViewController {
    
    @IBOutlet weak var controls: TaskDetailControls!
    var btnEdit: UIBarButtonItem!
    var btnComment: UIBarButtonItem!

    
    var isEditMode = false
    let disposeBag = DisposeBag()
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setObserver()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let taskUpdate = realm.objects(Task.self).filter({$0.TaskLocalId == self.task.TaskLocalId}).first {
            self.task = taskUpdate
        }
        controls.setupUI()
        controls.setDetail(task)
        
    }
    
    func setupUI() {
        self.title = "View Task"
        //controls.viewAccept.isHidden = isEditMode
        btnEdit = UIBarButtonItem(image: images.ic_Edit()!, style: .done, target: self, action: nil)
        btnComment = UIBarButtonItem(image:images.ic_chat()!, style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItems = isEditMode ? [btnComment, btnEdit] : nil
        
    }
    
    func setObserver() {
        btnComment.rx.tap.subscribe(onNext: {
            let vc = board.task.taskCommentVC()!
            vc.task = self.task
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        btnEdit.rx.tap.subscribe(onNext: {
            let vc = board.task.addTaskVC()!
            vc.isEditMode = true
            vc.task = self.task
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }
    
    @IBAction func btnShowAllTapped(_ sender: UIButton) {
        let vc = board.task.userAssignVC()!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension TaskDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == controls.tblAssignUser {
            return task.Assigned.isEmpty ? 0 : 1
        } else if tableView == controls.tblReviewer {
            return task.Reviewer.isEmpty ? 0 : 1
        }
//        else if tableView == controls.tblSupporter {
//            return task.supporter.isEmpty ? 0 : 1
//        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == controls.tblAssignUser {
            return max(task.Assigned.count, 0)
        } else if tableView == controls.tblReviewer {
            return max(task.Reviewer.count, 0)
        }
//        else if tableView == controls.tblSupporter {
//            return min(task.supporter.count, 2)
//        }
        else {
            return task.SubTask.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == controls.tblSubTask {
            return 0
        } else if tableView == controls.tblAssignUser {
            if let taskAssigned = task.Assigned.first {
             if let _ = taskAssigned.Schedule {
                return task.Assigned.count == 0 ? 0 : 144
            }
            }
            return 0
        } else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == controls.tblAssignUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! UserReminderHeaderTableViewCell
            if  let taskAssigned = task.Assigned.first {
                if let schedule = taskAssigned.Schedule {
                    let dateFormater = DateFormatter()
                    dateFormater.dateFormat = DateFormats.DFddMMMyyyyhhmma
                    cell.lblDueDate.text = dateFormater.string(from: Date(milliseconds: Int64(schedule.DueDateAndTime)!))
                    cell.lblRemindDate.text = dateFormater.string(from: Date(milliseconds: Int64(schedule.RepeatReminderDate)!))
                    let repeatReminder = self.getRepeatReminder(schedule)
                    cell.lblRepeatReminder.text = repeatReminder == "" ? "Never" : repeatReminder
                    if schedule.StopReminder != "" {
                        cell.lblStopRemider.text = dateFormater.string(from:Date(milliseconds: Int64(schedule.StopReminder)!))
                    }
                }
            }
            return cell.contentView
        } else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == controls.tblAssignUser {
            let user = task.Assigned[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cell) as! TaskAssignTableViewCell
            cell.btnCancel.isHidden = true
            cell.setDetail(user)
            return cell
        } else if tableView == controls.tblReviewer {
            let user = task.Reviewer[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cell) as! TaskAssignTableViewCell
            cell.btnCancel.isHidden = true
            cell.setDetail(user)
            return cell
        }
//        else if tableView == controls.tblSupporter {
//            let user = task.supporter[indexPath.row]
//            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cell) as! TaskAssignTableViewCell
//            cell.btnCancel.isHidden = true
//            cell.setDetail(user)
//            return cell
//        }
        else if tableView == controls.tblSubTask {
            let subTask = task.SubTask[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cell) as! SubTaskTableViewCell
            cell.btnCancel.isHidden = true
            cell.lblName.text = subTask.Task
            cell.btnCheck.isSelected = subTask.IsDone.intValue == 0 ? false : true
            cell.btnCheck.rx.tap.subscribe(onNext: {
                try! realm.write {
                    let status = subTask.IsDone == .pending ? 1 : 0
                    TaskHelper.subTaskStatus(task: self.task, subtask: subTask, status: status)
                    self.task.SubTask[indexPath.row].IsDone = subTask.IsDone == .pending ? .done : .pending
                }
                self.controls.tblSubTask.reloadData()
            }).disposed(by: cell.disposeBag)
            return cell
        }
        return UITableViewCell()

    }
}

extension TaskDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return task.Files.toArray().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TaskFilesCollectionViewCell
        cell.viewAttachFile.isHidden = true
        cell.imgThumb.backgroundColor = .gray
        cell.imgThumb.alpha = 1.0
        let strFileURL = task.Files.toArray()[indexPath.row]
        cell.imgThumb.sd_setImage(with: (webUrls.hostURL() + strFileURL).toURL(), completed: nil)
        //(with: (webUrls.hostURL() + strFileURL).toURL(), placeholderImage: images.ic_user_placeholder(), options: .progressiveDownload, completed: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 100)
    }
}
