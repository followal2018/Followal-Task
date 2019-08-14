//
//  RepeatIntervalViewController.swift
//  Alarm Module
//
//  Created by iMac on 01/04/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import RxSwift
import IQKeyboardManagerSwift

class RepeatIntervalViewController: UIViewController {
    
    @IBOutlet weak var repeatIntervalView: UIView!
    @IBOutlet weak var lblRepeatInterval: UILabel!
    @IBOutlet weak var repeatEveryView: UIView!
    @IBOutlet weak var viewDays: UIView!
    @IBOutlet weak var daysCollectionView: UICollectionView!
    @IBOutlet weak var viewMonth: UIView!
    @IBOutlet weak var monthCollectionView: UICollectionView!
    @IBOutlet weak var repeatRightArrow: UIImageView!
    @IBOutlet weak var lblRepeatIntervalTime: UILabel!
    
    @IBOutlet weak var heightOfDayCollection: NSLayoutConstraint!
    @IBOutlet weak var heightOfMonthCollection: NSLayoutConstraint!
    @IBOutlet weak var repeatRightArrowTwo: UIImageView!
    
    var selectedDayIndex = [Int]()
    var selectedMonthIndex = [Int]()
    var delegate:RepeatAlarmViewControllerDelegate?
    //var isMonthSelected = Bool()
    var selectedIndex = 0
    
    var disposeBag = DisposeBag()
    
    var customData: [String: Any] = [:]
    var customDataObserver = PublishSubject<[String: Any]>()
    var repeatIntervalType:RepeatIntervalType = .never
    var arryOfDays: [Int] = []
    var arrayOfWeeks: [Int] = []
    var arrayOfMonths: [Int] = []
    
    //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
  
        fillData()
        
