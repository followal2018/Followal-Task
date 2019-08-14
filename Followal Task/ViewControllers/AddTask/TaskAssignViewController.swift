//
//  TaskAssignViewController.swift
//  followal
//
//  Created by Vivek Gadhiya on 09/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift


class TaskAssignViewController: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Variable
    var isViewMode = false
    var contacts: [Contact] = []
    var disposeBag = DisposeBag()
    var contactCompletion = PublishSubject<()>()
    var btnDone: UIBarButtonItem!
    var type = 0

    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(resource: nibs.taskAssignTableViewCell), forCellReuseIdentifier: CellIdentifiers.cell)
        btnDone = UIBarButtonItem(title: Localization.done.key.localized, style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = isViewMode ? nil : btnDone
        if type == 0 {
            self.title = Localization.assignUser.key.localized
        } else if type == 1 {
            self.title = Localization.reviewer.key.localized
        } else {
            self.title = Localization.supporter.key.localized
        }
        btnDone.rx.tap.subscribe(onNext: {
            let vc = board.task.taskRemiderVC()!
            vc.remiderCompletion.subscribe(onNext: {
                self.contactCompletion.onNext(())
            }).disposed(by: self.disposeBag)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension TaskAssignViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isViewMode ? contacts.count : contacts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cell) as! TaskAssignTableViewCell
        
        cell.btnCancel.isHidden = indexPath.row == contacts.count
        
        if indexPath.row == contacts.count {
            cell.lblName.text = Localization.addUser.key.localized
            cell.imgUserProfile.image = images.ic_task_add_user()
        } else {
            let item = contacts[indexPath.row]
            cell.lblName.text = item.name
            cell.btnCancel.isHidden = isViewMode
          //  cell.imgUserProfile.sd_setImage(with: MessageHelper.getUserAvatar(of: item.userID), placeholderImage: images.ic_user_placeholder(), options: .highPriority, completed: nil)
            cell.btnCancel.rx.tap.subscribe(onNext: {
                self.contacts.remove(at: indexPath.row)
                self.tableView.reloadData()
            }).disposed(by: cell.disposeBag)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == contacts.count {
//            let vc = board.chat.contactListVC()!
//            vc.markedContact = self.contacts
//            vc.isSelectionMode = true
//            vc.selectedContacts.subscribe(onNext: { (contacts) in
//                self.contacts = contacts
//                self.tableView.reloadData()
//                self.dismiss(animated: true, completion: nil)
//            }).disposed(by: self.disposeBag)
//            let nvc = UINavigationController(rootViewController: vc)
//            self.present(nvc, animated: true, completion: nil)
        }
    }
    
}
