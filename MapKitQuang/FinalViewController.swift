//
//  FinalViewController.swift
//  MapKitQuang
//
//  Created by Quang Nguyen on 6/8/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Firebase
import FirebaseMessaging
import Toast_Swift
import Gifu

class FinalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UITextFieldDelegate {
    
    
    @IBOutlet var timePicker: UISlider!
   

    @IBOutlet var timeFromTimePicker: UITextField!
    // Data model: These strings will be the data for the table view cells
    let BusStop: [String] = ["Bus E", "Bus I", "Bus Sat. N.", "Bus Sat. South"]
    var BusTime = [Double]()
    var previousalarmed = ""
    var BusToDisplay: [String] = []
    var DisplayBus = [String]()
     //var cellColor = ["#EC7A08", "#B6BF00", "#3CB6CE", "#DBCEAC"]
    var cellColor = [String]()
    var refreshControl : UIRefreshControl!
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var myNewDictArray: [Dictionary<String, String>] = []
    
   // var UrlDomain = "http://sudokit.com:3000"
      var UrlDomain = "http://52.32.160.105:3000"
  //  var routeID = ["99163E", "99163I","99163North","99163South" ]
    
    var BusID = [String]()
    //var updateTimer = NSTimer()
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
     @IBOutlet weak var tableView: UITableView!


             let defaults = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeFromTimePicker.delegate = self;
        
        if let cColor = defaults.objectForKey("DisplayColor")
        {
            cellColor = cColor as! [String]
        }
        
        
        if let busid = defaults.objectForKey("DisplayRouteId")
        {
            BusID = busid as! [String]
        }
        
        
        for i in 0 ..< BusID.count{
        BusTime.append(0.0)
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    
//         mainInstance.name = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "DecreaseTime", userInfo: nil, repeats: true)
        

        
        timeFromTimePicker.text = "15"
        
        
        
        
        //calcualte walking distance
        
        if let srctime = defaults.objectForKey("srckey")
        {
            if let desttime = defaults.objectForKey("destkey")
            {
                
                let unSubUrl = UrlDomain + "/GetWalkingTime/" + (srctime as! String) + "/" + (desttime as! String)
                let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)

                print("GetWalkingTime url : " + (unSubUrl ))
                Alamofire.request(.GET, myUnSubUrl!)
                    .validate()
                    .responseString { response in
                        
                        if(response.result.isSuccess == false)
                        {
                            print("Get Walking Time fail....")
                            return
                            
                        }
                        
                        print("Success: \(response.result.isSuccess)")
                        print("Response String: \(response.result.value)")
                        dispatch_async(dispatch_get_main_queue()) {
                        self.timeFromTimePicker.text = response.result.value
                        }
                        
                }
            
            }
        }
        

        // Register the table view cell class and its reuse id
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self

