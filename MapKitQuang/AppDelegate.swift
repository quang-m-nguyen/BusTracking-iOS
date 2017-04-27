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
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var i = 0;
    var inbg = 0;
    var toSendNot = 0;
    var alertsent = 0;
    var busAlarm: [String] = []
    var routeID = ["99163E", "99163I","99163North","99163South" ]
    var indexToDelete = [Int]()
    var VrouteArr = [String]()
    var VrouteInfo = [String]()
    var VrouteID = [String]()
    var BusID = [String]()
    //    var cellColor = ["#B26CAD", "#FFE787", "#FF2DF0", "#63B2AA"]
    //var cellColor = ["#EC7A08", "#B6BF00", "#3CB6CE", "#DBCEAC"]
    var cellColor = [String]()
    var OpHours = [String]()
    
    var busReceive = [Alarm]()
    
  //  var UrlDomain = "http://sudokit.com:3000"
   var UrlDomain = "http://52.32.160.105:3000"
    
    var vc = ViewController()
    var FinalView = FinalViewController()
    
    var availableBus = [0,0,0,0]
    var notification = UILocalNotification()
    
    
    var defaults = NSUserDefaults.standardUserDefaults()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = UIColor.lightTextColor()//hexStringToUIColor("#5e6a71")
        UITabBar.appearance().tintColor = UIColor.blackColor()
  
        //remove if u want tab bar border to dissappear 
       // UITabBar.appearance().shadowImage = UIImage()
        //UITabBar.appearance().backgroundImage = UIImage()
        
        

       // NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        NSUserDefaults.standardUserDefaults().synchronize()
        
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
   
   
        //mainInstance.name.invalidate()
