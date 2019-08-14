//
//  RepeatAlarmViewController.swift
//  Alarm Module
//
//  Created by iMac on 01/04/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import RxSwift
let ArrayOfDays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
let ArrayOfMonths = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]
var ArrayOfAlarmsType = ["General","Habit","Sunrise and Sunset","GPS","Memories"]
var ArrayOfRepeatReminders = ["Never","Every Sunday","Every Monday","Every Tuesday","Every Wedneday","Every Thursday","Every Friday","Every Saturday"]

let IS_IPHONE_X = UIScreen.main.bounds.height == 812.0
let IS_IPHONE_XR = UIScreen.main.bounds.height == 896.0

func updateBottomLayout(Constraint: NSLayoutConstraint, view: UIView) {
    if IS_IPHONE_X {
        Constraint.constant = 20
    } else if IS_IPHONE_XR {
        Constraint.constant = 25
    } else {
        Constraint.constant = 0
    }
    view.layoutIfNeeded()
}
protocol RepeatAlarmViewControllerDelegate{
    func didSelectRepeatReminder(_ str:String,type:RepeatIntervalType, days:[Int], months:[Int])
}

class RepeatAlarmViewController: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var rightArrow: UIImageView!
    var selectedDayIndex = [Int]()
    var customData: [String:Any] = [:]
    var disposeBag = DisposeBag()

    var selectedDays = PublishSubject<[DateComponents]>()
    var customDataObserver = PublishSubject<[String: Any]>()
    var isCustomRepeat = false
    var delegate: RepeatAlarmViewControllerDelegate?

    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Localization.repeat.key
        self.tableView.tableFooterView = UIView()
        
//        self.navigationController?.navigationBar.isTranslucent = false
        let tab = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed))
        self.navigationItem.rightBarButtonItem = tab
        self.customView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openCustomRepeatView)))
        self.rightArrow.image = self.rightArrow.image?.imageWithColor(color1: UIColor.lightGray)
        
    }
    //MARK:- UIButton Action Methods
    @objc func openCustomRepeatView() {
        let vc = board.task.repeatIntervalViewController()!
        vc.customData = customData
        vc.delegate = self
        vc.customDataObserver.subscribe(onNext: { (interval) in
            print(interval)
            vc.navigationController?.popViewController(animated: false)
            self.customDataObserver.onNext(interval)

        }).disposed(by: disposeBag)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func doneButtonPressed() {
        let finalarr = Array(ArrayOfRepeatReminders.filter{self.selectedDayIndex.contains(ArrayOfRepeatReminders.firstIndex(of: $0)!)})
        //delegate?.didSelectRepeatReminder(finalarr.joined(separator: ","),RepeatIntervalType.week,self.selectedDayIndex)
        let strRepeat = finalarr.joined(separator: ",")
        let repeatType = strRepeat == "Never" ? RepeatIntervalType.never : RepeatIntervalType.week
        delegate?.didSelectRepeatReminder(strRepeat, type: repeatType, days: self.selectedDayIndex, months: [])
        self.navigationController?.popViewController(animated: true)
    }
}

extension RepeatAlarmViewController: RepeatAlarmViewControllerDelegate {
    func didSelectRepeatReminder(_ str:String,type:RepeatIntervalType, days:[Int], months:[Int]){
        delegate?.didSelectRepeatReminder(str, type: type, days: days, months: months)
    }
}
//MARK:- UITableViewDelegate, UITableViewDataSource
extension RepeatAlarmViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrayOfRepeatReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.repeatAlarmDayCell) as! RepeatAlarmDayCell
        cell.lblDayRepeat.text = ArrayOfRepeatReminders[indexPath.row]
        cell.accessoryType = selectedDayIndex.contains(indexPath.row) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedDayIndex.contains(indexPath.row) == false {
            if indexPath.row == 0 {
                self.selectedDayIndex.removeAll()
            } else {
                if let IndexOfNever = self.selectedDayIndex.firstIndex(of: 0) {
                    self.selectedDayIndex.remove(at: IndexOfNever)
                }
            }
            self.selectedDayIndex.append(indexPath.row)
        } else if let index = self.selectedDayIndex.firstIndex(of: indexPath.row) {
            self.selectedDayIndex.remove(at: index)
        }
        tableView.reloadData()
    }
}
