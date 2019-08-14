//
//  AIExtensions.swift
//  Swift3CodeStructure
//
//  Created by Ravi Alagiya on 25/11/2016.
//  Copyright © 2016 Ravi Alagiya. All rights reserved.
//

import QuartzCore
import Foundation
import UIKit
import AVFoundation



extension String {
    
    func heightWithWidthAndFont(_ width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    
    func isValidEmailBoth(str:String) -> Bool    {
        //        return ( (isValidEmail(self as String))  && (isValidEmail_NEW(self as String)) )
        let emailRegex = "[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Z0-9a-z]+([.-]{1}[A-Z0-9a-z]+)*(\\.[A-Za-z]{2,4}){0,1}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: str)
        
    }
    
    func isValidEmail(_ stringToCheckForEmail:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Z0-9a-z]+([.-]{1}[A-Z0-9a-z]+)*(\\.[A-Za-z]{2,4}){0,1}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: stringToCheckForEmail)
        
    }
    
    func isValidEmail_NEW(_ stringToCheckForEmail:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: stringToCheckForEmail)
    }
    
    func trimString(str : String) -> String
    {
        let getstr = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return getstr
    }
    
    //    var length: Int {
    //        return self.count
    //    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    //    subscript (i: Int) -> String {
    //        return self[Range(i ..< i + 1)]
    //    }
    
    //    func substring(from: Int) -> String {
    //        return self[Range(min(from, length) ..< length)]
    //    }
    
    //    func substring(to: Int) -> String {
    //        return self[Range(0 ..< max(0, to))]
    //    }
    
    //    subscript (r: Range<Int>) -> String {
    //        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
    //                                            upper: min(length, max(0, r.upperBound))))
    //        let start = index(startIndex, offsetBy: range.lowerBound)
    //        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    //        return String(self[Range(start ..< end)])
    //    }
    
    
    func setDateFormatToSend(strDate : String) -> String
    {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MM-dd-yy"
        let getDate = dateFormatter1.date(from: strDate)
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        return dateFormatter1.string(from: getDate!)
    }
    
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}


extension NSLayoutConstraint {
    
    func setMultiplier(_ multiplier:CGFloat) -> NSLayoutConstraint {
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        newConstraint.isActive = true
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension UILabel {
    
    func setLineHeight(_ lineHeight: CGFloat) {
        self.setLineHeight(lineHeight, withAlignment: .center)
        
    }
    
    func setLineHeight(_ lineHeight: CGFloat, withAlignment alignment:NSTextAlignment) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineHeight
            style.alignment = alignment
            
            attributeString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, text.count))
            self.attributedText = attributeString
        }
    }
    
    
    func setBetweenSpace() {
        setBetweenSpace(space: 1.5)
    }
    func setBetweenSpace(space:CGFloat) {
        let text = self.text
        
        if let text = text {
            
            let attributeString = NSMutableAttributedString(string: text)
            
            attributeString.addAttribute(NSAttributedString.Key.kern, value: GET_PROPORTIONAL_WIDTH(space), range: NSMakeRange(0, text.count))
            self.attributedText = attributeString
        }
    }
    
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
    
}

extension UISearchBar {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.barTintColor = APP_NAVIGATION_COLOR
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = APP_HEADER_TEXT_COLOR
        textFieldInsideSearchBar?.backgroundColor = UIColor.white
        self.tintColor = UIColor.white
    }
}

extension UITextField
{
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.autocapitalizationType = UITextAutocapitalizationType.none;
        self.autocorrectionType = UITextAutocorrectionType.no;
        
