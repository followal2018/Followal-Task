//
//  Global.swift
//  followal
//
//  Created by Vivek Gadhiya on 16/01/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftyJSON
import Contacts
import ObjectMapper
import Alamofire
import Reachability
import UserNotifications




typealias board = R.storyboard
typealias images = R.image
typealias webUrls = R.string.webUrls

typealias Keys = R.string.keys
typealias Localization = R.string.localizable
typealias nibs = R.nib


//MARK: - GENERAL
let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

//MARK: - MANAGERS
let storyBoard = UIStoryboard(name: "Main", bundle: nil)
let ipad_storyboard = UIStoryboard(name: "StoryboardiPad", bundle: nil)


//let UserManager = AIUser.sharedManager
//let CurrentUserAuthID = Auth.auth().currentUser

//MARK: - APP SPECIFIC
let APP_NAME = "Followal"

func getStringFromDictionary(_ dict:AnyObject) -> String{
    var strJson = ""
    do {
        let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        strJson = String(data: data, encoding: String.Encoding.utf8)!
    } catch let error as NSError {
    }
    
    return strJson
}
struct UserDefaultDataKeys {
    static let token = "accessToken"
    static let userID = "userID"
    static let isUserLogIn = "loginFlag"
    static let userDetail = "userDetail"
}


//MARK: - IMAGE
func ImageNamed(_ name:String) -> UIImage?{
    return UIImage(named: name)
}

let VIDEO_UPLOAD_MAX_LENGTH_MB = 25.0
let VIDEO_UPLOAD_MAX_LENGTH    = 30

// FONT

let FONT_REGULAR = "HelveticaNeue"
let FONT_LIGHT = "HelveticaNeue-Light"
let FONT_MEDIUM = "HelveticaNeue-Medium"
let FONT_SEMIBOLD = "HelveticaNeue-Medium"
let FONT_THIN = "HelveticaNeue-Thin"
let FONT_BOLD = "HelveticaNeue-Bold"
let FONT_EXTRABOLD = "HelveticaNeue"
let FONT_BLACK = "HelveticaNeue"





let SYSTEM_BOLD_FONT  = UIFont.boldSystemFont(ofSize: 19)
let SYSTEM_REGULAR_FONT  = UIFont.systemFont(ofSize: 14)
let SYSTEM_MEDIUM_FONT = UIFont.boldSystemFont(ofSize: 17)


