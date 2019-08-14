//
//  TaskAssignViewController.swift
//  followal
//
//  Created by Vivek Gadhiya on 09/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
protocol UserListViewControllerDelegate {
    func didSelectUser(_ obj:UserResponseModel)
}

class UserListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var contacts = [String]()
    var arrUsers = [UserResponseModel]()
    var delegate : UserListViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Users"
        tableView.register(UINib.init(resource: nibs.taskAssignTableViewCell), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: .zero)
        arrUsers = Array(realm.objects(UserResponseModel.self).filter({$0.UserId != getUserID()}))
        let req = FolderList()
        let request = RequestBaseModel<FolderList>()
        request.data = req
        request.eventName = "MyGroupUser"
        request.accessToken = getAccessToken()

        self.userList(request: request)
    }
    
    func userList(request: RequestBaseModel<FolderList>) {
        
       // let url = webUrls.baseURL() + webUrls.myGroupUser()
        SocketHelper.emitWithAck(param: request, eventName: request.eventName) { (response) in
            
            guard let response = response else {
                showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: self)
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let jsonData = JSON(response)
                if jsonData[Keys.returnValue.key].boolValue {
                    if let data = jsonData["Data"].rawValue as? [String : Any]{
                        if let dataUser = data["Users"] as? [[String : Any]]{
                         let user = Mapper<UserResponseModel>().mapArray(JSONArray:dataUser)
                            try realm.write {
                                realm.add(user, update: true)
                            }
                            self.arrUsers = Array(realm.objects(UserResponseModel.self).filter({$0.UserId != getUserID()}))
                            self.tableView.reloadData()
                        }
                        }
                    
                } else{
                    showAlertView(with: jsonData[Keys.returnMsg.key].stringValue, viewController: self)
                }
                
//                let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
//                let responseModel = try decoder.decode(ResponseBaseModel<[UserResponseModel]>.self, from: jsonData)
//                if responseModel.returnValue {
//                    try realm.write {
//                        realm.add(responseModel.data!, update: true)
//                    }
//                    self.arrUsers = Array(realm.objects(UserResponseModel.self))
//                    self.tableView.reloadData()
//                } else {
//                    showAlertView(with: responseModel.returnMsg, viewController: self)
//                }
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: self)
            }
            
            
        }
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TaskAssignTableViewCell
        let user = arrUsers[indexPath.row]
        cell.lblName.text = user.UserName == "" ? user.EmailAddress : user.UserName
        cell.imgUserProfile.sd_setImage(with: URL(string: user.Profile), placeholderImage:images.ic_user_placeholder(), options: [.progressiveLoad], context: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let user = arrUsers[indexPath.row]
         delegate?.didSelectUser(user)
        self.navigationController?.popViewController(animated: false)
    }

}