        //        if self.tag == 0 {
        //          /*  let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        //            self.leftViewMode = UITextFieldViewMode.always;
        //            self.leftView = view;  */
        //            self.tintColor = APP_TEXTFIELD_BLACK_COLOR
        //            self.textColor = APP_TEXTFIELD_BLACK_COLOR
        //            self.backgroundColor = UIColor.clear
        //            self.setValue(APP_PLACEHOLDER_COLOR, forKeyPath: "_placeholderLabel.textColor")
        //            self.font = SYSTEM_REGULAR_FONT
        //        }else if self.tag == 1 {
        //            self.tintColor = APP_HEADER_TEXT_COLOR
        //            self.textColor = APP_HEADER_TEXT_COLOR
        //            self.backgroundColor = UIColor.clear
        //            self.setValue(APP_LIGHT_GRAY_COLOR, forKeyPath: "_placeholderLabel.textColor")
        //            self.font = SYSTEM_REGULAR_FONT
        //        }else{
        //
        //            self.tintColor = APP_TEXTFIELD_TINT_COLOR
        //            self.textColor = APP_HEADER_TEXT_COLOR
        //            //self.useUnderline()
        //            self.backgroundColor = UIColor.white
        //            self.setValue(APP_PLACEHOLDER_COLOR, forKeyPath: "_placeholderLabel.textColor")
        //            self.font = UIFont(name: FONT_REGULAR, size: 15)
        //        }
        //
        //
        //        if self.keyboardType == UIKeyboardType.numberPad {
        //            let toolbar = UIToolbar.init()
        //            toolbar.sizeToFit()
        //            let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(btnBarDoneAction))
        //            toolbar.items = [barBtnDone]
        //            self.inputAccessoryView = toolbar
        //        }
        //        self.tintColor = .black
    }
    
    @objc func btnBarDoneAction() { self.resignFirstResponder() }
    
    func useUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.blue.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func applyCornerRadious()
    {
        self.layer.cornerRadius = self.frame.size.width/16
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0
    }
    
}

extension UITextView
{
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.autocapitalizationType = UITextAutocapitalizationType.none;
        self.autocorrectionType = UITextAutocorrectionType.no;
        
        
        /*let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
         self.leftViewMode = UITextFieldViewMode.always;
         self.leftView = view;*/
        
        
        //        if self.keyboardType == UIKeyboardType.default {
        //            let toolbar = UIToolbar.init()
        //            toolbar.sizeToFit()
        //            let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(btnBarDoneAction))
        //            toolbar.items = [barBtnDone]
        //            self.inputAccessoryView = toolbar
        //        }
        //  self.textContainerInset = UIEdgeInsetsMake(10,10,0 ,0);
        
        //        self.tintColor = APP_TEXTFIELD_TINT_COLOR
        //        self.textColor = APP_HEADER_TEXT_COLOR
        /* self.layer.borderColor = APP_SEPERATOR_COLOR.cgColor
         self.layer.borderWidth = 1.0
         self.layer.cornerRadius = APP_CORNER_RADIOUS
         self.backgroundColor = UIColor.white */
        self.setValue(APP_PLACEHOLDER_COLOR, forKeyPath: "_placeholderLabel.textColor")
        self.font = UIFont(name: FONT_REGULAR, size: 15)
        
    }
    
    func btnBarDoneAction() { self.resignFirstResponder() }
    
    
    func adjustFontToFitInsideContent(maxfontSize:CGFloat, minFontSize:CGFloat) {
        
        var currentSize = maxfontSize
        font = font?.withSize(currentSize)
        
        while  contentSize.height > frame.height {
            
            if currentSize <= minFontSize {
                currentSize = minFontSize
                font = font?.withSize(currentSize)
                return
            }
            
            currentSize -= 1
            font = font?.withSize(currentSize)
            setNeedsLayout()
            setNeedsDisplay()
        }
        self.zoomScale = currentSize
    }
    
}

//MARK: - MULTIPLIER CONSTRAINT

extension NSLayoutConstraint {
    
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        newConstraint.isActive = true
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha
        
        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }
        
        return color
    }
    
}

extension UIView
{
    // HEIGHT / WIDTH
    
