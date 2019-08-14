//
//  TaskUserStatusListViewController.swift
//  followal
//
//  Created by Vivek Gadhiya on 11/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TaskUserStatusListViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var disposeBag = DisposeBag()
    
    var userList = BehaviorRelay<[UserResponseModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Info"

        segmentControl.rx.value.subscribe(onNext: { (index) in
            print(index)
        }).disposed(by: disposeBag)
        
        userList.asObservable().bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: TaskAssignTableViewCell.self)) { row, element, cell in
            cell.setDetail(element)
        }.disposed(by: disposeBag)
    }


}