//MARK: - COLORS
public func RGBCOLOR(_ r: CGFloat, g: CGFloat , b: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

public func RGBCOLOR(_ r: CGFloat, g: CGFloat , b: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
}

let APP_THEME_COLOR  = RGBCOLOR(0, g:125, b:254)
let APP_NAVIGATION_COLOR  = APP_THEME_COLOR
let APP_BUTTON_COLOR = RGBCOLOR(255, g:255, b:255)
let APP_TEXTFIELD_TINT_COLOR = UIColor.white
let APP_RED_COLOR = RGBCOLOR(200, g:35, b:0)
let APP_GREEN_COLOR = RGBCOLOR(97, g:166, b:64)

let APP_LABEL_BLACK_COLOR = RGBCOLOR(0, g:0, b:0)
let APP_TEXTFIELD_BLACK_COLOR = RGBCOLOR(255, g:255, b:255)

let APP_WHITE_TEXT_COLOR = UIColor.white
let APP_DARK_SEPERATOR_COLOR = RGBCOLOR(120, g:120, b:120)
let APP_SEPERATOR_COLOR = RGBCOLOR(221, g:221, b:221)
let APP_PLACEHOLDER_COLOR = UIColor.lightGray
let APP_HEADER_TEXT_COLOR = RGBCOLOR(49, g:49, b:49)
let APP_HEADER_TEXT_BLACK_COLOR = UIColor.black
let APP_LIGHT_GRAY_COLOR = UIColor.lightGray
let APP_DARK_GRAY_COLOR = UIColor.darkGray

let APP_CORNER_RADIOUS:CGFloat = 5

//MARK: - SCREEN SIZE

let NAVIGATION_BAR_HEIGHT:CGFloat = 64
let SCREEN_BOUNDS = UIScreen.main.bounds
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let is_iPhone : Bool! = UIDevice.current.userInterfaceIdiom == .phone

func GET_PROPORTIONAL_WIDTH (_ width:CGFloat) -> CGFloat {
    return ((SCREEN_WIDTH * width)/375)
}
func GET_PROPORTIONAL_HEIGHT (_ height:CGFloat) -> CGFloat {
    return ((SCREEN_HEIGHT * height)/667)
}

func GET_PROPORTIONAL_WIDTH_CELL (_ width:CGFloat) -> CGFloat {
    return ((SCREEN_WIDTH * width)/375)
}
func GET_PROPORTIONAL_HEIGHT_CELL (_ height:CGFloat) -> CGFloat {
    return ((SCREEN_WIDTH * height)/667)
}

// MARK: - KEYS FOR USERDEFAULTS

let DeviceToken = "DeviceToken"

let IS_SIGNUP = "isSignup"

//Language Localized
let LOCALIZE_ENGLISH    = "English"
let LOCALIZE_ARABIC      = "Arabic"

// MARK: - USERDEFAULTS

func setUserDefaultValues(_ key : String , value : String)
{
    let userDefault : UserDefaults = UserDefaults.standard
    userDefault.set(value, forKey: key)
    userDefault.synchronize()
}

func setIntUserDefaultValue(_ key : String , value : Int)
{
    let userDefault : UserDefaults = UserDefaults.standard
    userDefault.set(value, forKey: key)
    userDefault.synchronize()
}

func getIntUserDefaultValue(_ key : String) -> String
{
    let userDefault : UserDefaults = UserDefaults.standard
    var value : Int = 0
    if userDefault.value(forKey: key) != nil
    {
        value = userDefault.value(forKey: key) as! Int
    }
    return String(value)
}

func getUserDefaultValue(_ key : String) -> String
{
    let userDefault : UserDefaults = UserDefaults.standard
    var value : String = ""
    if userDefault.value(forKey: key) != nil
    {
        value = userDefault.value(forKey: key) as! String
    }
    return value
}

func setBoolUserDefaultValue(_ key : String , value : Bool)
{
    let userDefault : UserDefaults = UserDefaults.standard
    userDefault.set(value, forKey: key)
    userDefault.synchronize()
}

func getBoolUserDefaultValue(_ key : String) -> Bool
{
    var value : Bool = false
    let userDefault : UserDefaults = UserDefaults.standard
    if userDefault.value(forKey: key) != nil
    {
        value = userDefault.value(forKey: key) as! Bool
    }
    return value
}

func setAttributedLabel(strString : String, lbl:UILabel)  {
    var myMutableString = NSMutableAttributedString()
    myMutableString = NSMutableAttributedString(string: strString)
    myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: APP_PLACEHOLDER_COLOR, range: NSRange(location:strString.count - 1 ,length:1))
    lbl.attributedText = myMutableString
}

let appDelegte = UIApplication.shared.delegate as! AppDelegate

let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "IN"