    var width:CGFloat {
        return self.frame.size.width
    }
    var height:CGFloat {
        return self.frame.size.height
    }
    var xPos:CGFloat {
        return self.frame.origin.x
    }
    var yPos:CGFloat {
        return self.frame.origin.y
    }
    
    
    // ROTATE
    func rotate(_ angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat(M_PI)
        self.transform = self.transform.rotated(by: radians);
    }
    
    
    // BORDER
    func applyBorderDefault() {
        self.applyBorder(UIColor.red, width: 1.0)
    }
    func applyBorderDefault1() {
        self.applyBorder(UIColor.green, width: 1.0)
    }
    func applyBorderDefault2() {
        self.applyBorder(UIColor.blue, width: 1.0)
    }
    func applyBorder(_ color:UIColor, width:CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func applyCircle() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) * 0.5
        self.layer.masksToBounds = true
    }
    func applyCircleWithRadius(_ radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    // CORNER RADIUS
    func applyCornerRadius(_ radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func applyCornerRadiusTwoSide(_ radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively

    }
    
    func applyCornerRadiusDefault() {
        self.applyCornerRadius(5.0)
    }
    
    func setViewShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5.0
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = false
    }
    
    func applyShadowDefault()    {
        self.applyShadowWithColor(UIColor.black, opacity: 0.5, radius: 1)
    }
    
    func applyShadowWithColor(_ color:UIColor)    {
        self.applyShadowWithColor(color, opacity: 0.5, radius: 1)
    }
    
    func applyShadowWithColor(_ color:UIColor, opacity:Float, radius: CGFloat)    {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = radius
        
        self.clipsToBounds = false
    }
    
    func applyShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.2
    }
    
    func layerGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPoint(x: 0, y: 0)
        layer.cornerRadius = CGFloat(frame.width / 20)
        
        let color0 = UIColor(red:250.0/255, green:250.0/255, blue:250.0/255, alpha:0.5).cgColor
        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.1).cgColor
        let color2 = UIColor(red:150.0/255, green:150.0/255, blue: 150.0/255, alpha:0.1).cgColor
        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).cgColor
        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).cgColor
        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).cgColor
        let color6 = UIColor(red:150.0/255, green:150.0/255, blue:150.0/255, alpha:0.1).cgColor
        
        layer.colors = [color0,color1,color2,color3,color4,color5,color6]
        self.layer.insertSublayer(layer, at: 0)
    }
    
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 120)
        gradient.colors = colours.map { $0.cgColor }
        gradient.opacity = 0.3
        gradient.locations = locations
        //gradient.startPoint = CGPoint(x: 1, y: 0)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension NSDictionary{
    
    func object_forKeyWithValidationForClass_Int(_ aKey: String) -> Int {
        
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return Int()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.object(forKey: aKey) {
            if((val as AnyObject).isEqual(NSNull())) {
                return Int()
            }
        } else {
            // KEY NOT FOUND
            return Int()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.object(forKey: aKey)! as AnyObject
        if aValue.isEqual(NSNull()) {
            return Int()
        }
        else {
            
            if aValue is Int {
                return self.object(forKey: aKey) as! Int
            }
            else{
                return Int()
            }
            
            
            //            return self.objectForKey(aKey) as! Int
        }
    }
    
    func object_forKeyWithValidationForClass_CGFloat(_ aKey: String) -> CGFloat
        
        
    {
        
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return CGFloat()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.object(forKey: aKey) {
            if((val as AnyObject).isEqual(NSNull())) {
                return CGFloat()
            }
        } else {
            // KEY NOT FOUND
            return CGFloat()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.object(forKey: aKey)! as AnyObject
        if aValue.isEqual(NSNull()) {
            return CGFloat()
        }
        else {
            
            if aValue is CGFloat {
                return self.object(forKey: aKey) as! CGFloat
            }
            else{
                return CGFloat()
            }
            
            //            return self.objectForKey(aKey) as! CGFloat
        }
    }
    
    func object_forKeyWithValidationForClass_String(_ aKey: String) -> String {
        
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return String()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.object(forKey: aKey) {
            if((val as AnyObject).isEqual(NSNull())) {
                return String()
            }
        } else {
            // KEY NOT FOUND
            return String()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.object(forKey: aKey)! as AnyObject
        if aValue.isEqual(NSNull()) {
            return String()
        }
        else {
            
            if aValue is String {
                return self.object(forKey: aKey) as! String
            }
            else{
                return String()
            }
            
            //            return self.objectForKey(aKey) as! String
        }
    }
    
    func object_forKeyWithValidationForClass_Bool(_ aKey: String) -> Bool {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return Bool()
        }
        // CHECK IF KEY EXIST
        if let val = self.object(forKey: aKey) {
            if((val as AnyObject).isEqual(NSNull())) {
                return Bool()
            }
        } else {
            // KEY NOT FOUND
            return Bool()
        }
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.object(forKey: aKey)! as AnyObject
        if aValue.isEqual(NSNull()) {
            return Bool()
        }
        else {
            
            if aValue is Bool {
                return self.object(forKey: aKey) as! Bool
            }
            else{
                return Bool()
            }
            
            //            return self.objectForKey(aKey) as! Bool
        }
    }
    
    func object_forKeyWithValidationForClass_NSArray(_ aKey: String) -> NSArray {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return NSArray()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.object(forKey: aKey) {
            if((val as AnyObject).isEqual(NSNull())) {
                return NSArray()
            }
        } else {
            // KEY NOT FOUND
            return NSArray()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.object(forKey: aKey)! as AnyObject
        if aValue.isEqual(NSNull()) {
            return NSArray()
        }
        else {
            if aValue is NSArray {
                return self.object(forKey: aKey) as! NSArray
            }
            else{
                return NSArray()
            }
            
            //            return self.objectForKey(aKey) as! NSArray
        }
    }
    
    func object_forKeyWithValidationForClass_NSMutableArray(_ aKey: String) -> NSMutableArray {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return NSMutableArray()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.object(forKey: aKey) {
            if((val as AnyObject).isEqual(NSNull())) {
                return NSMutableArray()
            }
        } else {
            // KEY NOT FOUND
            return NSMutableArray()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.object(forKey: aKey)! as AnyObject
        if aValue.isEqual(NSNull()) {
            return NSMutableArray()
        }
        else {
            
            if aValue is NSMutableArray {
                return self.object(forKey: aKey) as! NSMutableArray
            }
            else{
                return NSMutableArray()
            }
            
            //            return self.objectForKey(aKey) as! NSMutableArray
        }
    }
    
    func object_forKeyWithValidationForClass_NSDictionary(_ aKey: String) -> NSDictionary {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return NSDictionary()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.object(forKey: aKey) {
            if((val as AnyObject).isEqual(NSNull())) {
                return NSDictionary()
            }
        } else {
            // KEY NOT FOUND
            return NSDictionary()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.object(forKey: aKey)! as AnyObject
        if aValue.isEqual(NSNull()) {
            return NSDictionary()
        }
        else {
            
            if aValue is NSDictionary {
                return self.object(forKey: aKey) as! NSDictionary
            }
            else{
                return NSDictionary()
            }
            
            //            return self.objectForKey(aKey) as! NSDictionary
        }
    }
    
    func object_forKeyWithValidationForClass_NSMutableDictionary(_ aKey: String) -> NSMutableDictionary {
        // CHECK FOR EMPTY
        if(self.allKeys.count == 0) {
            return NSMutableDictionary()
        }
        
        // CHECK IF KEY EXIST
        if let val = self.object(forKey: aKey) {
            if((val as AnyObject).isEqual(NSNull())) {
                return NSMutableDictionary()
            }
        } else {
            // KEY NOT FOUND
            return NSMutableDictionary()
        }
        
        // CHECK FOR NIL VALUE
        let aValue : AnyObject = self.object(forKey: aKey)! as AnyObject
        if aValue.isEqual(NSNull()) {
            return NSMutableDictionary()
        }
        else {
            
            if aValue is NSMutableDictionary {
                return self.object(forKey: aKey) as! NSMutableDictionary
            }
            else{
                return NSMutableDictionary()
            }
            
            //            return self.objectForKey(aKey) as! NSMutableDictionary
        }
    }
    
    
    func dictionaryByReplacingNullsWithBlanks() -> NSMutableDictionary {
        let dictReplaced : NSMutableDictionary = self.mutableCopy() as! NSMutableDictionary
        
        
        let null : AnyObject = NSNull()
        let blank : NSString = ""
        
        for key : Any in self.allKeys {
            let strKey : NSString  = key as! NSString
            let object : AnyObject = self.object(forKey: strKey)! as AnyObject
            if object.isEqual(null) {
                dictReplaced.setObject(blank, forKey: strKey)
                
            }else if object.isKind(of : NSDictionary.self) {
                dictReplaced.setObject((object as! NSDictionary).dictionaryByReplacingNullsWithBlanks(), forKey: strKey)
            }else if object.isKind(of : NSArray.self) {
                dictReplaced.setObject((object as! NSArray).arrayByReplacingNullsWithBlanks(), forKey: strKey)
            }
        }
        return dictReplaced
    }
    
    
    func dictionaryByAppendingKey(_ value : String) -> NSMutableDictionary {
        let dictReplaced : NSMutableDictionary = self.mutableCopy() as! NSMutableDictionary
        dictReplaced.setObject(value, forKey: "reviewType" as NSCopying)
        return dictReplaced
    }
    
}

extension NSArray{
    
    func arrayByReplacingNullsWithBlanks () -> NSMutableArray {
        let arrReplaced : NSMutableArray = self.mutableCopy() as! NSMutableArray
        let null : AnyObject = NSNull()
        let blank : NSString = ""
        
        for idx in 0..<arrReplaced.count {
            let object : AnyObject = arrReplaced.object(at: idx) as AnyObject
            if object.isEqual(null) {
                arrReplaced.setValue(blank, forKey: object.key!!)
                
            }else if object.isKind(of: NSDictionary.self) {
                arrReplaced.replaceObject(at: idx, with: (object as! NSDictionary).dictionaryByReplacingNullsWithBlanks())
            }else if object.isKind(of: NSArray.self) {
                arrReplaced.replaceObject(at: idx, with: (object as! NSArray).arrayByReplacingNullsWithBlanks())
            }
        }
        
        return arrReplaced
    }
    
    func arrayByAppendingKey(_ value : String) -> NSMutableArray {
        let arrReplaced : NSMutableArray = self.mutableCopy() as! NSMutableArray
        
        for idx in 0..<arrReplaced.count {
            let object : AnyObject = arrReplaced.object(at: idx) as AnyObject
            if object.isKind(of :NSDictionary.self) {
                
                arrReplaced.replaceObject(at: idx, with: (object as! NSDictionary).dictionaryByAppendingKey(value))
                
            }
        }
        return arrReplaced
    }
}

extension UIButton {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        //        self.showsTouchWhenHighlighted = true
    }
    
    func underlineButton(text: String, color:UIColor) {
        let titleString = NSMutableAttributedString(string: text)
        titleString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, text.count))
        titleString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, text.count))
        self.setAttributedTitle(titleString, for: .normal)
    }
    
    func setBetweenSpace() {
        setBetweenSpace(space: 1.5)
    }
    func setBetweenSpace(space:CGFloat) {
        let text = self.titleLabel?.text
        
        if let text = text {
            
            let attributeString = NSMutableAttributedString(string: text)
            
            attributeString.addAttribute(NSAttributedString.Key.kern, value: GET_PROPORTIONAL_WIDTH(space), range: NSMakeRange(0, text.count))
            self.setAttributedTitle(attributeString, for: .normal)
        }
    }
    
    func setHyperLink() {
        let text: String = self.currentTitle!;
        let dictAttribute: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue) :NSUnderlineStyle.single.rawValue as AnyObject,
                                                                  NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue):(self.titleLabel?.textColor)!]
        self.titleLabel?.attributedText = NSAttributedString(string: text, attributes: dictAttribute)
    }
    
    func setMultiLineText() {
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    func setShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 6, height: 6)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 6.0
        self.layer.cornerRadius = self.height/2
        self.clipsToBounds = false
    }
}

