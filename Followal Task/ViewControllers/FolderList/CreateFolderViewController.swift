//
//  CreateFolderViewController.swift
//  Followal Task
//
//  Created by iMac on 19/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift
import RxRealm
import SwiftyJSON
import RealmSwift
import ObjectMapper
class CreateFolderViewController: UIViewController {
    
    //MARK:- Outlet
    @IBOutlet weak var tfFolderName: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    //MARK:- Variable
    var disposeBag = DisposeBag()
    
     //MARK:- UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Folder"
        btnSave.rx.tap
            .subscribe(onNext: {
                if self.tfFolderName.text!.isEmpty {
                    self.showToast("Please enter folder name")
                } else {
                    let req = FolderRequest()
                    req.folderName = self.tfFolderName.text ?? ""
                    req.folderID =  UUID.init().uuidString
                    let request = RequestBaseModel<FolderRequest>()
                    request.data = req
                    request.eventName = "CreateFolder"
                    request.accessToken = getAccessToken()

                    self.createFolder(request: request)
                }
            }).disposed(by: disposeBag)
        btnBack.rx.tap
            .subscribe(onNext: {
               self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
    
    //MARK:- Login
    
    func createFolder(request: RequestBaseModel<FolderRequest>) {
        
        let arrayFolders = Array(realm.objects(FolderResponseModel.self).filter({$0.FolderName == self.tfFolderName.text!.trimmed()}))
        if arrayFolders.count > 1 {
            self.showToast("This name already exist in folder list. Please enter different folder name.")
            return
        }
        
        
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: self)
                return
            }
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
                    if let dataUser = jsonData["Data"].dictionaryObject {
                        let folder = Mapper<FolderResponseModel>().map(JSONObject: dataUser)
                        let realm = try! Realm()
                        try realm.write {
                            realm.add(folder!, update: true)
                        }
                    }
                } else {
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: appDelegte.window!.rootViewController!)
                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: appDelegte.window!.rootViewController!)
            }
            
        }
        
     
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


