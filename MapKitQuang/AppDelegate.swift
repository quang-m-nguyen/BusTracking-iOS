//
//  AppDelegate.swift
//  MapKitQuang
//
//  Created by Quang Nguyen on 3/6/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import SwiftyJSON



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var i = 0;
    
    var vc = ViewController()
    var FinalView = FinalViewController()
    
    var availableBus = [0,0,0,0]
    
    
    var defaults = NSUserDefaults.standardUserDefaults()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = hexStringToUIColor("#B8CCCA")
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        
        FIRApp.configure()
        //set notification types
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge]
        
        //add notification typees to our setting
        let mySettings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        
        application.registerForRemoteNotifications()
        
        //now call for the settings
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        
        
        
        // Add observer for InstanceID token refresh callback.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                                         name: kFIRInstanceIDTokenRefreshNotification, object: nil)
   
   
        
        
        
//        let refreshedToken = FIRInstanceID.instanceID().token()!
//        
//        
//        //print("firebase token : " + refreshedToken)
//        print("InstanceID token: \(refreshedToken)")
//        
//        defaults.setObject(refreshedToken, forKey: "token")
//
//        var urltoken = "http://sudokit.com:3000/Register/"+refreshedToken+"/0"+"/0"
//        let url = NSURL(string: urltoken)
//        
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
//            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
//            var receivedStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            
//            
//        }
//        
//        task.resume()
        

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // vc.TriggerBG()

        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
              connectToFcm()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        //vc.TriggerBG()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        connectToFcm()
       
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
                    print(i)
               i += 1
        print(userInfo)

        
        var busStopName = defaults.valueForKey("busStopName")
        var UserSelectedBusRoute = defaults.valueForKey("UserSelectedBusRoute")
        var UserSelectedBusTime = defaults.valueForKey("UserSelectedBusTime")

        
        
        var routeID = ["99163E", "99163I","99163North","99163South" ]
       
        //print(userInfo["busArray"])
            
//                            if let JSON1 = userInfo["busArray"] {
//                                //print(JSON1)
//                                var jsonArr:[JSON] = JSON(JSON1).arrayValue
//                                for var i = 0; i < jsonArr.count ; i+=1 {
//                                        print(jsonArr)
//                                }
//                            }
        
//        var temp = String(userInfo["busArray"])
//        //var some = JSON.parse(temp)
//        print(temp)

        if let msg = userInfo["busArray"]         {
            
            var newmsg = JSON(msg).rawString()
            
            var newjson = JSON.parse(newmsg!)
            print(newjson[0]["StopID"])
            
            print("count: " + String(newjson.count))
            //print(newmsg.rawString())
            
            
            
            
            for i in 0 ..< newjson.count {
                
                var routevalue = newjson[i]["RouteID"]
                
                   var position = newjson[i]["Time"]
                
                        self.defaults.setObject(position.stringValue, forKey: routevalue.stringValue)
                        self.defaults.synchronize()
                
                
                // print(busStopName)
                // print(UserSelectedBusRoute)
                if((UserSelectedBusTime) != nil)
                {
                if((busStopName) != nil)
                {
                    if((UserSelectedBusRoute) != nil)
                    {

                        
                        if let somevar = UserSelectedBusRoute
                        {
//                            print("routevalue")
//                            print(routevalue)
//                            print("UserSelectedBusRoute")
//                            print(somevar)
                        if(routevalue.stringValue == somevar as! String)
                        {
                            if( position.double <= UserSelectedBusTime?.doubleValue )
                            {
                                print("setting alarm nowww")
                                
                                                    let notification = UILocalNotification()
                                                    notification.fireDate = NSDate (timeIntervalSinceNow: 0)
                                                    notification.alertBody = "your bus is near"
                                                    notification.timeZone = NSTimeZone.localTimeZone()
                                                    notification.soundName = UILocalNotificationDefaultSoundName
                                                    notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                                                    
                                                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                                
                                defaults.removeObjectForKey("UserSelectedBusTime")
                            
                            }
                        
                        }
                        }
                    }
                }
                }
                
                
            }
        }
        
        
        
        

        
        
        
        
        
        
        
       
        //
       // FinalView.remainTime.text = 
        //var
        
        
        // print(String(position))
        
        

        
        
//        for var i = 0; i < routeID.count; i += 1 {
//            
//            if let routevalue = userInfo["route"]
//            {
//            if(routeID[i] == routevalue as! String)
//            {
//                availableBus[i] = 1;
//            }
//            }
//        }
        
       // print(availableBus)
        
   
         

        
        //   application.registerForRemoteNotifications()
        
       // if let aps = userInfo["time"]  {
            
//            if(( userInfo["time"]?.isEqualToString("3") ) != nil){
//                print("MATTTTTCHHHHHhhhhhhhhhhhh")
//                
//                let notification = UILocalNotification()
//                                    notification.fireDate = NSDate (timeIntervalSinceNow: 0)
//                                    notification.alertBody = "Your Bus is Here!"
//                                    //notification.soundName = "gc.mp3"
//                                    notification.timeZone = NSTimeZone.localTimeZone()
//                                    notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
//                                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
//
//            
//            
//            
//          //  }
//            
//        }

        ////             //setting up TEST notification
//        var a = userInfo["time"]
//        if(String(a) == "0")
//        {
//                    let notification = UILocalNotification()
//                    notification.fireDate = NSDate (timeIntervalSinceNow: 1)
//                    notification.alertBody = String(userInfo["time"])
//                    //notification.soundName = "gc.mp3"
//                    notification.timeZone = NSTimeZone.localTimeZone()
//                    notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
//                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
//        }
            
      //  })
        
        
       completionHandler(.NewData);

    
  }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .Unknown)
        print("Device Token:", tokenString)
        
       
       if let refreshedToken = FIRInstanceID.instanceID().token() {
        print("InstanceID token: \(refreshedToken)")
                self.defaults.setObject(refreshedToken, forKey: "token")
        }
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    // [START refresh_token]
    func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            self.defaults.setObject(refreshedToken, forKey: "token")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
                FIRMessaging.messaging().disconnect()
                self.connectToFcm()
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//     
//            print(i)
//        i += 1
//        print("DID GET REMOTE1111")
//        print(userInfo)
//    }
    

    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

