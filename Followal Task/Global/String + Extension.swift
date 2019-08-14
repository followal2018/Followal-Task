//
//  String + Extension.swift
//  followal
//
//  Created by Vivek Gadhiya on 23/05/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    
    public var length: Int { return self.count }
    
    public func toURL() -> URL? {
        return URL(string: self)
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func seperatedBySymbol() -> [String] {
        let symbols = CharacterSet(charactersIn: "[]~|+=<>\\{}()-@#$%^&*:;.,₹/?!\"\'-_ ")
        return self.components(separatedBy: symbols).filter { !$0.isEmpty }.map { $0.trimmed() }
    }
    
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter { okayChars.contains($0) }.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var isPhoneNumber: Bool {
        let allowedCharacters = CharacterSet(charactersIn: "+0123456789").inverted
        let inputString = components(separatedBy: allowedCharacters)
        let filtered = inputString.joined(separator: "")
        return self == filtered
        
    }
    
    public func toDate(format : String = "yyyy-MM-dd") -> Date? {
        let text = self.trimmed().lowercased()
        let dateFmt = DateFormatter()
        dateFmt.timeZone = NSTimeZone.default
        dateFmt.dateFormat = format
        return dateFmt.date(from: text) as Date?
    }
    
    func isValidURL() -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }
    
    func isEmail() throws -> Bool {
        let regex = try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9]+\\.[A-Za-z]{2,64}$", options: [.caseInsensitive])
        
        return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, count)) != nil
    }
    
    func isAlphaSpace() throws -> Bool {
        let regex = try NSRegularExpression(pattern: "^[A-Za-z ]*$", options: [])
        return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, count)) != nil && self != ""
    }
    
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }
    
    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }
    
    func isNumeric() throws -> Bool {
        let regex = try NSRegularExpression(pattern: "^[0-9]*$", options: [])
        
        return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, count)) != nil
    }
    
    func isRegistrationNumber() throws -> Bool {
        let regex = try NSRegularExpression(pattern: "^[A-Za-z0-9 ]*$", options: [])
        
        return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, count)) != nil
    }
    
    func isValidDate(dateFormat: String) -> Bool {
        if self.toDate(format: dateFormat) == nil {
            return false
        }
        return true
    }
    
    func getPlural(count: Int) -> String {
        if count == 1 {
            return self
        } else {
            return "\(self)s"
        }
    }
    
    func formateFileSize(byteCount: Int) -> String {
        if (byteCount < 1000) { return "\(byteCount) B" }
        let exp = Int(log2(Double(byteCount)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(byteCount) / pow(1000, Double(exp))
        return String(format: "%.1f %@", number, unit)
    }
    
}

//MARK: - String Manipulation
extension String {
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [.font : font], context: nil)
        return actualSize.height
    }
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
    }
    
    func substring(to : Int) -> String? {
        if (to >= length) {
            return nil
        }
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return self.substring(to: toIndex)
    }
    
    func index(at offset: Int, from start: Index? = nil) -> Index? {
        return index(start ?? startIndex, offsetBy: offset, limitedBy: endIndex)
    }
    
    func character(at offset: Int) -> Character? {
        precondition(offset >= 0, "offset can't be negative")
        guard let index = index(at: offset) else { return nil }
        return self[index]
    }
    
    subscript(_ range: CountableRange<Int>) -> Substring {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        return self[start..<(index(at: range.count, from: start) ?? endIndex)]
    }
    subscript(_ range: CountableClosedRange<Int>) -> Substring {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        return self[start..<(index(at: range.count, from: start) ?? endIndex)]
    }
    subscript(_ range: PartialRangeUpTo<Int>) -> Substring {
        return prefix(range.upperBound)
    }
    subscript(_ range: PartialRangeThrough<Int>) -> Substring {
        return prefix(range.upperBound+1)
    }
    subscript(_ range: PartialRangeFrom<Int>) -> Substring {
        return suffix(max(0,count-range.lowerBound))
    }
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

