//
//  EmailMagicLinkViewController.swift
//  Followal Task
//
//  Created by iMac on 18/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift


class EmailMagicLinkViewController: UIViewController {

    //MARK:- Outlets -
    @IBOutlet weak var btnTypePassword: UIButton!
    @IBOutlet weak var btnEmailMagicLink: UIButton!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var tfPassword: TextField!
    @IBOutlet weak var btnSignUp: UIButton!

    //MARK:- Variable
    let disposeBag = DisposeBag()
    var strEmail:String!
    
    //MARK:- UIView Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUI()
    }
    func setUI() {
        btnEmailMagicLink.setGradientBackground()
        btnSignUp.setGradientBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.hideAllObj()
        setUI()
        self.btnTypePassword.isHidden = false
        self.btnEmailMagicLink.isHidden = false
        viewBG.setGradientBackground()
       
        tfPassword.applyCornerRadius(tfPassword.bounds.height / 2)
        btnEmailMagicLink.applyCornerRadius(btnEmailMagicLink.bounds.height / 2)
        btnSignUp.applyCornerRadius(btnSignUp.bounds.height / 2)

        btnSignUp.rx.tap.subscribe(onNext: {
            
            let registerRequestEmail = RegisterRequest()
            registerRequestEmail.emailAddress = self.strEmail
            registerRequestEmail.password  = self.tfPassword.text ?? ""
            registerRequestEmail.deviceType = "ios"
            registerRequestEmail.userLoginType = "Guest"
            registerRequestEmail.pushToken = getDeviceToken()
            let request = RequestBaseModel<RegisterRequest>()
            request.data = registerRequestEmail
            request.eventName = "Login"
            self.signupWith(request: request, webUrls.login())
//            let viewController = board.main.checkYourEmailVC()!
//            self.navigationController?.pushViewController(viewController, animated: true)
        }).disposed(by: disposeBag)
        btnEmailMagicLink.rx.tap.subscribe(onNext: {
            let registerRequestEmail = RegisterRequest()
            registerRequestEmail.emailAddress = self.strEmail
           // registerRequestEmail.password  = self.tfPassword.text ?? ""
            registerRequestEmail.deviceType = "ios"
            registerRequestEmail.userLoginType = "MagicLink"
            registerRequestEmail.pushToken = getDeviceToken()
            let request = RequestBaseModel<RegisterRequest>()
            request.data = registerRequestEmail
            request.eventName = "Signup"
            self.signupWith(request: request,webUrls.registerURL())
//            let viewController = board.main.checkYourEmailVC()!
//            self.navigationController?.pushViewController(viewController, animated: true)
        }).disposed(by: disposeBag)
        btnTypePassword.rx.tap.subscribe(onNext: {
            self.hideAllObj()
            self.tfPassword.isHidden = false
            self.btnSignUp.isHidden = false
        }).disposed(by: disposeBag)
    }
    
    func hideAllObj() {
        self.tfPassword.isHidden = true
        self.btnEmailMagicLink.isHidden = true
        self.btnSignUp.isHidden = true
        self.btnTypePassword.isHidden = true
    }
    
    //MARK:- API
    func signupWith(request: RequestBaseModel<RegisterRequest>, _ urlStr:String) {
        
        // UIApplication.shared.beginIgnoringInteractionEvents()
        let url = webUrls.baseURL() + urlStr
        ServiceManager().request(url: url, inputModel: request) { (response) in
            
            //UIApplication.shared.endIgnoringInteractionEvents()
            guard let response = response else {
                showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: self)
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                let responseModel = try decoder.decode(ResponseBaseModel<RegisterResponseModel>.self, from: jsonData)
                if responseModel.returnValue {
                    if  responseModel.data!.IsVerify!{
                        UserDefaults.standard.set(true, forKey: Keys.isUserLogIn())
                        UserDefaults.standard.set(responseModel.data?.Token ?? "", forKey: Keys.access_token())
                        UserDefaults.standard.set(responseModel.data?._id ?? "", forKey: Keys.userID())
                        let encoder = JSONEncoder()
                        if let encoded = try? encoder.encode(responseModel.data) {
                            UserDefaults.standard.set(encoded, forKey: Keys.registerData())
                        }
                        TaskHelper.login()
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                        self.navigationController?.popToRootViewController {
                            showAlertView(with: "Please verify your email first than login again", viewController: self)

                        }
                    }
                } else {
                    showAlertView(with: responseModel.returnMsg, viewController: self)
                    self.navigationController?.popViewController(animated: true)
                }
            } catch let error {
                print(error.localizedDescription)
                showAlertView(with: error.localizedDescription, viewController: self)
            }
        }
    }
    
    //MARK:- Setup UI -
    func setupUI() {
        btnEmailMagicLink.applyCornerRadius(btnEmailMagicLink.bounds.height / 2)
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


extension EmailMagicLinkViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            self.hideAllObj()
            if text.count == 0 {
                self.btnTypePassword.isHidden = false
                self.btnEmailMagicLink.isHidden = false
            } else {
                self.tfPassword.isHidden = false
                self.btnSignUp.isHidden = false
            }
        }
        return true
        
    }
    
}