        print("inside final view under viewdidload")
        
        
        //here WE WILL GET ALL THE ROUTES THAT PASSES THROUGH THE BUS STOP WE SELECTED 
        //AND HOW TO PARSE IT
        //SavedStringArray
        var array = JSON.parse(defaults.valueForKey("SavedStringArray") as! String)
        
        
        let busStopName = defaults.valueForKey("busStopName")

        
           if let mybustoken = FIRInstanceID.instanceID().token() {
            

        
        print("busStopName is : " + String(busStopName))
        
        if let gotbusStopName = busStopName
        {
           

            //check if unsubscribe bus is set, then unsubribe it
            //if not then do normal procedure and subscribe to it 
            if(defaults.valueForKey("UnSubBusStopName") != nil)
            {
                if let unsubStop = defaults.valueForKey("UnSubBusStopName")
                {
                let unSubUrl = UrlDomain + "/Simulation/UnsubscribeBusstop/99163" + (unsubStop as! String) + "/" + mybustoken
                let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                print("inside unsub conditionnnnnnnn1")
                print("unsub: " + (unsubStop as! String))
                Alamofire.request(.POST, myUnSubUrl!)
                    .responseJSON { response in
                        
                        if(response.result.isSuccess == false)
                        {
                            print("UnsubscribeBusstop fail....")
                            return
                            
                        }
                        
                        
                        // mainInstance.name.invalidate()
                        
                }
                   
                    
//                    var task = NSURLSession.sharedSession().dataTaskWithURL(myUnSubUrl!) {(data, response, error) in
//                       // var data = (NSString(data: data!, encoding: NSUTF8StringEncoding))
//                        
//                        print(response)
//                        
//                    }
//                        task.resume()
                    
                }
            }
            
            self.Subscribe()
            
            
            

            
                //Save this key so that we can unsubribe later
                defaults.setObject(gotbusStopName, forKey: "UnSubBusStopName")
                defaults.synchronize()
            

            
        
        
        let mylat = array[0]["lat"].stringValue
        print("array : ")
        print(String(mylat))
        }
       
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FinalViewController.observeUserDefaults), name:
            NSUserDefaultsDidChangeNotification, object: nil)

        //remainTime.text = strHolder

        // Do any additional setup after loading the view.
    }
    
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.BusToDisplay.count
    }
    
    func Subscribe(){
        self.refreshControl.beginRefreshing()
      
        
        if let mybustoken = defaults.valueForKey("token")
        {
        if let busStopName = defaults.valueForKey("busStopName")
        {
        let currenturl = UrlDomain + "/Simulation/SubscribeBusstop/99163" + (busStopName as! String) + "/" + (mybustoken as! String)
            print("nooooooooooooo")
            print(currenturl)
        
        
        let myurl = NSURL(string: currenturl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            
            
                   let task = NSURLSession.sharedSession().dataTaskWithURL(myurl!) {(data, response, error) in
                        let data = (NSString(data: data!, encoding: NSUTF8StringEncoding))
                        // _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("the datttaa")
                        //print(JSON(data!)[0])
                    if let  newmsg = JSON(data!).rawString()
                    {
                    var newjson = JSON.parse(newmsg)
                    
                    print(newjson)
                       
                                            for i in 0 ..< newjson.count {
                                               
                                                
                                                let str = newjson[i]["RouteID"].stringValue
                                                 let str1 = newjson[i]["Time"].doubleValue
                                                
                                                for j in 0 ..< self.BusID.count {
                                                    
                                                    if(str == self.BusID[j])
                                                    {
                                                        
                                                        self.BusToDisplay.append(newjson[i]["RouteID"].stringValue)
                                                        
                                                        self.BusTime[j] = str1
                                                        
                                                        
                                                        var item = (str.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString("")
                                                        item = item + " Route"
                                                        
                                                        self.DisplayBus.append(item)
                                                        
                                                    }
      
                                                }
                                             
                                                
                                                
                                           }
                        
                        self.refresh("a")
                       // self.refreshControl.endRefreshing()
                        
                        
            
            
                    }
                    }
            
            
                    task.resume()
            
            

        }
        }
        
        //mainInstance.isPaused = 0
        
    
    }
    
    // create a cell for each table view row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        dispatch_async(dispatch_get_main_queue(), {
        cell.textLabel?.text = self.DisplayBus[indexPath.row]
         cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell.textLabel?.textColor = UIColor.whiteColor()
           
//        if(String(self.BusTime[indexPath.row]) == "0.0")
//        {
//            cell.detailTextLabel?.text = "calculating..."
//            }
//            
//            else
//        {
//            print("attempting to update")
//            print("updating : " + String(self.BusTime[indexPath.row]))
//            print("bustime array: " + String(self.BusTime))
            
            
            
//            if(self.BusToDisplay[indexPath.row] == "99163E")
//            {
//                cell.detailTextLabel?.text = String(Int(self.BusTime[0])) + " mins"
//            }
//            else if(self.BusToDisplay[indexPath.row] == "99163I")
//            {
//                cell.detailTextLabel?.text = String(Int(self.BusTime[1])) + " mins"
//            }
//            else if(self.BusToDisplay[indexPath.row] == "99163South")
//            {
//                cell.detailTextLabel?.text = String(Int(self.BusTime[2])) + " mins"
//            }
//            else if(self.BusToDisplay[indexPath.row] == "99163North")
//            {
//                cell.detailTextLabel?.text = String(Int(self.BusTime[3])) + " mins"
//            }
//            else if(self.BusToDisplay[indexPath.row] == "99163SatNorth")
//            {
//                cell.detailTextLabel?.text = String(Int(self.BusTime[0])) + " mins"
//            }
//            else if(self.BusToDisplay[indexPath.row] == "99163SatSouth")
//            {
//                cell.detailTextLabel?.text = String(Int(self.BusTime[1])) + " mins"
//            }
            
            // let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
            
           // let calendar = NSCalendar.currentCalendar()
            //let date = calendar.dateByAddingUnit(.Minute, value: 5, toDate: calendar, options: [])
            //calendar.dateByAddingUnit(.Min, value: <#T##Int#>, toDate: <#T##NSDate#>, options: <#T##NSCalendarOptions#>)
            

            //print("yeyeyeyeyeyyeyeye")
            //print(timeStamp)
            
            for i in 0 ..< self.BusID.count {
                if(self.BusToDisplay[indexPath.row] == self.BusID[i])
                {
                    let date = NSDate().dateByAddingTimeInterval(Double(self.BusTime[i]) * 60.0)
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "h:mma"
                    dateFormatter.timeZone = NSTimeZone.localTimeZone()
                    let timeStamp = dateFormatter.stringFromDate(date)
                    
                    cell.backgroundColor = self.hexStringToUIColor(self.cellColor[i])
                    cell.detailTextLabel?.text = String(Int(self.BusTime[i])) + " mins (" + String(timeStamp) + ")"

                }
            }
            
            cell.detailTextLabel!.font = UIFont.boldSystemFontOfSize(12.0)
            cell.detailTextLabel?.textColor = UIColor.whiteColor()
//
//        if(self.BusToDisplay[indexPath.row] == "99163E")
//        {
//            cell.backgroundColor = self.hexStringToUIColor(self.cellColor[0])
//            }
//            else if (self.BusToDisplay[indexPath.row] == "99163I")
//        {
//            cell.backgroundColor = self.hexStringToUIColor(self.cellColor[1])
//            }
//        else if (self.BusToDisplay[indexPath.row] == "99163North")
//        {
//            cell.backgroundColor = self.hexStringToUIColor(self.cellColor[2])
//            }
//        else if (self.BusToDisplay[indexPath.row] == "99163South")
//        {
//                cell.backgroundColor = self.hexStringToUIColor(self.cellColor[3])
//            }
//        else if (self.BusToDisplay[indexPath.row] == "99163SatSouth")
//        {
//            cell.backgroundColor = self.hexStringToUIColor(self.cellColor[1])
//            }
//        else if (self.BusToDisplay[indexPath.row] == "99163SatNorth")
//        {
//            cell.backgroundColor = self.hexStringToUIColor(self.cellColor[0])
//            }
            
        
        
//            let imageView = AnimatableImageView(frame: CGRect(x: 15.0, y: 22.00, width: 30.0, height: 30.0))
//            imageView.animateWithImage(named: "mugen.gif")
            
            //cell.imageView?.image = imageView
            //cell.imageView?.animationImages
            
           // http://stackoverflow.com/questions/24364504/swift-how-to-animate-images
            
        cell.layer.shadowOpacity = 1.0;
        cell.layer.shadowRadius = 3.7;
        cell.layer.shadowColor = UIColor.darkGrayColor().CGColor;
        cell.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        
            
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
            
            
        let label = UILabel(frame: CGRectMake(17.0, 22.00, 150.0, 30.0))
      
        label.font = UIFont(name:"Avenir-Roman", size:12)
        label.text = "tap to set alert"
        label.tag = indexPath.row
        label.textColor = UIColor.blueColor()
        cell.contentView.addSubview(label)
            
            let screenWidth = self.screenSize.width
           // let screenHeight = screenSize.height
            let tlabel = UILabel(frame: CGRectMake(screenWidth * 0.6, 22.00, 150.0, 30.0))
            
            tlabel.font = UIFont(name:"AvenirNext-Italic", size:10)
            tlabel.text = "last updated : " + timestamp
            
            tlabel.tag = indexPath.row
            tlabel.textColor = UIColor.darkGrayColor()
            cell.contentView.addSubview(tlabel)
            
         })
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //tabBarController?.selectedIndex = 0

        
        defaults.setInteger(0, forKey: "tracker")
        print("You tapped cell number \(indexPath.row).")
        