//        mainInstance.name = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: #selector(AppDelegate.DecreaseTime), userInfo: nil, repeats: true)
//        
        

        mainAlarmSets.AddAlarm(mainAlarm)
        //print("baha")
        //print(String(mainAlarmSets.alarmList[0].busRoute))
    
        

        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        
        connectToFcm()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
          inbg = 1
         //vc.TriggerBG()
        
        
        
        
        //save the user alarm
        
        //defaults.setObject(mainAlarmSets, forKey: "AlarmSets")
        

        mainInstance.isPaused = 0
      
        print("Disconnected from FCM.")
            //
        //FIRMessaging.messaging().disconnect()
        connectToFcm()
       // exit(0);
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

           connectToFcm()

        
        //vc.TriggerBG()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            inbg = 0
            connectToFcm()
       
    }

    func applicationWillTerminate(application: UIApplication) {
          connectToFcm()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        
        if let busid = defaults.objectForKey("DisplayRouteId")
        {
            BusID = busid as! [String]
        }

                    print(i)
               i += 1
        print(userInfo)

        
        var busStopName = defaults.valueForKey("busStopName")
        let UserSelectedBusRoute = defaults.valueForKey("UserSelectedBusRoute")
        let UserSelectedBusTime = defaults.valueForKey("UserSelectedBusTime")


        
        var routeID = ["99163E", "99163I","99163North","99163South" ]
       
        
        

        
        
        if ((userInfo["remain_time"] ) != nil)         {

            let routeId = userInfo["route_ID"] as! String
            let stopId = userInfo["busstop_ID"] as! String
            
            
            
            print("data not nillllll")
            let remaintime = userInfo["remain_time"] as! String
            
            let newstopId = stopId.stringByReplacingOccurrencesOfString("99163", withString: "")
            
            //check to see if the alarm notification is something we set
            if( mainAlarmSets.DoesContain(routeId, stopid: newstopId))
            {
                //connectToFcm()
                //do something here if the notification we receive matches the one we set
            
               let newlarm = Alarm(busroute: routeId, busstop: stopId, remaintime: remaintime, isenable: true)
                
                if(busReceive.count < 1)
                {
                busReceive.append(newlarm)
                }
                else
                {
                    for i in 0 ..< busReceive.count {
                     if(busReceive[i].busRoute == newlarm
                        .busRoute && busReceive[i].busStop == newlarm.busStop)
                     {
                        busReceive[i].remainTime = newlarm.remainTime
                        
                        
                        }
               
                    }
                
                }
//                mainAlarmSets.alarmList.append(newlarm)
                
                
                print("matched")
                
            }
            else{
            
                //if it doesnt match then we need to ubsubribe
                print(" no matched")
                //UnSubscribeAlarm(routeId, stop: stopId)
                
                
            }
            
            
            
            
            //only add to our alarm list if does not exist before
            if busAlarm.contains(routeId) {
                //do nothing
            }
            else
            {
                print("runnning")
                busAlarm.append(routeId)
                
                    //mainInstance.name.invalidate()
                     // mainInstance.name = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "DecreaseTime", userInfo: nil, repeats: true)
                    
                
            }
            
            defaults.setObject(remaintime, forKey: routeId)
            
//            if( Double(remaintime) <= UserSelectedBusTime?.doubleValue  && routeId == (UserSelectedBusRoute as! String))
//            {
////                mainInstance.isPaused = 1
////                print("setting alarm nowww")
////                
////                self.notification.fireDate = NSDate (timeIntervalSinceNow: 1)
////                self.notification.alertBody = routeId + " is at " + stopId
////                self.notification.timeZone = NSTimeZone.localTimeZone()
////                self.notification.soundName = UILocalNotificationDefaultSoundName
////                self.notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
////                
////                UIApplication.sharedApplication().scheduleLocalNotification(self.notification)
////                
////                self.defaults.removeObjectForKey("UserSelectedBusTime")
////                
////                self.defaults.removeObjectForKey(routeId)
////                UnSubscribeAlarm(routeId, stop: stopId)
////                
////             
//                
//                
//            }
            
        }
        
        
        
        

        print(userInfo["lat"])
        if let lat = userInfo["lat"]
        {
        
            
        
            if let long = userInfo["long"]
            {
                
                if let busPosId = userInfo["bposition"]
                {
                    if let userSelectedRoute = defaults.objectForKey("SelectedRoute")
                    {
                        print("lolololol")
                        
                        let bposition = String(busPosId)
                        let userRoute = userSelectedRoute as! String
                        
                        print(bposition)
                        print(userRoute)
                        
                        if (bposition == userRoute)
                        {
               defaults.setObject(lat, forKey: "busLat")
                defaults.setObject(long, forKey: "busLong")
                        }
                        
                    }
                }
                
            }
        }
        
        //new way to send all bus coordinates data
        if let busesPosition = userInfo["coordinatedata"]
        {
            print("llllllllllllllllllllllllllllllll")
            print(userInfo["coordinatedata"])
            
            defaults.setObject(busesPosition, forKey: "BusesPosition")
            defaults.synchronize()
            
            
        }
        
        
        
        
        
//        
//         if ((userInfo["notification"] ) != nil)         {
//         
//            print("notificationn")
//            print(userInfo["notification"]!["title"])
//            
//            let bTimeUpdate = userInfo["notification"]!["title"] as! String
//            
//            
//                //print(userInfo["notification"]!["title"])
//                //print(String(bTimeUpdate))
//            
//            
//            
//                if (bTimeUpdate == "BusstopTimeUpdate")
//                {
//                    print("inbg")
//                    print(inbg)
//                    if let msg = userInfo["busArray"]   {
//                        let newmsg = JSON(msg).rawString()
//                        
//                        var newjson = JSON.parse(newmsg!)
//                        
//                        let  stopId = newjson[0]["BusstopID"].stringValue
//                        print("oooooooooossssssnnnnnnnnaaaaaapppppp")
//                        print(newjson)
//                        
//                        
//                        
//                        
//                    
//                 
//
//                        UnSubNotification(stopId)
//                            
//                    
//                    
//                    }
//            }
//        }
//
//
//                    //need to make this funciton work
//                    //alg:
//                    //if the route we are receiving does not match the selected route, then unsub from it
////                        if let  currentroute = defaults.objectForKey("busStopName")
////                                        {
////                                            
////                                            
////                                            if let msg = userInfo["busArray"]   {
////                                                let newmsg = JSON(msg).rawString()
////                                                
////                                                var newjson = JSON.parse(newmsg!)
////                                                
////                                                let  stopId = newjson[0]["StopID"].stringValue
////                                                
////                                                
////                                            
////                                            
////                                            
////                                            
////                                            if(currentroute as! String != stopId)
////                                            {
////                                               
////                                                    UnSubNotification(stopId)
////                                                
////                                            
////                                            }
////                                            }
////                                        
////                                        }
//                
//                }
//
//            
//       
//            
//                if(bTimeUpdate == "CoordinatesUpdate")
//                {
//                    let lat = userInfo["lat"]
//                    let long = userInfo["long"]
//                    print("inside coordinateupdate")
//                    print(userInfo["notification"]!["lat"])
//                    print(userInfo["notification"]!["long"])
//                    defaults.setObject(lat, forKey: "busLat")
//                    defaults.setObject(long, forKey: "busLong")
//
//            }
//            
//        }
        

        if let msg = userInfo["busArray"]         {
            
            
            if let stopname = userInfo["busstop_ID"]
            {
                
                if let selectedstopName = defaults.valueForKey("busStopName")
                {
                print("stopnameeeeee")
                print(stopname)
                print(selectedstopName)
                print("stopnameeeeee")
                
           
                
                var receivedBusId = String(stopname)
                var selectedBusId = "99163" + (selectedstopName as! String)
                
                
                if(receivedBusId == selectedBusId)
                {
                    let newmsg = JSON(msg).rawString()
                    
                    var newjson = JSON.parse(newmsg!)
                    print(newjson[0]["StopID"])
                    
                    print("count: " + String(newjson.count))
                    //print(newmsg.rawString())
                    
                    for i in 0 ..< newjson.count {
                        
                        var routevalue = newjson[i]["RouteID"]
                        
                        var position = newjson[i]["Time"]
                        
                        for j in 0 ..< BusID.count
                        {
                        
                            if(String(routevalue) == BusID[j])
                            {
                            print("Saving routevalue : " + String(BusID[j]))
                            print("Saving routevalue : " + String(routevalue))
                            print("Saving time for routevalue above  : " + String(position))
                            self.defaults.setObject(position.stringValue, forKey: routevalue.stringValue)
                            self.defaults.synchronize()
                            }
                        
                        }
                        

                        
                        
                        
                    }
                
                }
                else
                {
                    //unsub here
                    
                    UnSubNotification(receivedBusId)
                
                }
                    
                }
                
            
            }
            
            

        }
        

        
        
       completionHandler(.NewData);
        

    
  }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .Prod)
        print("Device Token:", tokenString)
        defaults.setObject(tokenString, forKey: "apntoken")
        
       
       if let refreshedToken = FIRInstanceID.instanceID().token() {
        print("InstanceID token: \(refreshedToken)")
                self.defaults.setObject(refreshedToken, forKey: "token")
                //self.defaults.synchronize()
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
            //self.defaults.synchronize()
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
                FIRMessaging.messaging().disconnect()

            } else {

                print("Connected to FCM.")
                
            }
        }
    }
    

    

    
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
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print("the other receive notification")
    }
    
    
    func UnSubNotification(unsubStop : String)
    {
        if let mybustoken = defaults.valueForKey("token")
        {
        let unSubUrl = UrlDomain + "/Simulation/UnsubscribeBusstop/" + (unsubStop ) + "/" + (mybustoken as! String)
        let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        print("inside unsub conditionnnnnnnn")
        print("unsub: " + (unsubStop ))
            
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(myUnSubUrl!) {(data, response, error) in
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                // _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                
            }
            
            task.resume()
        }
    }
    
