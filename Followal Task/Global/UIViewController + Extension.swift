//
//  UIViewController + Extension.swift
//  followal
//
//  Created by Vivek Gadhiya on 16/01/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI
import MessageUI
import MaterialComponents.MaterialSnackbar
import ARSLineProgress

func showAlertView(with msg: String, viewController: UIViewController) {
    let alert = UIAlertController(title: "Followal Task", message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (ok) in
        alert.dismiss(animated: true, completion: nil)
    }))
    viewController.present(alert, animated: true, completion: nil)
}
extension NSObject{
    func getRepeatReminderValue(_ customData: ScheduleTask) -> String {
        let type = customData.IntervalType.textValue
        print(type)
        if customData.IntervalDays.toArray().isEmpty {
            return "Never"
        }
        if type == "Day" { //Handle Custom Day
            let interval = customData.IntervalDays[0]
            let day = interval
            if day == 1 {
                return "Repeat at Everyday"
            } else {
                return "Repeat at Every \(day) Days"
            }
        } else if type == "Week" { // Handle Custom Week
            if !customData.IntervalDays.toArray().contains(0) {
                let components = customData.IntervalDays.toArray().compactMap { (value) -> DateComponents? in
                    var component = DateComponents()
                    component.weekday = value
                    return component
                }
                let daysName = components.map( { Calendar.current.standaloneWeekdaySymbols[$0.weekday! - 1].prefix(3) })
                print(daysName)
                return "Repeat on \(daysName.joined(separator: ", "))"
            } else{
                return "Never"
            }
        } else if type == "Month" { // Handle Custom Month
            let components = customData.IntervalDays.toArray().compactMap { (value) -> DateComponents? in
                var component = DateComponents()
                component.month = value
                return component
            }
            let daysName = components.compactMap( { $0.day }).map { $0.description }
            print(daysName)
            return "Monthly - \(daysName.joined(separator: ", "))"
            
        } else if type == "Year" {
            
            let components = customData.IntervalMonths.toArray().compactMap { (value) -> DateComponents? in
                var component = DateComponents()
                component.month = value
                return component
            }
            let daysName = Set(components.compactMap( { $0.month }).map { ArrayOfMonths[$0 - 1] })
            print(daysName)
            return "Yearly - \(daysName.joined(separator: ", "))"
            
            
        }
        return ""
    }
}
extension UIViewController {
    func getRepeatReminder(_ customData: ScheduleTask) -> String {
        let type = customData.IntervalType.textValue
        print(type)
        if customData.IntervalDays.toArray().isEmpty {
            return "Never"
        }
        if type == "Day" { //Handle Custom Day
            let interval = customData.IntervalDays[0]
            let day = interval
            if day == 1 {
                return "Repeat at Everyday"
            } else {
                return "Repeat at Every \(day) Days"
            }
        } else if type == "Week" { // Handle Custom Week
            if !customData.IntervalDays.toArray().contains(0) {
                let components = customData.IntervalDays.toArray().compactMap { (value) -> DateComponents? in
                    var component = DateComponents()
                    component.weekday = value
                    return component
                }
                let daysName = components.map( { Calendar.current.standaloneWeekdaySymbols[$0.weekday! - 1].prefix(3) })
                print(daysName)
                return "Repeat on \(daysName.joined(separator: ", "))"
            } else{
                return "Never"
            }
        } else if type == "Month" { // Handle Custom Month
            let components = customData.IntervalDays.toArray().compactMap { (value) -> DateComponents? in
                var component = DateComponents()
                component.month = value
                return component
            }
            let daysName = components.compactMap( { $0.day }).map { $0.description }
            print(daysName)
            return "Monthly - \(daysName.joined(separator: ", "))"
            
        } else if type == "Year" {
            
            let components = customData.IntervalMonths.toArray().compactMap { (value) -> DateComponents? in
                var component = DateComponents()
                component.month = value
                return component
            }
            let daysName = Set(components.compactMap( { $0.month }).map { ArrayOfMonths[$0 - 1] })
            print(daysName)
            return "Yearly - \(daysName.joined(separator: ", "))"
            
            
        }
        return ""
    }
//    var barItemIndicator: UIActivityIndicatorView {
//        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
//        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.style = .whiteLarge
//        activityIndicator.color = Colors.blueTheme
//
//        return activityIndicator
//    }
    
    func setupBackButton(color: UIColor = Colors.blueTheme) {
        
      //  self.navigationItem.hidesBackButton = true

//        let barButton = UIBarButtonItem(image: images.ic_back_arrow_blue(), style: .done, target: self, action: #selector(backTapped))
//        barButton.tintColor = color
//        self.navigationItem.leftBarButtonItem = barButton
    }
    
    
    func startLoader() {
        self.view.isUserInteractionEnabled = false
        ARSLineProgress.show()
        //startAnimating(CGSize(width: 50, height: 50), type: NVActivityIndicatorType.ballClipRotate, color: Colors.blueTheme)
        
    }
    
