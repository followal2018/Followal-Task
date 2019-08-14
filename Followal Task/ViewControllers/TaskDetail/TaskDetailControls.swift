//
//  TaskDetailControls.swift
//  followal
//
//  Created by Vivek Gadhiya on 11/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RxSwift

class TaskDetailControls: NSObject {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblFolderName: UILabel!

    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var lblRemindDate: UILabel!
    @IBOutlet weak var lblRepeatReminder: UILabel!
    @IBOutlet weak var lblStopRemider: UILabel!
    
    
    @IBOutlet weak var viewAssigner: UIView!
    @IBOutlet weak var viewReviewer: UIView!
    @IBOutlet weak var viewFiles: UIView!
    @IBOutlet weak var viewSubTask: UIView!

    @IBOutlet weak var tblSubTask: UITableView!
    @IBOutlet weak var heightOfTable: NSLayoutConstraint!

    @IBOutlet var viewUsers: [UIView]!
    @IBOutlet var btnAllMember: [UIButton]!
    @IBOutlet weak var tblAssignUser: UITableView!
    @IBOutlet weak var heightOfTableAssign: NSLayoutConstraint!
    
    @IBOutlet weak var tblReviewer: UITableView!
    @IBOutlet weak var heightOfTableReview: NSLayoutConstraint!
    
    @IBOutlet weak var tblSupporter: UITableView!
    @IBOutlet weak var heightOfTableSupport: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewAccept: UIView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    
    let disposeBag = DisposeBag()
    
    func setupUI() {
        tblSubTask.register(UINib.init(resource: nibs.subTaskTableViewCell), forCellReuseIdentifier: CellIdentifiers.cell)
        
        [tblAssignUser, tblReviewer, tblSupporter].forEach {
            $0?.register(UINib.init(resource: nibs.taskAssignTableViewCell), forCellReuseIdentifier: CellIdentifiers.cell)
            $0?.register(UINib.init(resource: nibs.userReminderHeaderCell), forCellReuseIdentifier: "headerCell")
        }
        btnAllMember.sort(by: { $0.tag < $1.tag })
        collectionView.register(UINib.init(resource: nibs.taskFilesCell), forCellWithReuseIdentifier: CellIdentifiers.cell)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        tblSubTask.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            self.heightOfTable.constant = self.tblSubTask.contentSize.height
        }).disposed(by: disposeBag)
        
        tblAssignUser.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            self.heightOfTableAssign.constant = self.tblAssignUser.contentSize.height
        }).disposed(by: disposeBag)
        
        tblReviewer.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            self.heightOfTableReview.constant = self.tblReviewer.contentSize.height
        }).disposed(by: disposeBag)
        
        tblSupporter.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            self.heightOfTableSupport.constant = self.tblSupporter.contentSize.height
        }).disposed(by: disposeBag)
    }
    
    func setDetail(_ task: Task) {
        
        lblTitle.text = task.TaskTitle
        lblDescription.text = task.Description
        if let folder = realm.objects(FolderResponseModel.self).filter({$0.FolderId == task.FolderName }).first {
            lblFolderName.text = folder.FolderName
        }

        let dateFormater = DateFormatter()
        dateFormater.dateFormat = DateFormats.DFddMMMyyyyhhmma
        lblDueDate.text = dateFormater.string(from: Date(milliseconds: Int64(task.Schedule.StartDate)!))
        lblRemindDate.text = dateFormater.string(from: Date(milliseconds: Int64(task.Schedule.DueDateAndTime)!))
        self.lblRepeatReminder.text = getRepeatReminderValue(task.Schedule)
        if task.Schedule.StopReminder != "" {
            lblStopRemider.text = dateFormater.string(from:Date(milliseconds: Int64(task.Schedule.StopReminder)!))
        }else{
             lblStopRemider.text = "Never"
        }
        if task.Files.toArray().count == 0 {
            viewFiles.isHidden = true
        }
        if task.Assigned.toArray().count == 0 {
            viewAssigner.isHidden = true
        }
        if task.Reviewer.toArray().count == 0 {
            viewReviewer.isHidden = true
        }
        if task.SubTask.toArray().count == 0 {
            viewSubTask.isHidden = true
        }
        tblSubTask.reloadData()
        tblReviewer.reloadData()
        tblAssignUser.reloadData()
        
        
//        if task.Assigned.isEmpty {
//            viewUsers.forEach { $0.isHidden = $0.tag == 0 }
//        } else {
//            btnAllMember[0].isHidden = task.Assigned.count <= 2
//        }
//        
//        if task.Reviewer.isEmpty {
//            viewUsers.forEach { $0.isHidden = $0.tag == 1 }
//        } else {
//            btnAllMember[1].isHidden = task.Reviewer.count <= 2
//        }
        
//        if task.supporter.isEmpty {
//            viewUsers.forEach { $0.isHidden = $0.tag == 2 }
//        } else {
//            btnAllMember[2].isHidden = task.supporter.count <= 2
//        }
    }
   
}
