//
//  RepeatIntervalPopupViewController.swift
//  Alarm Module
//
//  Created by iMac on 01/04/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class RepeatIntervalPopupViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var selectedInterval = ""
    var selectedIndex = 0
    var isWeek = Bool()
    var isNumberFormatPicker = Bool()
    var delegate: RepeatIntervalSelectionDelegate?
    
    let repeatIntervalArray = ["Day","Week","Month","Year"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBottomLayout(Constraint: self.bottomHeight, view: self.view)
        updateBottomLayout(Constraint: self.bottomHeight, view: self.view)
        self.mainView.isHidden = true
        
        UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveEaseIn, animations: {
            self.mainView.isHidden = false
        }, completion: nil)
        UIView.transition(with: self.view, duration: 1.0, options: UIView.AnimationOptions.transitionFlipFromBottom, animations: {
            self.mainView.isHidden = false
        }, completion: nil)
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        if self.selectedInterval != "" {
            if isNumberFormatPicker == false {
                if self.selectedInterval == "Week" {
                    self.selectedIndex = 1
                    self.pickerView.selectRow(1, inComponent: 0, animated: true)
                } else if self.selectedInterval == "Month" {
                    self.selectedIndex = 2
                    self.pickerView.selectRow(2, inComponent: 0, animated: true)
                } else if self.selectedInterval == "Year" {
                    self.selectedIndex = 3
                    self.pickerView.selectRow(3, inComponent: 0, animated: true)
                }
                self.titleLabel.text = self.selectedInterval == "Daily" ? "Every Day" : "Every " + self.selectedInterval
            } else {
                var row = 0
                for index in 0 ..< 53 {
                    let value = selectedInterval.description.components(separatedBy: " ")[0]
                    if value == index.description {
                        row = index - 1
                    }
                }
                if self.selectedInterval.components(separatedBy: " ").count > 1 {
                    self.titleLabel.text = self.selectedInterval == "Daily" ? "Every Day" : "Every " + self.selectedInterval.components(separatedBy: " ")[1]
                } else {
                    self.titleLabel.text = self.selectedInterval == "Daily" ? "Every Day" : "Every " + self.selectedInterval
                }
                self.selectedInterval = (row+1).description
                self.pickerView.selectRow(row, inComponent: 0, animated: true)
            }
        } else {
            self.pickerView.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor.init(hexString: "000000").withAlphaComponent(0.5)
        })
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.delegate?.didselectedRepeatentervaltime(with: self.selectedInterval, isNumberFormatPicker: self.isNumberFormatPicker, selectedIndex: self.selectedIndex)
        }
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}
extension RepeatIntervalPopupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isNumberFormatPicker {
            if isWeek {
                return 53
            } else if self.selectedInterval.contains("day") {
                return 31
            } else {
                return 30
            }
        } else {
            return self.repeatIntervalArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isNumberFormatPicker {
            return (row+1).description
        } else {
            return self.repeatIntervalArray[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        if isNumberFormatPicker {
            self.selectedInterval = (row+1).description
        } else {
            self.selectedInterval = row == 0 ? "Daily" : self.repeatIntervalArray[row]
        }
    }
}
