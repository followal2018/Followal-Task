//
//  LoginViewController.swift
//  Followal Task
//
//  Created by iMac on 18/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift
import ActiveLabel
import IQKeyboardManagerSwift

class LoginViewController: UIViewController ,GIDSignInUIDelegate{

    //MARK:- Outlet
    @IBOutlet weak var btnLoginWithGoogle: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewEmailBox: UIView!
    @IBOutlet weak var tfEmail: TextField!
    @IBOutlet weak var viewGmail: GIDSignInButton!
    @IBOutlet weak var lblTermsAndCondition: ActiveLabel!
    
    //MARK:- Variable
    let disposeBag = DisposeBag()
    
    //MARK:- UIView Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUI()
        setupLinkLabel()
        if isUserLogin() {
            TaskHelper.login()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUI()
    }
    
    func setUI(){
        viewBG.setGradientBackground()
        btnLogin.setGradientBackground()
    }
    
    //MARK:- Setup UI -
    func setupUI() {
        
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        
        btnLoginWithGoogle.applyCornerRadius(btnLoginWithGoogle.bounds.height / 2)
        viewEmailBox.applyCornerRadius(15)
        btnLogin.applyCornerRadius(btnLogin.bounds.height / 2)
        tfEmail.applyCornerRadius(tfEmail.bounds.height / 2)
        viewGmail.applyCornerRadius(viewGmail.bounds.height / 2)
        viewEmailBox.applyShadow()
        btnLoginWithGoogle.applyShadow()
        btnLogin.rx.tap.subscribe(onNext: {
            if (self.tfEmail.text!.isValidEmail()) {
                let viewController = board.main.emailMagicVC()!
                viewController.strEmail = self.tfEmail.text ?? ""
                self.navigationController?.pushViewController(viewController, animated: true)
                self.tfEmail.text = ""
            } else{
                self.showToast("Please enter valid email")
            }
            
        }).disposed(by: disposeBag)
        btnLoginWithGoogle.rx.tap.subscribe(onNext: {
            GIDSignIn.sharedInstance().signInSilently()
        }).disposed(by: disposeBag)
    }
    
    func setupLinkLabel() {
        let message = "By continuing, you agree to our Terms of Use and read the Privacy Policy"
        
        let termsConditionType = ActiveType.custom(pattern: "\\sTerms of Use\\b")
        let privacyType = ActiveType.custom(pattern: "\\sPrivacy Policy\\b")
        lblTermsAndCondition.enabledTypes = [termsConditionType, privacyType]
        lblTermsAndCondition.text = message
        
        lblTermsAndCondition.customize { (label) in
            label.customColor[termsConditionType] = Colors.blueTheme
            label.customSelectedColor[termsConditionType] = UIColor.black
            label.customColor[privacyType] = Colors.blueTheme
            label.customSelectedColor[privacyType] = UIColor.black
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case termsConditionType:
                    atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
                case privacyType:
                    atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
                default:
                    break
                }
                return atts
            }
        }
        lblTermsAndCondition.handleCustomTap(for: termsConditionType) { (word) in
            if let url = webUrls.termsAndConditionURL().toURL() {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        lblTermsAndCondition.handleCustomTap(for: privacyType) { (word) in
            print(word)
            if let url = webUrls.privacyURL().toURL() {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    //MARK:- GIDSignIn -
    private func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    private func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.view.endEditing(true)
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    private func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
            let email = user.profile.email
            print(userId)
            print(idToken)
            print(fullName)
//            print(givenName)
//            print(familyName)
            print(email)
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