    func dismissLoader() {
        //stopAnimating()
        ARSLineProgress.hide()
        self.view.isUserInteractionEnabled = true
    }
    
//    func startActivityIndicator() {
//        self.view.addSubview(barItemIndicator)
//        barItemIndicator.startAnimating()
//    }
//    
//    func stopActivityIndicator() {
//        barItemIndicator.removeFromSuperview()
//        barItemIndicator.stopAnimating()
//    }
    
    
    @objc func hideTabBar(_ hidden: Bool) {
        self.tabBarController?.tabBar.isHidden = hidden
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
        //self.navigationController?.popToViewController(ofClass: ConversionListViewController.self, animated: true)
    }
    
    func makeNavigationClear() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func openSheetMenu(title: String?, message: String?, actionTitles: [String], actions:[((UIAlertAction) -> Void)?], cancelTitle: String? = nil , cancelAction: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: cancelTitle == nil ? Localization.cancel.key.localized : cancelTitle, style: .cancel, handler: cancelAction))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActionsheet(title: String?, message: String?, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, (title, style)) in actions.enumerated() {
            let alertAction = UIAlertAction(title: title, style: style) { (_) in
                completion(index)
            }
            alertViewController.addAction(alertAction)
        }
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func showToast(_ message: String) {
        MDCSnackbarMessageView.appearance().backgroundColor = .black
        let messageBar = MDCSnackbarMessage()
        messageBar.text = message
        MDCSnackbarManager.show(messageBar)
    }
    
    func showAlert(_ message: String) {
        popupAlert(title: "Followal Task", message: message, actionTitles: ["Ok"], actions: [ { _ in
            
            }])
    }
    
    func addImageButton() -> (UIImageView, UIButton, UIBarButtonItem) {
        let size = 41
        let viewBtn = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        viewBtn.layer.cornerRadius = 20.5
        viewBtn.clipsToBounds = true
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        imageview.contentMode = .scaleAspectFill
        viewBtn.addSubview(btn)
        viewBtn.addSubview(imageview)
        
        let revel = UIBarButtonItem(customView: viewBtn)
        return (imageview, btn, revel)
    }
    
//    func configDD(_ dropdown: DropDown, sender: UIView) {
//        dropdown.anchorView = sender
//        dropdown.width = sender.bounds.width
//        dropdown.direction = .any
//        dropdown.bottomOffset = CGPoint(x: 0, y: sender.frame.height)
//        dropdown.cellHeight = 40.0
//        dropdown.customCellConfiguration = { (index, item, cell) in
//            cell.optionLabel.font = Fonts.regular(size: 16)
//        }
//    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func ShowUploadDownloadLoader(percentage: Double){
        
        
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
    
    func hideKeyboardWhenTappedAround(onview: UIView? = nil) {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        let viewContainer = onview ?? view
        viewContainer?.addGestureRecognizer(tapGesture)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}

extension UIViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func openImagePicker(withMessage: String? = nil, isEditMode: Bool = false) {
        
        let imagePicker = UIImagePickerController()
        
        let alertController = UIAlertController(title: nil, message: withMessage, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                imagePicker.delegate = self
                imagePicker.allowsEditing = isEditMode
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                imagePicker.delegate = self
                imagePicker.allowsEditing = isEditMode
                imagePicker.sourceType = .savedPhotosAlbum
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: Localization.cancel.key.localized, style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
   
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
extension UIView {
    func setGradientBackground() {
        let colorTop =  UIColor(hexString: HexString.hex_startcolor).cgColor
        let colorBottom = UIColor(hexString: HexString.hex_endcolor).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at:0)
    }
   
}


extension UIViewController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func inviteForApp(recipients: String, isEmail: Bool) {
        print(recipients)
        let message = Localization.hiThereUseFollowalApp.key.localized
        
        if isEmail {
            if MFMailComposeViewController.canSendMail() {
                let mailComposeVC = MFMailComposeViewController()
                mailComposeVC.mailComposeDelegate = self
                mailComposeVC.setToRecipients([recipients])
                mailComposeVC.setSubject("Followal Task")
                mailComposeVC.setMessageBody(message, isHTML: false)
                self.present(mailComposeVC, animated: true, completion: nil)
            } else {
                showAlert(Localization.canTSendMail.key.localized)
            }
        } else {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = message
                controller.recipients = [recipients]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            } else {
                showAlert(Localization.canTSendInvite.key.localized)
            }
        }
    }
    
    func configureMailComposer(with emails: [String], subject: String, message: String) -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(emails)
        mailComposeVC.setSubject(subject)
        mailComposeVC.setMessageBody(message, isHTML: false)
        return mailComposeVC
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            showAlert(error!.localizedDescription)
            return
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController: CNContactViewControllerDelegate {
    
    func saveContact(contact: CNContact) {
        let controller = CNContactViewController(forNewContact: contact)
        controller.contactStore = contactStore
        controller.delegate = self
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .fullScreen
        self.present(navigation, animated: true, completion: nil)
    }
    
    public func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}


extension UINavigationController {
    
    func getController<T: UIViewController>(ofClass: T.Type) -> T? {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass.classForCoder())}).last {
            return vc as? T
        }
        return nil
    }
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let vc = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(vc, animated: animated)
        }
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
}

extension UIViewController: UIViewControllerTransitioningDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = RevealFromFrameAnimator()
        transition.originFrame = self.view.frame
        transition.forward = (operation == .push)
        return transition
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PresentReverseAnimator()
        animator.isPresenting = true
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PresentReverseAnimator()
        animator.isPresenting = false
        return animator
    }
}