class CornersOfChatView {
    static let cornerRadiusOfChat = 10.0
}
class Colors {
    static let blueTheme = UIColor(displayP3Red: 133.0/255.0, green: 68.0/255.0, blue: 237.0/255.0, alpha: 1.0)
    static let blackTheme = UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let darkFont = UIColor(displayP3Red: 130.0/255.0, green: 130.0/255.0, blue: 130.0/255.0, alpha: 1.0)
    static let lightGray = UIColor(displayP3Red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    static let green = UIColor(displayP3Red: 63.0/255.0, green: 202.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    static let red = UIColor(displayP3Red: 244.0/255.0, green: 67.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    static let headerBlack =  Colors.blackTheme
}
class HeaderConstant {
    static let headerHeightRadius: CGFloat =  9.5
    
    
    
}


func getDeviceToken() -> String {
    return UserDefaults.standard.value(forKey: "deviceToken") as? String ?? ""
}

func getAccessToken() -> String {
    return UserDefaults.standard.value(forKey: Keys.access_token()) as? String ?? ""
}

func getUserID() -> String {
    return UserDefaults.standard.value(forKey: Keys.userID()) as? String ?? ""
}

func isUserLogin() -> Bool {
    return UserDefaults.standard.bool(forKey: Keys.isUserLogIn())
}

func getUserDetail() -> JSON {
    if let data = UserDefaults.standard.value(forKey:Keys.registerData()) as? Data {
        let json = JSON(data)
        return json
    }
    return ""
}


let noOfPhotoSelections = 10
var tabController = UITabBarController()

var realm = try! Realm()

var contactStore = CNContactStore()

func getGeneralAPIHeader() -> HTTPHeaders {
    let header: HTTPHeaders =
        [
            "Content-Type": "application/json",
            "X-Authorization": getAccessToken()
    ]
    return header
}

func getUserDetail(forKey: String) -> String {
    // Profileimage,  Dob, Profileimagepath, Gender, Username
    if let data = UserDefaults.standard.value(forKey: Keys.registerData()) as? Data {
        let json = JSON(data)
        //print(json)
        return json[forKey].stringValue
    }
    return ""
}

func getUserData(forKey: String) -> String {
    
    // Otp, _id, Mobilenumber, FcmToken
    if let data = UserDefaults.standard.value(forKey: Keys.userData()) as? Data {
        let json = JSON(data)   
        return json[forKey].stringValue
    }
    return ""
}
struct ChatCellHeight {
    
    let file = CGFloat(SCREEN_WIDTH * 0.72) * 0.78
    let contact = 120.0
    let document = 85.0
    let jobtemplete = 150.0
    let interviewInvitation = 165.0
    let location = 185.0
    let chatTextSender = 35.0
    let chatTextReceiver = 35.0
    let audio = 90.0
    let attachment = CGFloat(SCREEN_WIDTH * 0.65) * 0.72
}


struct NibIdentifiers {
    static let  customCameraViewController = "CustomCameraViewController"
    static let  myStoryViewController = "MyStoryViewController"
    static let  stickersViewController = "StickersViewController"
    static let  mediaCaptionViewController = "MediaCaptionViewController"
    static let  attachmentView = "AttachmentView"
    static let  headerView = "headerView"
}


struct CellIdentifiers {
    static let  openningHoursTableViewCellIdentifiers = "OpenningHoursTableViewCell"
    static let  myLocation = "myLocation"
    static let  annotationView = "annotationView"
    static let  nearByCell = "NearByCell"
    static let  senderTextCell = "senderTextCell"
    static let  receiverTextCell = "receiverTextCell"
    static let  contactCell = "contactCell"
    static let  chatImageTableViewCell = "ChatImageTableViewCell"
    static let  documentCell = "documentCell"
    static let  recentStoryTableViewCell = "RecentStoryTableViewCell"
    static let  addStatusStoryCell = "AddStatusStoryCell"
    static let  cell = "cell"
    static let  messageResultCell = "messageResultCell"
    static let  statusCollectionViewCell = "StatusCollectionViewCell"
    static let  photosCollectionViewCell = "PhotosCollectionViewCell"
    static let  centerCollectionViewCell = "CenterCollectionViewCell"
    static let  contactTableViewCell = "ContactTableViewCell"
    static let  settingTableViewCell = "SettingTableViewCell"
    static let  contactPickerSelectedCell = "ContactPickerSelectedCell"
    static let  additionalCell = "additionalCell"
    static let  headerCell = "headerCell"
    static let  docCell = "docCell"
    static let  linkCell = "linkCell"
    static let  addExperienceTableViewCell = "AddExperienceTableViewCell"
    static let  addEducationTableViewCell = "AddEducationTableViewCell"
    static let  addAwardTableViewCell = "AddAwardTableViewCell"
    static let  addProjectTableViewCell = "AddProjectTableViewCell"
    static let  experienceCell = "experienceCell"
    static let  projectCell = "projectCell"
    static let  educationCell = "educationCell"
    static let  awardCell = "awardCell"
    static let  jobPostTableViewCell = "JobPostTableViewCell"
    static let  allResumeTableViewCell = "AllResumeTableViewCell"
    static let  interviewInviteTableViewCell = "InterviewInviteTableViewCell"
    static let  interviewListTableViewCell = "InterviewListTableViewCell"
    static let  interviewListJobTableViewCell = "InterviewListJobTableViewCell"
    static let  interviewTimeAvailabilityTableViewCell = "InterviewTimeAvailabilityTableViewCell"
    static let  addressCell = "addressCell"
    static let  allJobsTableViewCell = "AllJobsTableViewCell"
    static let  myResumeTableViewCell = "MyResumeTableViewCell"
    static let  jobFilterHeaderTableViewCell = "JobFilterHeaderTableViewCell"
    static let  jobFilterContentTableViewCell = "JobFilterContentTableViewCell"
    static let  sideMenuCell = "SideMenuCell"
    static let  repeatAlarmDayCell = "RepeatAlarmDayCell"
    static let  dayCell = "DayCell"
    static let  chatJobTempleteTableViewCell = "ChatJobTempleteTableViewCell"
    static let  chatInterviewScheduleTableViewCell = "ChatInterviewScheduleTableViewCell"
    static let  jobtyperesumecell = "Jobtyperesumecell"
    

}

struct HexString{
    static let hex_startcolor = "#8544ED"
    static let hex_endcolor = "#1E9CFF"
    /*
     393e46 & 00adb5
     08d9d6 & 252a34
     222831 & 393e46
     */
//    static let hex_startcolor = "#222831"
//    static let hex_endcolor = "#393e46"
//    static let hex_startcolor = "#2D132C"
//    static let hex_endcolor = "#7D1335"

    static let hex_607D8B = "#607D8B"
    static let hex_A93226 = "#A93226"
    static let hex_2471A3 = "#2471A3"
    static let hex_17A589 = "#17A589"
    static let hex_D4AC0D = "#D4AC0D"
    static let hex_7D3C98 = "#7D3C98"
    static let hex_273746 = "#273746"
    static let hex_28B463 = "#28B463"
    static let hex_BA4A00 = "#BA4A00"
    static let hex_707B7C = "#707B7C"
    static let hex_CB4335 = "#CB4335"
    static let hex_2E86C1 = "#2E86C1"
    static let hex_138D75 = "#138D75"
    static let hex_D68910 = "#D68910"
    static let hex_A6ACAF = "#A6ACAF"
    static let hex_884EA0 = "#884EA0"
    static let hex_2E4053 = "#2E4053"
    static let hex_229954 = "#229954"
    static let hex_CA6F1E = "#CA6F1E"
    static let hex_839192 = "#839192"
    static let hex_8e8e93 = "#8e8e93"
    static let hex_434343 = "#434343"
    static let hex_212121 = "#212121"
    static let hex_F7F7F7 = "#F7F7F7"
    static let hex_B2B2B2 = "#B2B2B2"
    static let hex_007DFF = "#007DFF"
    static let hex_EFEFF4 = "#EFEFF4"
    static let hex_E4E4E4 = "#E4E4E4"
    static let hex_FFFFFF = "#FFFFFF"
    static let hex_385E7C = "#385E7C"
    static let hex_000000 = "#000000"
    static let hex_7d7d7d = "#7d7d7d"
    static let hex_CCCCCC = "#CCCCCC"
    static let hex_027DFD = "#027DFD"
    static let hex_DBEBFB = "#DBEBFB"
    static let hex_e4e4e4 = "#e4e4e4"
    static let hex_f9f9f9 = "#f9f9f9"
    static let hex_A28988 = "#A28988"
    static let hex_6B7f93 = "#6B7f93"
    static let hex_FD6247 = "#FD6247"
    static let hex_Sender = "#E4E4E4"//CDD2D7
    static let hex_Receiver = "#F4F4F4"
    static let hex_JobInterViewHeader = "#747474"

}

struct DateFormats {
    static let DFHHmm = "HH.mm"
    static let DFhmma = "h:mm a"
    static let DFhhmma = "hh:mm a"
    static let DFhhmmaddmmyyyy = "hh:mm a, dd-MM-yyyy"
    static let DFhhmmaa = "hh:mma"
    static let DFddMMyyyy = "dd/MM/yyyy"
    static let DFMMddyyyy = "MM/dd/yyyy"
    static let DFdd_MM_yyyy = "dd-MM-yyyy"
    static let DFyyyy_MM_dd_HH_mm_ss = "yyyy_MM_dd_HH_mm_ss"
    static let DFyyyyMMddHHmmss = "yyyyMMddHHmmss"
    static let DFyyyyMMdd = "yyyy/MM/dd"
    static let DFyyyy_MM_dd = "yyyy:MM:dd"
    static let DFHHmmss_S = "HH:mm:ss.SSSSSS"
    static let DFMMMMyyyy = "MMMM, yyyy"
    static let DFyyyyMMddTHHmmss = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let DFyyyyMMddTHHmmssZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    static let DFddMMM = "dd MMM"
    static let DFddMMMYYYY = "dd MMM yyyy"
    static let DFyyyyMMddhhmma = "yyyy-MM-dd hh:mm a"
    static let DFddMMMyyyyhhmma = "dd MMM yyyy - hh:mm a"
    
}

func loginUserID() -> String {
    return UserDefaults.standard.value(forKey: Keys.userId()) as? String ?? ""
}


func multiLoginID() -> String {
    return UserDefaults.standard.value(forKey: Keys.multiLoginID()) as? String ?? ""
}

func getSocketID() -> String {
    return UserDefaults.standard.value(forKey: Keys.socket_id()) as? String ?? ""
}

var hasTopNotch: Bool {
    if #available(iOS 11.0, tvOS 11.0, *) {
        // with notch: 44.0 on iPhone X, XS, XS Max, XR.
        // without notch: 24.0 on iPad Pro 12.9" 3rd generation, 20.0 on iPhone 8 on iOS 12+.
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
    }
    return false
}

//func FirebaseAnalyticsLog(name:String){
//    Analytics.logEvent("screen_name", parameters: [
//        "name": name as NSObject,
//        ])
//}

public func debugLog(object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    #if DEBUG
    let className = (fileName as NSString).lastPathComponent
    print("<\(className)> \(functionName) [#\(lineNumber)]| \(object)\n")
    #endif
}
