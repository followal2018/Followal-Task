//
//  SubTaskListViewController.swift
//  Followal Task
//
//  Created by iMac on 03/08/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit

class SubTaskListViewController: UIViewController {

    
    @IBOutlet weak var tblView: UITableView!
    var task:Task!
    var arrSubtasks : [SubTask]!
    
    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib.init(resource: nibs.subTaskTableViewCell), forCellReuseIdentifier: "Cell")
        arrSubtasks = task.SubTask.toArray()
        self.title = task.TaskTitle + "'s " + "Subtasks"
        tblView.tableFooterView = UIView(frame: .zero)
     }
       

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK:- UITableViewDataSource, UITableViewDelegate

extension SubTaskListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSubtasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subTask = arrSubtasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SubTaskTableViewCell
        cell.btnCancel.isHidden = true
        cell.lblName.text = subTask.Task
        cell.btnCheck.isSelected = subTask.IsDone == .pending ? false : true
        cell.btnCheck.rx.tap.subscribe(onNext: {
            try! realm.write {
                let status = subTask.IsDone == .pending ? 1 : 0
                TaskHelper.subTaskStatus(task: self.task, subtask: subTask, status: status)
                self.task.SubTask[indexPath.row].IsDone = subTask.IsDone == .pending ? .done : .pending
            }
            self.tblView.reloadData()
        }).disposed(by: cell.disposeBag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
 }