extension UIDevice
{
    // Device Family : iPhone,iPad, ...
    public var deviceFamily: String {
        return UIDevice.current.model
    }
    
    //Device Model : iPhone 6, iPhone 6 plus, iPad Air, ...
    public var deviceModel: String {
        
        var model : String
        let deviceCode = UIDevice().deviceModel
        switch deviceCode
        {
        case "iPod1,1":
            model = "iPod Touch 1G"
        case "iPod2,1":
            model = "iPod Touch 2G"
        case "iPod3,1":
            model = "iPod Touch 3G"
        case "iPod4,1":
            model = "iPod Touch 4G"
        case "iPod5,1":
            model = "iPod Touch 5G"
        case "iPod7,1":
            model = "iPod Touch 6G"
            
        case "iPhone1,1":
            model = "iPhone 2G"
        case "iPhone1,2":
            model = "iPhone 3G"
        case "iPhone2,1":
            model = "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            model = "iPhone 4"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            model = "iPhone 4"
            
        case "iPhone4,1":
            model = "iPhone 4S"
        case "iPhone5,1", "iPhone5,2":
            model = "iPhone 5"
        case "iPhone5,3", "iPhone5,4":
            model = "iPhone 5C"
        case "iPhone6,1", "iPhone6,2":
            model = "iPhone 5S"
        case "iPhone7,2":
            model = "iPhone 6"
        case "iPhone7,1":
            model = "iPhone 6 Plus"
        case "iPhone8,1":
            model = "iPhone 6S"
        case "iPhone8,2":
            model = "iPhone 6S Plus"
            
        case "iPad1,1":
            model = "iPad 1"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            model = "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":
            model = "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":
            model = "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":
            model = "iPad Air"
        case "iPad5,1", "iPad5,3", "iPad5,4":
            model = "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":
            model = "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":
            model = "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":
            model = "iPad Mini 3"
        case "iPad5,1", "iPad5,2":
            model = "iPad Mini 4"
        case "iPad6,7", "iPad6,8":
            model = "iPad Pro"
            
        case "i386", "x86_64":
            model = "Simulator"
        default:
            model = deviceCode
        }
        return model
    }
    
