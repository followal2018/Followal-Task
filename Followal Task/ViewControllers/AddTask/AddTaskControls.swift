//
//  AddTaskControls.swift
//  followal
//
//  Created by Vivek Gadhiya on 08/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift

class AddTaskControls: NSObject {
    
    @IBOutlet weak var txtFolder: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    @IBOutlet weak var btnAddReviewer: UIButton!
    @IBOutlet weak var btnAssignToUser: UIButton!
    @IBOutlet weak var btnAddFiles: UIButton!

    @IBOutlet weak var txtDueDate: UITextField!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtRepeatReminder: UITextField!
    @IBOutlet weak var txtStopRemider: UITextField!
    
    @IBOutlet weak var tblTask: UITableView!
    @IBOutlet weak var heightOfTable: NSLayoutConstraint!
    @IBOutlet weak var txtSubTask: UITextField!
    @IBOutlet weak var btnAddSubTask: UIButton!
    
    @IBOutlet var viewUsers: [UIView]!
    @IBOutlet weak var tblAssignUser: UITableView!
    @IBOutlet weak var heightOfTableAssign: NSLayoutConstraint!
    
    @IBOutlet weak var tblReviewer: UITableView!
    @IBOutlet weak var heightOfTableReview: NSLayoutConstraint!

    @IBOutlet weak var tblSupporter: UITableView!
    @IBOutlet weak var heightOfTableSupport: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnAddTask: UIButton!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!

    let disposeBag = DisposeBag()

    func setupUI() {
        tblTask.register(UINib.init(resource: nibs.subTaskTableViewCell), forCellReuseIdentifier: CellIdentifiers.cell)
        
        [tblAssignUser, tblReviewer, tblSupporter].forEach {
            $0.register(UINib.init(resource: nibs.taskAssignTableViewCell), forCellReuseIdentifier: CellIdentifiers.cell)
        }
    
        collectionView.register(UINib.init(resource: nibs.taskFilesCell), forCellWithReuseIdentifier: CellIdentifiers.cell)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        tblTask.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            self.heightOfTable.constant = self.tblTask.contentSize.height
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
    
    
   
}