//        let urltoken = defaults.stringForKey("urltoken")
//        
//        let url = NSURL(string: urltoken!)
//        
//
//        print("manual token url" + String(urltoken))
//        
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
//            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
//            // _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            
//            
//        }
//        
//        task.resume()
        

//        self.view.makeToast("This is a piece of toast", duration: 2.0, position: CGPoint(x: 110.0, y: 410.0), title: "Toast Title", image: UIImage(named: "thrifa.png"), style:nil) { (didTap: Bool) -> Void in
//            if didTap {
//                print("completion from tap")
//            } else {
//                print("completion without tap")
//            }
//        }
        
        // present the toast with the new style
       // self.view.makeToast("Your alert has been set!", duration: 3.0, position: .Bottom, style: style)
        //ToastManager.shared.tapToDismissEnabled = true

        
        //let appDelegate = UIApplication.sharedApplication().delegate as! ViewController//Your app delegate class name.
        
        //appDelegate.SendToast()
      
        
        if let mybustoken = defaults.valueForKey("token")
        {
        if(defaults.valueForKey("UnSubBusStopName") != nil)
        {
            if let unsubStop = defaults.valueForKey("UnSubBusStopName")
            {
                let unSubUrl = UrlDomain + "/Simulation/UnsubscribeBusstop/99163" + (unsubStop as! String) + "/" + (mybustoken as! String)
                let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                print("inside unsub conditionnnnnnnn2")
                print("unsub: " + (unsubStop as! String))
                Alamofire.request(.POST, myUnSubUrl!)
                    .responseJSON { response in
                        
                        if(response.result.isSuccess == false)
                        {
                            print("UnsubscribeBusstop fail....")
                            return
                            
                        }
                        
                        
                    
                        
                }
               // mainInstance.name.invalidate()

                
            }
        }
        }
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)
        print("text label:")
       // print(currentCell?.textLabel.text)
        
        
        
        
        
        
        print("rowwwwwwwwwww")
        print(BusID[indexPath.row])
        print(indexPath.row)
        defaults.setObject(BusToDisplay[indexPath.row], forKey: "UserSelectedBusRoute")
        defaults.setObject(timeFromTimePicker.text, forKey: "UserSelectedBusTime")
        defaults.synchronize()
        
        
         let busStopName1 = defaults.valueForKey("busStopName") as! String
        
        