extension StringProtocol where Index == String.Index {
    func nsRange(of string: Self, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> NSRange? {
        guard let range = self.range(of: string, options: options, range: range ?? startIndex..<endIndex, locale: locale ?? .current) else { return nil }
        return NSRange(range, in: self)
    }
    
    func nsRanges(of string: Self, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> [NSRange] {
        var start = range?.lowerBound ?? startIndex
        let end = range?.upperBound ?? endIndex
        var ranges: [NSRange] = []
        while start < end, let range = self.range(of: string, options: options, range: start..<end, locale: locale ?? .current) {
            ranges.append(NSRange(range, in: self))
            start = range.upperBound
        }
        return ranges
    }
}

extension Substring {
    var string: String { return String(self) }
}

//Test Be like this
//let test = "Hello USA 🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test.character(at: 10)   // "🇺🇸"
//test.character(at: 11)   // "!"
//test[10...]   // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
//test[10..<12]   // "🇺🇸!"
//test[10...12]   // "🇺🇸!!"
//test[...10]   // "Hello USA 🇺🇸"
//test[..<10]   // "Hello USA "
//test.first   // "H"
//test.last    // "!"
//
//// Note that they all return a Substring of the original String.
//// To create a new String you need to add .string as follow
//test[10...].string  // "🇺🇸!!! Hello Brazil 🇧🇷!!!"

public extension String {
    
    func validateFirstName() -> Bool {
        do {
            if !(try self.isAlphaSpace()) {
                return false
            }
        } catch {
            return false
        }
        
        return true
    }
    
    func isValidEmail() -> Bool {
        if self.length == 0 {
            return false
        } else {
            do {
                if !(try self.isEmail()) {
                    return false
                }
            } catch {
                return false
            }
        }
        
        return true
    }
    
    func validatePassword() -> Bool {
        if self.length == 0 {
            return false
        }
        return true
    }
    
}

extension String {
    
    func getImage(completionHandler: @escaping (UIImage) -> ()){
        let url = URL(string:
            webUrls.hostURL() + self)
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {    // execute on main thread
                if let img = UIImage(data: data) {
                    completionHandler(img)
                }
            }
        }
        task.resume()
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
}

extension UILabel {
    
    func setHighlightString(from searchString: String, into: String) {
        
        let attrStr = NSMutableAttributedString(string: into)
        let inputLength = attrStr.string.count
        let searchLength = searchString.count
        var range = NSRange(location: 0, length: attrStr.length)
        
        while (range.location != NSNotFound) {
            range = (attrStr.string as NSString).range(of: searchString, options: [], range: range)
            if (range.location != NSNotFound) {
                attrStr.addAttributes([NSAttributedString.Key.backgroundColor : UIColor.yellow], range: NSRange(location: range.location, length: searchLength))
                range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
            }
        }
        
        self.attributedText = attrStr
    }
    
}

func formatPoints(num: Double) -> String{
    var thousandNum = num/1000
    var millionNum = num/1000000
    if num >= 1000 && num < 1000000{
        if(floor(thousandNum) == thousandNum){
            return String(format: "%.1f", thousandNum) + "k"
            
        }
        return String(format: "%.1f", thousandNum.roundToPlaces(places: 1)) + "k"
    }
    if num > 1000000{
        if(floor(millionNum) == millionNum){
            return String(format: "%.1f", thousandNum) + "k"
        }
        return String(format: "%.1f", millionNum.roundToPlaces(places: 1)) + "M"
    }
    else{
        if(floor(num) == num){
            return ("\(Int(num))")
        }
        return String(format: "%.1f", num)
    }
    
}

func formatDigits(num: Double) -> String{
    var thousandNum = num/1000
    var millionNum = num/1000000
    if num >= 1000 && num < 1000000{
        if(floor(thousandNum) == thousandNum){
            return String(format: "%.0f", thousandNum) + "k"
            
        }
        return String(format: "%.0f", thousandNum.roundToPlaces(places: 1)) + "k"
    }
    if num > 1000000{
        if(floor(millionNum) == millionNum){
            return String(format: "%.0f", thousandNum) + "k"
        }
        return String(format: "%.0f", millionNum.roundToPlaces(places: 1)) + "M"
    }
    else{
        if(floor(num) == num){
            return ("\(Int(num))")
        }
        return String(format: "%.0f", num)
    }
    
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor) / divisor
        
    }
}


extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                    print(error.localizedDescription)
            }
        }
            return nil
    }
    
    func addImageWith(images: [UIImage?], behindText: Bool) -> NSAttributedString {
        
        let strings = images.map({ image -> NSAttributedString in
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -image!.size.height / 4, width: image!.size.width, height: image!.size.height)
            return NSAttributedString(attachment: attachment)
        })
        
        if behindText {
            let strLabelText = NSMutableAttributedString(string: self)
            strings.forEach { strLabelText.append($0) }
            return strLabelText
        } else {
            let strLabelText = NSAttributedString(string: " " + self)
            let mutableAttachmentString = NSMutableAttributedString(string: "")
            strings.forEach { mutableAttachmentString.append($0) }
            mutableAttachmentString.append(strLabelText)
            return mutableAttachmentString
        }
    }
    
}
