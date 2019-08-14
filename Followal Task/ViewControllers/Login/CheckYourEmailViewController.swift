//
//  CheckYourEmailViewController.swift
//  Followal Task
//
//  Created by iMac on 18/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift

class CheckYourEmailViewController: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var btnOpenEmail: UIButton!
    @IBOutlet weak var viewBG: UIView!
    
    //MARK:- Variable
    let disposeBag = DisposeBag()
    
    //MARK:- UIView Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUI()
    }
    
    func setUI() {
        viewBG.setGradientBackground()
        btnOpenEmail.setGradientBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       setUI()
       btnOpenEmail.rx.tap.subscribe(onNext: {
            //TaskHelper.login()
            self.navigationController?.popToRootViewController {
                
            }
        }).disposed(by: disposeBag)
    }

    //MARK:- Setup UI
    func setupUI() {
        btnOpenEmail.applyCornerRadius(btnOpenEmail.bounds.height / 2)
        
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
