//
//  AppDelegate.swift
//  Followal Task
//
//  Created by iMac on 17/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import CoreLocation
import AVKit
import SocketIO
import PushKit
import RealmSwift
import UserNotifications
import Reachability
import PushKit
import SwiftyJSON
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift
import ARSLineProgress

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
    
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    var isSocketConnected = BehaviorRelay<Bool>(value: false)
    var socket: SocketIOClient!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = "802043134914-1u13rvr5s1conenaarrei6sklp1fmgfv.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = Colors.blueTheme
        navigationBarAppearace.barTintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:Colors.blueTheme]
        notificationCenter.delegate = self
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        

        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        voipRegistration()
        realmMigration()
        TaskHelper.setAllTask()
      //  let arr = realm.objects(FolderResponseModel.self).filter({$0.FolderName == "Inbox"})
       //TaskHelper.prepareRequestAssignFolder("5d4904939bca710bd9c68835")
        
        return true
    }
   
        
     func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
       // UNUserNotificationCenter.current().cleanRepeatingNotifications()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return (GIDSignIn.sharedInstance()?.handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]))!
//    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }

    
    //MARK:- Realm Migration
    func realmMigration() {
        let config = Realm.Configuration(
            schemaVersion: 22,
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 0 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    
    
    //MARK:- GIDSignIn Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let givenName = user.profile.givenName
            let email = user.profile.email
            let req = RegisterRequest()
            req.emailAddress = email ?? ""
            req.deviceType = "ios"
            req.userLoginType = "Google"
            req.userName = givenName ?? ""
            req.pushToken = getDeviceToken()
            req.googleId = userId ?? ""
            req.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            if user.profile.hasImage{
                req.profile = user.profile.imageURL(withDimension: 200)?.absoluteString ?? ""
            }
            let request = RequestBaseModel<RegisterRequest>()
            request.data = req
            request.eventName = "Login"
            self.signupWith(request: request)
            
//
//            let strMessage = "User ID : \(userId ?? "")\ngivenName : \(givenName ?? "")\nfullName : \(fullName ?? "")\nfamilyName : \(familyName ?? "")\nemail : \(email ?? "")\n"
//            let alertCv = UIAlertController(title: "Followal Task", message: strMessage, preferredStyle: .alert)
//            alertCv.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
//
//            }))
//            window?.rootViewController?.present(alertCv, animated: true, completion: {
//
//            })
        }
    }
    
    
    //MARK:- Login
    
    func signupWith(request: RequestBaseModel<RegisterRequest>) {
        
       // UIApplication.shared.beginIgnoringInteractionEvents()
        let url = webUrls.baseURL() + webUrls.login()
        ARSLineProgress.show()
        ServiceManager().request(url: url, inputModel: request) { (response) in
            
            //UIApplication.shared.endIgnoringInteractionEvents()
            ARSLineProgress.hide()

            guard let response = response else {
                showAlertView(with: R.string.localizable.somethingWentWrong(), viewController: self.window!.rootViewController!)
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                let responseModel = try decoder.decode(ResponseBaseModel<RegisterResponseModel>.self, from: jsonData)
                if responseModel.returnValue {
                    UserDefaults.standard.set(true, forKey: Keys.isUserLogIn())
                    UserDefaults.standard.set(responseModel.data?.Token ?? "", forKey: Keys.access_token())
                    UserDefaults.standard.set(responseModel.data?._id ?? "", forKey: Keys.userID())
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(responseModel.data) {
                        UserDefaults.standard.set(encoded, forKey: Keys.registerData())
                    }
                    TaskHelper.login()
                } else {
                    showAlertView(with: responseModel.returnMsg, viewController: self.window!.rootViewController!)
                }
               
                
            } catch let error {
                showAlertView(with: error.localizedDescription, viewController: self.window!.rootViewController!)

            }
            
            
        }
    }
}

extension UNUserNotificationCenter {
    func cleanRepeatingNotifications() {
        //cleans notification with a userinfo key endDate
        //which have expired.
        var cleanStatus = "Cleaning...."
        getPendingNotificationRequests {
            (requests) in
            for request in requests{
                if let endDate = request.content.userInfo["endDate"] {
                    if Date() >= (endDate as! Date){
                        cleanStatus += "Cleaned request"
                        let center = UNUserNotificationCenter.current()
                        center.removePendingNotificationRequests(
                            withIdentifiers: [request.identifier])
                    } else {
                        cleanStatus += "No Cleaning"
                    }
                    print(cleanStatus)
                }
            }
        }
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       TaskHelper.setAllTask()

        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        
        completionHandler()
    }
}

// MARK: - Pushkit Methods
extension AppDelegate: PKPushRegistryDelegate {
    
    func voipRegistration() {
        let pushRegistery = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistery.delegate = self
        pushRegistery.desiredPushTypes = [PKPushType.voIP]
        
        print("Voip Registered")
        #if targetEnvironment(simulator)
        print("Voip for simulator")
        UserDefaults.standard.set(UUID().uuidString, forKey: "deviceToken")
        #endif
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("voip token: \(pushCredentials.token)")
        let token = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaults.standard.set(token, forKey: "deviceToken")
        print(token.uppercased())
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        UserDefaults.standard.set(Date(), forKey: "lastRefreshDate")
        TaskHelper.setAllTask()
        //createLocalNotification(title: "Voip Push", body: json["aps"]["alert"].stringValue, info: [:])
    }
    
    func createLocalNotification(title: String, body: String, info: [String: String]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = ["message_detail": info]
        print("Noti Info : \(info)")
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest.init(identifier: UUID.init().uuidString, content: content, trigger: trigger)
        
        // Schedule the notification.
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("We had an error in Local notification: \(error)")
            }
        }
    }
    
}