    //Device iOS Version : 8.1, 8.1.3, ...
    public var deviceIOSVersion: String {
        return UIDevice.current.systemVersion
    }
    
    public var deviceOrientationString: String {
        var orientation : String
        switch UIDevice.current.orientation{
        case .portrait:
            orientation="Portrait"
        case .portraitUpsideDown:
            orientation="Portrait Upside Down"
        case .landscapeLeft:
            orientation="Landscape Left"
        case .landscapeRight:
            orientation="Landscape Right"
        case .faceUp:
            orientation="Face Up"
        case .faceDown:
            orientation="Face Down"
        default:
            orientation="Unknown"
        }
        return orientation
    }
}

extension Date
{
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
    
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    init(ticks: UInt64) {
        self.init(timeIntervalSince1970: Double(ticks)/10_000_000 - 62_135_596_800)
    }
}

extension NSDate
{
    
    class func getCurrentYear() -> Int
    {
        let currDate = NSDate()
        let components = NSCalendar.current.component(Calendar.Component.year, from: currDate as Date)
        return components
    }
    
    
    class func getDayReturn(_ getDate : Date) -> Int
    {
        //  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        let date = getDate
        let cal = Calendar.current
        let day : Int = cal.component(.day, from: date as Date)
        return day
    }
    
    
    // APP SPECIFIC FORMATS
    func app_stringFromDate() -> String{
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let strdt = dateFormatter.string(from: self as Date)
        if let dtDate = dateFormatter.date(from: strdt){
            return dateFormatter.string(from: dtDate)
        }
        return "--"
    }
    