//    func UnSubscribeAlarm(route: String, stop: String){
//        
//        print("routestop")
//        print(route + stop)
//        
//        if let mybustoken = defaults.valueForKey("token")
//        {
//            let currenturl = "http://sudokit.com:3000/Simulation/UnsubscribeBusAlarm/" + route + "/" + stop + "/" + (mybustoken as! String)
//            
//            
//            
//            let myurl = NSURL(string: currenturl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
//            
//            print(myurl)
//            
//            Alamofire.request(.GET, myurl!)
//                .responseJSON { response in
//                    
//                    
//                    
//            }
//            
//            
//            
//        }
//
//    }
    
    func DecreaseTime()
    {
        //FIRMessaging.messaging().disconnect()
        //connectToFcm()
        //remove all alarms that has been disable from busReceive
        for k in 0 ..< busReceive.count
        {
            if(busReceive[k].enable == false)
            {
                indexToDelete.append(k)
            }
            
        }
        

        
        print("DecreaseTime_appdelegate")
        // print(mainInstance.isPaused)
        
        if(mainInstance.isPaused == 0)
        {
            
            for i in 0 ..< routeID.count {
                
                if((self.defaults.stringForKey(routeID[i])) != nil)
                {
                    let newvalue = Double(defaults.stringForKey(routeID[i])!)! - 0.5
                    
                    

                    
                    if(newvalue > 0)
                    {
                        defaults.setObject(newvalue, forKey: routeID[i])
                    }
                    
                    
                    
                    
                    
                    print("newvalue_appdelegate")
                    print(newvalue)
                }
                
            }
            

            
            //check to see if we have a match from our received data and the one from
            //our data of users settings
            for j in 0 ..< busReceive.count
            {
                
                for i in 0 ..< mainAlarmSets.alarmList.count {
                    print("busReceive[j].busRoute")
                    print(mainAlarmSets.alarmList[i].busRoute)
                    print(busReceive[j].busRoute)
                    
                    
                    print("busReceive[j].busStop")
                    print(("99163" + mainAlarmSets.alarmList[i].busStop))
                    print(busReceive[j].busStop)
                    
                    print("remain time")
                    
                    print(busReceive[j].remainTime)
                    print(mainAlarmSets.alarmList[i].remainTime)
                    
//                    if(mainAlarmSets.alarmList[i].busRoute == busReceive[j].busRoute && ("99163" + mainAlarmSets.alarmList[i].busStop) == busReceive[j].busStop && Double(busReceive[j].remainTime) < Double(mainAlarmSets.alarmList[i].remainTime)  && busReceive[j].enable == true && mainAlarmSets.alarmList[i].enable == true)
//                    {
//                        //if route match
//                        //stop match
//                        //and time is lesser then run the alarm
//                        busReceive[j].enable = false
//                        mainAlarmSets.alarmList[i].enable = false
//                        print("alarmmmm on")
//                        self.notification.fireDate = NSDate (timeIntervalSinceNow: 1)
//                                        self.notification.alertBody = mainAlarmSets.alarmList[i].busRoute + " is at " + mainAlarmSets.alarmList[i].busStop
//                                        self.notification.timeZone = NSTimeZone.localTimeZone()
//                                        self.notification.soundName = UILocalNotificationDefaultSoundName
//                                        self.notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
//                        
//                                        UIApplication.sharedApplication().scheduleLocalNotification(self.notification)
//                        
//                                        self.defaults.removeObjectForKey("UserSelectedBusTime")
//                                        
//                                        self.defaults.removeObjectForKey(mainAlarmSets.alarmList[i].busRoute)
//                        
//                                        UnSubscribeAlarm(mainAlarmSets.alarmList[i].busRoute, stop: mainAlarmSets.alarmList[i].busStop)
//                        
//                        
//                        
//                    }
                }
                
                if((Double(busReceive[j].remainTime)! - 0.5) > 0.0)
                {
                busReceive[j].remainTime = String(Double(busReceive[j].remainTime)! - 0.5)
                }
                

                
            }
        }
        
        
    }
    

}

