//
//  SelectTimeViewController.swift
//  Alarm Module
//
//  Created by iMac on 30/03/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import RxSwift

protocol TimeSelectionDelegate {
    func didSelectedTime(with date: Date)
}

protocol RepeatIntervalSelectionDelegate {
    func didselectedRepeatentervaltime(with interval: String, isNumberFormatPicker: Bool,selectedIndex: Int)
}
protocol SnoozeSelectionDelegate {
    func didSelectedSnoozeTime(with snoozeTime: String)
}

protocol HabitCategorySelectionDelegate {
    func didSelectedHabitCategory(with categoryName: String)
}
class SelectTimeViewController: UIViewController {
    
    //MARK:- Outlet
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    @IBOutlet weak var timePickerView: UIDatePicker!
    @IBOutlet weak var mainView: UIView!
    
    //MARK:- Variable
    var currentDate: Date?
    var datePicketMode: UIDatePicker.Mode = .date
    let selectedDate = PublishSubject<Date>()
    
    
    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DateComponents()
        updateBottomLayout(Constraint: self.bottomHeight, view: self.view)
        self.mainView.isHidden = true
        UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveEaseInOut, animations: {
            self.mainView.isHidden = false
            self.timePickerView.datePickerMode = self.datePicketMode
            self.timePickerView.date = self.currentDate ?? Date()
        }, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 3.0, animations: {
            self.view.backgroundColor = UIColor.init(hexString: HexString.hex_000000).withAlphaComponent(0.5)
        })
    }
    
    //MARK:- UIButton Actions
    @IBAction func saveTapped(_ sender: UIButton) {
        selectedDate.onNext(self.timePickerView.date)
        self.dismiss(animated: false) {
            
        }
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}