    func app_dateFormatString() -> String{
        return "\(self.dayOneDigit) \(self.monthNameShort.uppercased()), \(self.dayNameShort.uppercased())"
    }
    
    func app_dateFormatStringShort() -> String{
        return "\(self.dayOneDigit) \(self.monthNameShort.uppercased())"
    }
    
    func app_dateFormatStringForReview() -> String{
        return "\(self.dayOneDigit) \(self.monthNameShort.capitalized), \(self.yearFourDigit)"
    }
    
    func app_dateFormatStringForCreditCardDate() -> String{
        return "\(self.monthNameShort.capitalized), \(self.yearFourDigit)"
    }
    
    func app_dateFormatStringForPlaceOrder() -> String{
        return "\(self.yearFourDigit)-\(self.monthTwoDigit)-\(self.dayTwoDigit)"
    }
    
    func getUTCFormateDate(localDate: NSDate) -> String {
        
        let dateFormatter: DateFormatter = DateFormatter()
        let timeZone: NSTimeZone = NSTimeZone(name: "UTC")!
        dateFormatter.timeZone = timeZone as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let dateString: String = dateFormatter.string(from: localDate as Date)
        return dateString
    }
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending || self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isGreaterThanEqualDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending  {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    class func currentDate() -> NSDate
    {
        let date1 = NSDate()
        let formater : DateFormatter = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        let str = formater.string(from: date1 as Date)
        
        let formater1 : DateFormatter = DateFormatter()
        formater1.dateFormat = "yyyy-MM-dd"
        return formater1.date(from : str)! as NSDate
    }
    
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func isEqualToDateWithoutTime(dateToCompareWith:NSDate) -> Bool {
        if(self.dayTwoDigit_Int == dateToCompareWith.dayTwoDigit_Int &&
            self.monthTwoDigit_Int == dateToCompareWith.monthTwoDigit_Int &&
            self.yearFourDigit_Int == dateToCompareWith.yearFourDigit_Int){
            return true
        }else{
            return false
        }
    }
    
    
    // TIME
    var timeWithAMPM: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self as Date)
    }
    
    var timeWithFull : String
    {
        let dateFormatter = DateFormatter()
        //        NSTimeZone *gmtZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        //        [dateFormatter setTimeZone:gmtZone];
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: self as Date)
    }
    
    
    // YEAR
    
    
    var yearFourDigit_Int: Int {
        return Int(self.yearFourDigit)!
    }
    
    var yearOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y"
        return dateFormatter.string(from: self as Date)
    }
    var yearTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"
        return dateFormatter.string(from: self as Date)
    }
    var yearFourDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self as Date)
    }
    
    
    
    // MONTH
    
    var monthOneDigit_Int: Int {
        return Int(self.monthOneDigit)!
    }
    var monthTwoDigit_Int: Int {
        return Int(self.monthTwoDigit)!
    }
    
    
    var monthOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter.string(from: self as Date)
    }
    var monthTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameShort: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameFull: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameFirstLetter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMMM"
        return dateFormatter.string(from: self as Date)
    }
    
    // DAY
    
    var dayOneDigit_Int: Int {
        return Int(self.dayOneDigit)!
    }
    var dayTwoDigit_Int: Int {
        return Int(self.dayTwoDigit)!
    }
    
    var dayOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self as Date)
    }
    var dayTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameShort: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameFull: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameFirstLetter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: self as Date)
    }
    
    
    
    
    // AM PM
    var AM_PM: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a"
        return dateFormatter.string(from: self as Date)
    }
    
    // HOUR
    
    var hourOneDigit_Int: Int {
        return Int(self.hourOneDigit)!
    }
    var hourTwoDigit_Int: Int {
        return Int(self.hourTwoDigit)!
    }
    var hourOneDigit24Hours_Int: Int {
        return Int(self.hourOneDigit24Hours)!
    }
    var hourTwoDigit24Hours_Int: Int {
        return Int(self.hourTwoDigit24Hours)!
    }
    var hourOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h"
        return dateFormatter.string(from: self as Date)
    }
    var hourTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh"
        return dateFormatter.string(from: self as Date)
    }
    var hourOneDigit24Hours: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H"
        return dateFormatter.string(from: self as Date)
    }
    var hourTwoDigit24Hours: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: self as Date)
    }
    
    // MINUTE
    
    var minuteOneDigit_Int: Int {
        return Int(self.minuteOneDigit)!
    }
    var minuteTwoDigit_Int: Int {
        return Int(self.minuteTwoDigit)!
    }
    
    var minuteOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "m"
        return dateFormatter.string(from: self as Date)
    }
    var minuteTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        return dateFormatter.string(from: self as Date)
    }
    
    
    // SECOND
    
    var secondOneDigit_Int: Int {
        return Int(self.secondOneDigit)!
    }
    var secondTwoDigit_Int: Int {
        return Int(self.secondTwoDigit)!
    }
    
    var secondOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "s"
        return dateFormatter.string(from: self as Date)
    }
    var secondTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ss"
        return dateFormatter.string(from: self as Date)
    }
    
}

extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
extension UIImage {
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 0, height: size.height))//(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage
    {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

public extension UIWindow
{
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(vc: self.rootViewController)
    }
    
    static func getVisibleViewControllerFrom(vc: UIViewController?) -> UIViewController?
    {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(vc: nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(vc: tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: pvc)
            } else {
                return vc
            }
        }
    }
}

extension UIViewController {
    func backViewController() -> UIViewController? {
        if let stack = self.navigationController?.viewControllers {
            for i in (1..<stack.count).reversed() {
                if(stack[i] == self) {
                    return stack[i-1]
                }
            }
        }
        return nil
    }
}

extension UILabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength()
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    func vissibleTextLength() -> Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}

extension AVURLAsset
{
    func getThumbnailImage() -> UIImage? {
        do {
            let imgGenerator = AVAssetImageGenerator(asset: self)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)
        
        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
    
}