//        print("previousalarmed")
//
//        print(previousalarmed)
//         print(busStopName1)
//        if(previousalarmed == busStopName1)
//        {
//            let alert = UIAlertController(title: "Notification", message: "Unsubribe alarm" + timeFromTimePicker.text! + " mins", preferredStyle: UIAlertControllerStyle.Alert)
//            
//            
//            // add an action (button)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
//            
//            // show the alert
//            self.presentViewController(alert, animated: true, completion: nil)
//            
//        }
//        else
//        {
       
            var okAction = UIAlertAction(title: "Set", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                NSLog("OK Pressed")
                //subcribe for notification alarm here
                
                if let busStopName = self.defaults.valueForKey("busStopName")
                {
                    if let mybustoken = self.defaults.valueForKey("apntoken")
                    {
                        if let busroute = self.defaults.valueForKey("UserSelectedBusRoute")
                        {
                            //add to alarm lists
                            let newlarm = Alarm(busroute: busroute as! String, busstop: busStopName as! String, remaintime: String(self.timeFromTimePicker.text!) , isenable: true)
                            
                            mainAlarmSets.alarmList.append(newlarm)

                            
                            
                                let validDictionary = [
                                    "BusRoute": busroute as! String,
                                    "BusStop": busStopName as! String,
                                    "RemainTime": String(self.timeFromTimePicker.text!)
                                ]
                                
                                self.defaults.setObject(validDictionary, forKey: "alarmkey")
                                
                            
                            
                            var unSubUrl = self.UrlDomain + "/Simulation/SubscribeBusAlarmIOS/" + (busroute as! String) + "/99163" + (busStopName as! String) + "/" + (mybustoken as! String)
                            
                            unSubUrl =  unSubUrl + "/" + self.timeFromTimePicker.text!
                            
                            
                            print("alarm sub URL: " + String(unSubUrl))
                            
                            
                            //set this here so that if user select the same stop again, they can unsubribe
                            //defaults.setObject(busStopName, forKey: "previousalarmed")
                            self.previousalarmed = busStopName as! String
                            let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                            print("inside unsub conditionnnnnnnn0")
                            print("unsub: " + (busroute as! String))
                            Alamofire.request(.GET, myUnSubUrl!)
                            
                            
                        }
                    }
                }
                self.dismissViewControllerAnimated(true, completion: {});
                

                
            }
            var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
                //self.dismissViewControllerAnimated(true, completion: {});
            }

            
            //        // create the alert
            let alert = UIAlertController(title: "Alert Confirmation", message: "Thrifa will send you an alert when the bus is  " + timeFromTimePicker.text! + " mins away from your bus stop", preferredStyle: UIAlertControllerStyle.Alert)
            
            
            // add an action (button)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
        
        
        
        
        

        
        

    }
    
    
    func refresh(sender:AnyObject)
    {
        
        
        dispatch_async(dispatch_get_main_queue()) {
            
         
            self.tableView.reloadData()
            //self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            
            self.refreshControl.endRefreshing()
        }
    }
    
    func observeUserDefaults() {
        //var routeID = ["99163E", "99163I","99163North","99163South" ]
        //NSLog("observeUserDefaults() called")
        
        //print(latestposition)
    
            // code here
     
        for i in 0 ..< BusID.count {
            
            if((self.defaults.stringForKey(BusID[i])) != nil)
            {
                //set which bus to make the cell for
                //BusToDisplay.append(routeID[i])
                let latestposition = self.defaults.stringForKey(BusID[i])
                
                if let theTime = latestposition
                {
                   // print("retreiving : " + routeID[i])
                   // print("value retreived : " + String(theTime))
                    self.BusTime[i] = Double(theTime)!
                    //self.BusTime.append(Double(theTime)!)
//                    if(routeID[i] == "99163South")
//                    {
//                        self.BusTime[2] = Double(theTime)!
//                    }
                      //dispatch_async(dispatch_get_main_queue()) {
                        //self.tableView.hidden = true
                    //self.tableView.reloadData()
                        //print("self.BusToDisplay.count" + String(self.BusToDisplay.count))
//                        for j in 0 ..< self.BusToDisplay.count
//                        {
//                    dispatch_async(dispatch_get_main_queue()) {
//                      self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
//                    }
                       // }
                        
                        
                   // }

                    //print("bus to display")
                    //print(self.BusToDisplay)
                }
                
                
            }
            
        }
            
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SetNotification(sender: UIButton) {
        
                let urltoken = defaults.stringForKey("urltoken")
        
        print("manual token url" + String(urltoken))
        
        let url = NSURL(string: urltoken!)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            // _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            
        }
        
        task.resume()
        
        
        // create the alert
        let alert = UIAlertController(title: "Setting Notification", message: "Set alert for ", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func timePickerAction(sender: UISlider) {
        
        timeFromTimePicker.text = String(Int(sender.value))
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func addAlert(){
        
        // create the alert
        let title = "This is the title"
        let message = "This is the message"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alert.modalInPopover = true;
        
        // add an action button
        let nextAction: UIAlertAction = UIAlertAction(title: "Action", style: .Default){action->Void in
            // do something
        }
        alert.addAction(nextAction)
        
        // now create our custom view - we are using a container view which can contain other views
        let containerViewWidth = 250
        let containerViewHeight = 120
        let containerFrame = CGRectMake(10, 70, CGFloat(containerViewWidth), CGFloat(containerViewHeight));
        let containerView: UIView = UIView(frame: containerFrame);
        
        alert.view.addSubview(containerView)
        
        // now add some constraints to make sure that the alert resizes itself
        let cons:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: containerView, attribute: NSLayoutAttribute.Height, multiplier: 1.00, constant: 130)
        
        alert.view.addConstraint(cons)
        
        let cons2:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: containerView, attribute: NSLayoutAttribute.Width, multiplier: 1.00, constant: 20)
        
        alert.view.addConstraint(cons2)
        
        // present with our view controller
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func DecreaseTime()
    {
        print("DecreaseTime")
       // print(mainInstance.isPaused)
        
        if(mainInstance.isPaused == 0)
        {
        
        for i in 0 ..< BusID.count {
            
            if((self.defaults.stringForKey(BusID[i])) != nil)
            {
                 let newvalue = Double(defaults.stringForKey(BusID[i])!)! - 0.1
                
                if(newvalue > 0)
                {
                defaults.setObject(newvalue, forKey: BusID[i])
                    
//                    for i in 0 ..< mainAlarmSets.alarmList.count {
//                        
//                        if(mainAlarmSets.alarmList[i].busRoute == routeID[i] && mainAlarmSets.alarmList[i].busStop == stopid && mainAlarmSets.alarmList[i].enable)
//                        {
//                            return true
//                        }
//                    }

                }
                print("newvalue")
                print(newvalue)
           }
            
        }
        }
        
        
    }
    


}
