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

class FinalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var timePicker: UISlider!
   

    @IBOutlet var timeFromTimePicker: UITextField!
    // Data model: These strings will be the data for the table view cells
    let BusStop: [String] = ["Bus E", "Bus I", "Bus Sat. N.", "Bus Sat. South"]
    var BusTime: [Double] = [0.0, 0.0, 0.0, 0.0]
    var BusToDisplay: [String] = []
      var cellColor = ["#B26CAD", "#FFE787", "#FF2DF0", "#63B2AA"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
     @IBOutlet weak var tableView: UITableView!


             let defaults = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeFromTimePicker.text = "15"
        

        // Register the table view cell class and its reuse id
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self

        print("inside final view")
        
        
        //here WE WILL GET ALL THE ROUTES THAT PASSES THROUGH THE BUS STOP WE SELECTED 
        //AND HOW TO PARSE IT
        //SavedStringArray
        var array = JSON.parse(defaults.valueForKey("SavedStringArray") as! String)
        
        
        var busStopName = defaults.valueForKey("busStopName")

        
           if let mybustoken = FIRInstanceID.instanceID().token() {
            

        
        print("busStopName is : " + String(busStopName))
        
        if let gotbusStopName = busStopName
        {
           
            
                var currenturl = "http://sudokit.com:3000/Simulation/SubscribeBusstop/99163" + (gotbusStopName as! String) + "/" + mybustoken
                

                let myurl = NSURL(string: currenturl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            
            
            //check if unsubscribe bus is set, then unsubribe it
            //if not then do normal procedure and subscribe to it 
            if(defaults.valueForKey("UnSubBusStopName") != nil)
            {
                if let unsubStop = defaults.valueForKey("UnSubBusStopName")
                {
                var unSubUrl = "http://sudokit.com:3000/Simulation/UnsubscribeBusstop/99163" + (unsubStop as! String) + "/" + mybustoken
                let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                print("inside unsub conditionnnnnnnn")
                print("unsub: " + (unsubStop as! String))
                Alamofire.request(.GET, myUnSubUrl!)
                    .responseJSON { response in
                        
                        
                        
                }
                }
            }
            
                print(String(myurl))
            
                //Save this key so that we can unsubribe later
                defaults.setObject(gotbusStopName, forKey: "UnSubBusStopName")
                Alamofire.request(.GET, myurl!)
                    .responseJSON { response in
                        
//                        let defaults = NSUserDefaults.standardUserDefaults()
//                        defaults.setObject(JSON(response.result.value!).rawString()!, forKey: "SavedStringArray")
                        
                                       if let JSON1 = response.result.value {
                                        let total = JSON(JSON1).count
                                        for i in 0 ..< total {
                                            self.BusToDisplay.append(JSON(JSON1)[i]["RouteID"].stringValue)
                                        }
                                      }
                        
                        
                }
                
            
        
        
        

        
        
        
        var mylat = array[0]["lat"].stringValue
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
    // create a cell for each table view row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        dispatch_async(dispatch_get_main_queue(), {
        cell.textLabel?.text = self.BusToDisplay[indexPath.row]
         cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        cell.textLabel?.textColor = UIColor.whiteColor()
           
        if(String(self.BusTime[indexPath.row]) == "0.0")
        {
            cell.detailTextLabel?.text = "calculating..."
            }
            
            else
        {
            cell.detailTextLabel?.text = String(self.BusTime[indexPath.row]) + " mins"
            }
        cell.detailTextLabel!.font = UIFont.boldSystemFontOfSize(12.0)
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
            
        if(self.BusToDisplay[indexPath.row] == "99163E")
        {
            cell.backgroundColor = self.hexStringToUIColor(self.cellColor[0])
            }
            else if (self.BusToDisplay[indexPath.row] == "99163I")
        {
            cell.backgroundColor = self.hexStringToUIColor(self.cellColor[1])
            }
        else if (self.BusToDisplay[indexPath.row] == "99163North")
        {
            cell.backgroundColor = self.hexStringToUIColor(self.cellColor[2])
            }
        else if (self.BusToDisplay[indexPath.row] == "99163South")
        {
                cell.backgroundColor = self.hexStringToUIColor(self.cellColor[3])
            }
            
        
        
        cell.layer.shadowOpacity = 1.0;
        cell.layer.shadowRadius = 1.7;
        cell.layer.shadowColor = UIColor.blackColor().CGColor;
        cell.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        
        var label = UILabel(frame: CGRectMake(15.0, 22.00, 150.0, 30.0))
      
        label.font = UIFont(name:"Avenir", size:13)
        label.text = "tap to set alarm"
        label.tag = indexPath.row
        label.textColor = UIColor.blueColor()
        cell.contentView.addSubview(label)
         })
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
        
        var currentCell = tableView.cellForRowAtIndexPath(indexPath)
        print("text label:")
       // print(currentCell?.textLabel.text)
        
        defaults.setObject(currentCell?.textLabel!.text, forKey: "UserSelectedBusRoute")
        defaults.setObject(timeFromTimePicker.text, forKey: "UserSelectedBusTime")
        
        
        // create the alert
        let alert = UIAlertController(title: "Setting Notification", message: "Your notification has been set for " + timeFromTimePicker.text! + " mins", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    

    
    func observeUserDefaults() {
        var routeID = ["99163E", "99163I","99163North","99163South" ]
        //NSLog("observeUserDefaults() called")
        
        //print(latestposition)
    
            // code here
     
        for var i = 0; i < routeID.count; i += 1 {
            
            if((self.defaults.stringForKey(routeID[i])) != nil)
            {
                //set which bus to make the cell for
                //BusToDisplay.append(routeID[i])
                let latestposition = self.defaults.stringForKey(routeID[i])
                if let theTime = latestposition
                {
                    self.BusTime[i] = Double(theTime)!
                      dispatch_async(dispatch_get_main_queue()) {

                    self.tableView.reloadData()
                    }

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
