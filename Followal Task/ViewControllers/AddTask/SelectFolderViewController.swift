//
//  SelectFolderViewController.swift
//  Followal Task
//
//  Created by iMac on 24/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
protocol FolderSelectionDelegate {
    func didselectFolder(_ obj: FolderResponseModel)
}

class SelectFolderViewController: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    //MARK:- Variable
    var selectedObject:FolderResponseModel?
    var delegate: FolderSelectionDelegate?
    var arrayFolders = [FolderResponseModel]()
    
    //MARK:- UIView Life Cycle
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
        if self.selectedObject != nil {
            if let row = arrayFolders.firstIndex(of: self.selectedObject!) {
                self.pickerView.selectRow(row, inComponent: 0, animated: true)
            } else{
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        } else {
            self.pickerView.selectRow(0, inComponent: 0, animated: true)
        }
        let arrFoldersExcept = ["All","Assign","Completed","Review"]
        self.arrayFolders = Array(realm.objects(FolderResponseModel.self).filter({!arrFoldersExcept.contains($0.FolderName)}))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor.init(hexString: HexString.hex_000000).withAlphaComponent(0.5)
        })
    }
    
    //MARK:- UIButton Action
    @IBAction func saveTapped(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.delegate?.didselectFolder(self.arrayFolders[self.pickerView.selectedRow(inComponent: 0)])
        }
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}

//MARK:- UIPickerViewDelegatem, UIPickerViewDataSource
extension SelectFolderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrayFolders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrayFolders[row].FolderName
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedObject = self.arrayFolders[row]
    }
}
