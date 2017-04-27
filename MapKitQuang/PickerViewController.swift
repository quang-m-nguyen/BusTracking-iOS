//
//  PickerViewController.swift
//  MapKitQuang
//
//  Created by Quang Nguyen on 6/1/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Alamofire
import SwiftyJSON
import Toast_Swift

class PickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl : UIRefreshControl!

     var defaults = NSUserDefaults.standardUserDefaults()
    
    var VrouteArr = [String]()
    var VrouteInfo = [String]()
    var VrouteID = [String]()
    var RouteName = [String]()
//    var cellColor = ["#B26CAD", "#FFE787", "#FF2DF0", "#63B2AA"]
    //var cellColor = ["#EC7A08", "#B6BF00", "#3CB6CE", "#DBCEAC"]
    var cellColor = [String]()
    var OpHours = [String]()
    var suffix = " Route"
    //var UrlDomain = "http://sudokit.com:3000"
      var UrlDomain = "http://52.32.160.105:3000"

//    var VrouteArr = ["Route E", "Route I", "Route North", "Route South"]
//    var VrouteInfo = ["M.T.W.TH.F\n6:30AM - 6:30PM", "M.T.W.TH.F\n6:30AM - 6:30PM", "M.T.W.TH.F\n6:30AM - 6:30PM", "M.T.W.TH.F\n6:30AM - 6:30PM"]
//    var VrouteID = ["01","02","03","04"]
//    //    var cellColor = ["#B26CAD", "#FFE787", "#FF2DF0", "#63B2AA"]
//    var cellColor = ["#9E83E3", "#169CFF", "#70E588", "#F85E35", "FFFF63","#9E83E3", "#169CFF"]
//    var routeID = ["99163E", "99163I", "99163North", "99163South"]
//    
//    
    
    
    
    
    var userSelection = "Route E"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let moc = DataController().managedObjectContext
       // let entity = NSEntityDescription.entityForName("Alarms", inManagedObjectContext: moc) as! Alarms
        
        tableView.dataSource = self
        tableView.delegate = self
        
          print("heyyyyyyyyyyyyy")
        
        
        
        
        
        
//        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components([.Day , .Month , .Year, .Weekday], fromDate: date)
//        
//        
//        let day = components.weekday
//        //need to change back to 7
//        if(Int(day) == -1)
//        {
//             VrouteArr = ["Route SatNorth", "Route SatSouth"]
//             VrouteInfo = ["M.T.W.TH.F\n6:30AM - 6:30PM", "M.T.W.TH.F\n6:30AM - 6:30PM"]
//             VrouteID = ["05","06"]
//             cellColor = ["#9E83E3", "#169CFF"]
//            
//            
//        }
    

        
    self.tableView.contentInset = UIEdgeInsetsMake(10.0, -2.0, 10.0, -10.0)
        
        //self.layoutMargins = UIEdgeInsetsZero //or UIEdgeInsetsMake(top, left, bottom, right)
        //self.separatorInset = UIEdgeInsetsZero //if you also want to adjust separatorInset
  //tableView.contentInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)

        // Do any additional setup after loading the view.
        

        
        
        
        
    
            let currenturl = UrlDomain + "/GetInfo/99163"
            
            
            
            let myurl = NSURL(string: currenturl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            
            print(myurl)
        
        
        
            
            Alamofire.request(.GET, myurl!)
                .responseJSON { response in
                    
                    
                    if(response.result.isSuccess == false)
                    {
                        self.view.makeToast("Thrifa is unable to connect to the internet.  Please close app and try again in few mins.", duration: 60.0, position: .Bottom)
                        return
                        
                    }
                    var result = JSON(response.result.value!)
                    
                    
                    if(result != nil)
                    {
                        for i in 0 ..< result.count
                        {
                            var totalinfo = String(result[i]["OpDays"]) + "\n" + String(result[i]["OpHours"])
                            self.VrouteID.append(String(result[i]["BusNum"]))
                            self.VrouteArr.append(String(result[i]["RouteId"]))
                            self.VrouteInfo.append(totalinfo)
                            self.OpHours.append(String(result[i]["OpHours"]))
                            self.cellColor.append(String(result[i]["Color"]))
                            self.RouteName.append(String(result[i]["RouteName"]))
                            
                            
  
                        }
                        self.defaults.setObject(self.RouteName, forKey: "DisplayRouteName")
                        self.defaults.setObject(self.VrouteID, forKey: "DisplayBusNum")
                        self.defaults.setObject(self.VrouteArr, forKey: "DisplayRouteId")
                        self.defaults.setObject(self.VrouteInfo, forKey: "DisplayOpInfo")
                        self.defaults.setObject(self.cellColor, forKey: "DisplayColor")
                        print("yooo")
                        print(result[0]["OpDays"])
                     dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                    }
                    
            
        }
        

 
            
            
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //passing data
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let mainVc = segue.destinationViewController as! ViewController
        
        print("user selection from segueue" + userSelection)
        mainVc.rcvString = userSelection
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.VrouteID.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = self.tableView.dequeueReusableCellWithIdentifier("customcell", forIndexPath: indexPath) as! CustomCell
        
        cell.routeID.text = self.VrouteID[indexPath.row]
//        var str = VrouteArr[indexPath.row]
//        //remove zipcode digits from text
//        var stringWithoutDigit = (str.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString("")
        cell.routeDes.text = self.RouteName[indexPath.row]
        cell.routeInfo.text = self.VrouteInfo[indexPath.row]
        cell.backgroundColor = self.hexStringToUIColor(self.cellColor[indexPath.row])
//        let separator = UIView(frame: CGRectMake(0, 0, cell.bounds.size.width, 10))
//        separator.backgroundColor = UIColor.whiteColor()
//        cell.contentView.addSubview(separator)

        cell.contentView.backgroundColor = UIColor.clearColor()
        
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 8))
        
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 0.0
        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
        
        
        
        
        cell.contentView.layer.cornerRadius = 2.0;
        cell.contentView.layer.borderWidth = 1.0;
        cell.contentView.layer.borderColor = UIColor.clearColor().CGColor;
        cell.contentView.layer.masksToBounds = true;
        
        cell.layer.shadowColor = UIColor.grayColor().CGColor;
        cell.layer.shadowOffset = CGSizeMake(0, 2.0);
        cell.layer.shadowRadius = 2.0;
        cell.layer.shadowOpacity = 1.0;
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).CGPath;
        
        
        
        return cell
        
        
    }
    
//    // In this case I returning 140.0. You can change this value depending of your cell
//     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 140.0
//    }
//    
//     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        cell.contentView.backgroundColor = UIColor.clearColor()
//        
//        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.view.frame.size.width, 120))
//        
//        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
//        whiteRoundedView.layer.masksToBounds = false
//        whiteRoundedView.layer.cornerRadius = 2.0
//        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
//        whiteRoundedView.layer.shadowOpacity = 0.2
//        
//        cell.contentView.addSubview(whiteRoundedView)
//        cell.contentView.sendSubviewToBack(whiteRoundedView)
//    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.5
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clearColor()
        return header
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6.6
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You tapped cell number \(VrouteArr[indexPath.row]).")
        //set the same so we know which route to display on the map
        userSelection = VrouteArr[indexPath.row]
        print(userSelection)
        
        
        let selectedRoute = VrouteArr[indexPath.row]
        defaults.setObject(selectedRoute, forKey: "SelectedRoute")
        defaults.synchronize()
        
        
        
        
        
        //perform segue to another map here 
        performSegueWithIdentifier("tomapview", sender: self)
        
        
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

    


}