        daysCollectionView.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            self.heightOfDayCollection.constant = size?.height ?? 0
        }).disposed(by: disposeBag)
        
        monthCollectionView.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            self.heightOfMonthCollection.constant = size?.height ?? 0
        }).disposed(by: disposeBag)
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.isTranslucent = false
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        self.navigationItem.setRightBarButton(btnDone, animated: true)
        self.repeatRightArrow.image = self.repeatRightArrow.image?.imageWithColor(color1: UIColor.lightGray)
        self.repeatRightArrowTwo.image = self.repeatRightArrowTwo.image?.imageWithColor(color1: UIColor.lightGray)
        self.repeatIntervalView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openRepeatInervalPopup)))
        self.repeatEveryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openRepeatEveryPopup)))
        
        btnDone.rx.tap.subscribe(onNext: {
            if self.lblRepeatInterval.text! == "Daily" {

                let val = Int(self.lblRepeatIntervalTime.text!.components(separatedBy: " ")[0])!
                let interval = val * 86400
                self.delegate?.didSelectRepeatReminder("", type: RepeatIntervalType.day, days: [val], months: [])

                print("Days selected \(interval)")
                self.customDataObserver.onNext(["type" : "Day", "value" : interval])
            } else if self.lblRepeatInterval.text! == "Week" {

                if self.selectedDayIndex.isEmpty {
                    showAlertView(with: "Please select at least one day", viewController: self)
                    return
                }
                self.delegate?.didSelectRepeatReminder("", type: RepeatIntervalType.week, days: self.selectedDayIndex.map({return $0+1}), months: [])

                
                var dateComponents: [DateComponents] = []
                
                for i in self.selectedDayIndex {
                    print(i)
                    let date = Date().add(.day, value: i)!
                    var component = Calendar.current.dateComponents([.weekday], from: date)
                    component.weekday = i + 1
                    dateComponents.append(component)
                }

                print(dateComponents)
                self.customDataObserver.onNext(["type" : "Week", "value" : dateComponents])
            } else if self.lblRepeatInterval.text! == "Month" {

                if self.selectedDayIndex.isEmpty {
                    showAlertView(with: "Please select at least one day", viewController: self)
                    return
                }
                self.delegate?.didSelectRepeatReminder("", type: RepeatIntervalType.month, days:  self.selectedDayIndex.map({return $0+1}), months: [])

                let dateComponents = self.selectedDayIndex.sorted().map { (value) -> DateComponents in
                    var component = DateComponents()
                    component.day = value + 1
                    return component
                }
                self.customDataObserver.onNext(["type" : "Month", "value" : dateComponents])
                print(dateComponents)
            } else if self.lblRepeatInterval.text! == "Year" {

                if self.selectedDayIndex.isEmpty {
                    showAlertView(with: "Please select at least one day", viewController: self)
                    return
                }
                
                if self.selectedMonthIndex.isEmpty {
                    showAlertView(with: "Please select at least one month", viewController: self)
                    return
                }
                self.delegate?.didSelectRepeatReminder("", type: RepeatIntervalType.year, days:  self.selectedDayIndex.map({return $0+1}), months: self.selectedMonthIndex.map({return $0+1}))

                let dateComponents = self.selectedDayIndex.sorted().map { (value) -> DateComponents in
                    var component = DateComponents()
                    component.day = value + 1
                    return component
                }
                
                var finalComponent: [DateComponents] = []
                for monthIndex in self.selectedMonthIndex.sorted() {
                    let tempComponent = dateComponents.map { value -> DateComponents in
                        var component = value
                        component.month = monthIndex + 1
                        return component
                    }
                    finalComponent.append(contentsOf: tempComponent)
                }
            
                self.customDataObserver.onNext(["type" : "Year", "value" : finalComponent])
            }
        }).disposed(by: disposeBag)
    }
    
    func fillData() {

        if let type = customData["type"] as? String {
            if type == "Day" {
                self.lblRepeatInterval.text = "Daily"
                repeatEveryView.isHidden = false
                self.viewDays.isHidden = true
                if let value = customData["value"] as? Int {
                    let day = value / 86400
                    if day == 1 {
                        self.lblRepeatIntervalTime.text = "\(day) Day"
                    } else {
                        self.lblRepeatIntervalTime.text = "\(day) Days"
                    }
                }
                selectedIndex = 0
            } else if type == "Week" {
                self.lblRepeatInterval.text = "Week"
                repeatEveryView.isHidden = true
                self.viewDays.isHidden = false
                if let value = customData["value"] as? [DateComponents] {
                    self.selectedDayIndex = value.map { $0.weekday! - 1 }
                }
                selectedIndex = 1
                self.daysCollectionView.delegate = self
                self.daysCollectionView.dataSource = self
                self.daysCollectionView.reloadData()
            } else if type == "Month" { //TODO: - When select 31 date and Month have 30 days then check crash
                self.lblRepeatInterval.text = "Month"
                selectedIndex = 2
                repeatEveryView.isHidden = true
                if let value = customData["value"] as? [DateComponents] {
                    self.selectedDayIndex = value.map { $0.day! - 1 }
                }
                self.viewDays.isHidden = false
                self.daysCollectionView.delegate = self
                self.daysCollectionView.dataSource = self
                self.daysCollectionView.reloadData()
            } else if type == "Year" {
                self.lblRepeatInterval.text = "Year"
                selectedIndex = 3
                repeatEveryView.isHidden = true
                if let value = customData["value"] as? [DateComponents] {
                    let days = Set(value.map { $0.day! - 1 })
                    let months = Set(value.map { $0.month! - 1 })
                    self.selectedDayIndex = Array(days)
                    self.selectedMonthIndex = Array(months)
                }
                self.viewMonth.isHidden = false
                self.viewDays.isHidden = false
                self.daysCollectionView.delegate = self
                self.daysCollectionView.dataSource = self
                self.daysCollectionView.reloadData()
                self.monthCollectionView.reloadData()
            }
            self.view.layoutIfNeeded()
        } else {
            self.lblRepeatIntervalTime.text = "1 Day"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Repeat"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    @objc func openRepeatInervalPopup() {
        let vc = R.storyboard.task
            .repeatIntervalPopupViewController()!
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .flipHorizontal
        vc.delegate = self
        vc.isNumberFormatPicker = false
        if let value = self.lblRepeatInterval.text {
            vc.selectedInterval = value
            vc.isWeek = value.contains("Week")
        }
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc func openRepeatEveryPopup() {
        let vc = R.storyboard.task.repeatIntervalPopupViewController()!
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        vc.isNumberFormatPicker = true
        if let value = self.lblRepeatIntervalTime.text {
            vc.selectedInterval = value
        }
        if let value = self.lblRepeatInterval.text {
            vc.isWeek = value.contains("Week")
        }
        self.present(vc, animated: false, completion: nil)
    }
    
    func getDaysOfCurrentMonth() -> Int {
        let calendar = Calendar.current
        let dateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    @objc func doneButtonPressed() {
        let finalarr = Array(ArrayOfRepeatReminders.filter{self.selectedDayIndex.contains(ArrayOfRepeatReminders.firstIndex(of: $0)!)})
        //delegate?.didSelectRepeatReminder(finalarr.joined(separator: ","),RepeatIntervalType.week,self.selectedDayIndex)
        delegate?.didSelectRepeatReminder(finalarr.joined(separator: ","), type: RepeatIntervalType.week, days: self.selectedDayIndex,  months: [])
        self.navigationController?.popViewController(animated: true)
    }
}

extension RepeatIntervalViewController: RepeatIntervalSelectionDelegate {
    
    func didselectedRepeatentervaltime(with interval: String, isNumberFormatPicker: Bool, selectedIndex: Int) {
        
        if !isNumberFormatPicker {
        if interval == "Week" {
            repeatIntervalType = .week
        } else if interval == "Daily" {
            repeatIntervalType = .day
        } else if interval == "Month" {
            repeatIntervalType = .month
        }  else if interval == "Year" {
            repeatIntervalType = .year
        }
        } else{
            arryOfDays = [Int(interval)] as! [Int]
        }
       
        if isNumberFormatPicker {
            var isMultipleValue = Bool()
            if let value = Int(interval) as? Int {
                if value > 1 {
                    isMultipleValue = true
                }
            } else {
                isMultipleValue = false
            }
            if lblRepeatInterval.text!.contains("Daily") {
                self.lblRepeatIntervalTime.text = interval + " Day"
                if isMultipleValue {
                    self.lblRepeatIntervalTime.text = self.lblRepeatIntervalTime.text! + "s"
                }
            } else {
                self.lblRepeatIntervalTime.text = interval + " " + self.lblRepeatInterval.text!
                if isMultipleValue {
                    self.lblRepeatIntervalTime.text = self.lblRepeatIntervalTime.text! + "s"
                }
            }
        } else {
            self.lblRepeatInterval.text = interval
            var suffixValue = ""
            if interval.contains("Daily") {
                suffixValue = "Day"
                repeatEveryView.isHidden = false
            } else {
                suffixValue = interval
                repeatEveryView.isHidden = true
            }
            if self.lblRepeatIntervalTime.text!.components(separatedBy: " ").count > 1 {
                let val = Int(self.lblRepeatIntervalTime.text!.components(separatedBy: " ")[0])!
                if val  > 1 {
                    self.lblRepeatIntervalTime.text = self.lblRepeatIntervalTime.text!.components(separatedBy: " ")[0] + " " + suffixValue + "s"
                } else {
                    self.lblRepeatIntervalTime.text = self.lblRepeatIntervalTime.text!.components(separatedBy: " ")[0] + " " + suffixValue
                }
            } else {
                self.lblRepeatIntervalTime.text = "1 Day"
            }
            self.viewDays.isHidden = selectedIndex > 0 ? false : true // If day then hide Days selection view
            self.viewMonth.isHidden = selectedIndex != 3
            self.selectedIndex = selectedIndex
            
            self.selectedDayIndex.removeAll()
            self.selectedMonthIndex.removeAll()
            if selectedIndex == 1 {
                let component = Calendar.current.component(Calendar.Component.weekday, from: Date())
                selectedDayIndex.append(component - 1)
            }
            self.view.layoutIfNeeded()
            self.daysCollectionView.delegate = self
            self.daysCollectionView.dataSource = self
            self.daysCollectionView.reloadData()
            self.monthCollectionView.reloadData()
        }
    }
}
extension RepeatIntervalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == daysCollectionView {
            if selectedIndex == 1 {
                return ArrayOfDays.count
            } else if selectedIndex == 2 {
                return getDaysOfCurrentMonth()
            } else {
                return getDaysOfCurrentMonth()
            }
        } else {
            return selectedIndex == 3 ? ArrayOfMonths.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath)
        if let titleView = cell.contentView.viewWithTag(101) as? UILabel {
            if collectionView == daysCollectionView {
                if selectedIndex == 1 {
                    titleView.text = ArrayOfDays[indexPath.row].first!.description
                } else if selectedIndex == 2 {
                    titleView.text = (indexPath.row + 1).description
                } else if selectedIndex == 3 {
                    titleView.text = (indexPath.row + 1).description
                }
                titleView.backgroundColor = selectedDayIndex.contains(indexPath.row) ? UIColor.init(hexString: "E4E4E4") : UIColor.init(hexString: "FFFFFF")
            } else {
                titleView.text = ArrayOfMonths[indexPath.row]
                titleView.backgroundColor = selectedMonthIndex.contains(indexPath.row) ? UIColor.init(hexString: "E4E4E4") : UIColor.init(hexString: "FFFFFF")
            }
            titleView.layer.masksToBounds = true
            titleView.layer.borderWidth = 1.0
            titleView.layer.borderColor = UIColor.init(hexString: "385E7C").cgColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7 - 1
        if collectionView == daysCollectionView {
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: collectionView.frame.width / 4 - 1, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == daysCollectionView {
            if self.selectedDayIndex.contains(indexPath.row) == false {
                self.selectedDayIndex.append(indexPath.row)
            } else if let index = self.selectedDayIndex.firstIndex(of: indexPath.row) {
                self.selectedDayIndex.remove(at: index)
            }
        } else {
            if self.selectedMonthIndex.contains(indexPath.row) == false {
                self.selectedMonthIndex.append(indexPath.row)
            } else if let index = self.selectedMonthIndex.firstIndex(of: indexPath.row) {
                self.selectedMonthIndex.remove(at: index)
            }
        }
    
        collectionView.reloadData()
    }
}
