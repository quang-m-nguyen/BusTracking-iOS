//
//  AlarmsTable.swift
//  Thrifa
//
//  Created by Quang Nguyen on 7/8/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class AlarmsTable: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var items: [String] = ["Route E", "Route I", "Route North"]
    var itemsdes: [String] = ["campus n that", "blahblah", "Route North"]
  // var UrlDomain = "http://sudokit.com:3000"
      var UrlDomain = "http://52.32.160.105:3000"
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet var alarmTableView: UITableView!
    var alarmList = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let myalarms = defaults.objectForKey("AlarmSets")
//        {
//            mainAlarmSets = myalarms as! AlarmSets
//        }
        
        
        self.alarmTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "alarmcell")
        alarmTableView.reloadData()
        
        if let myalarms = defaults.objectForKey("alarmkey")
        {
            print("alarmmm")
            print(myalarms)
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainAlarmSets.alarmList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.alarmTableView.dequeueReusableCellWithIdentifier("alarmcell")! as UITableViewCell
        
       
        //cell.textLabel?.text = mainAlarmSets.alarmList[indexPath.row].busRoute
        
     
        let routelabel = UILabel(frame: CGRectMake(60.0, 10.00, 150.0, 30.0))
        
        routelabel.font = UIFont(name:"Avenir", size:13)
        routelabel.text = mainAlarmSets.alarmList[indexPath.row].busRoute
        routelabel.tag = indexPath.row
        routelabel.textColor = UIColor.blueColor()
        cell.contentView.addSubview(routelabel)
        
        
        
        let stoplabel = UILabel(frame: CGRectMake((screenSize.width) * 0.45, 10.00, 150.0, 30.0))
        
        stoplabel.font = UIFont(name:"Avenir", size:13)
        stoplabel.text = mainAlarmSets.alarmList[indexPath.row].busStop
        stoplabel.tag = indexPath.row
        stoplabel.textColor = UIColor.blueColor()
        cell.contentView.addSubview(stoplabel)
        
        
        let timelabel = UILabel(frame: CGRectMake((screenSize.width) * 0.85, 10.00, 150.0, 30.0))
        
        timelabel.font = UIFont(name:"Avenir", size:13)
        timelabel.text = mainAlarmSets.alarmList[indexPath.row].remainTime
        timelabel.tag = indexPath.row
        timelabel.textColor = UIColor.blueColor()
        cell.contentView.addSubview(timelabel)
        
        //cell.accessoryView = UIImageView(image: UIImage(named: "TabSettingsIcon"))
        //cell.accessoryView!.frame = CGRectMake(305.0, 22.00, 150.0, 30.0)
        if(mainAlarmSets.alarmList[indexPath.row].enable)
        {
        cell.imageView?.image = UIImage(named: "ClockSet")
        }
        else{
        cell.imageView?.image = UIImage(named: "Clock")
        }
        
        if(indexPath.row == 0)
        {
            cell.imageView?.image = UIImage(named: "Refresh")
        }
        //cell.imageView?.frame = CGRectMake(305.0, 222.00, 150.0, 300.0)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        
        
        if(mainAlarmSets.alarmList[indexPath.row].enable)
        {
            cell?.imageView?.image = UIImage(named: "Clock")
            mainAlarmSets.alarmList[indexPath.row].enable = false
            UnSubscribeAlarm(mainAlarmSets.alarmList[indexPath.row].busRoute, stop: "99163" + mainAlarmSets.alarmList[indexPath.row].busStop)
        }
        else{
            cell?.imageView?.image = UIImage(named: "ClockSet")
            mainAlarmSets.alarmList[indexPath.row].enable = true
            SubscribeAlarm(mainAlarmSets.alarmList[indexPath.row].busRoute, stop: "99163" + mainAlarmSets.alarmList[indexPath.row].busStop, time: mainAlarmSets.alarmList[indexPath.row].remainTime)
        }
        
        //cellToDeSelect.imageView?.image = UIImage(named: "Clock")
        
        alarmTableView.reloadData()
    }
    
    func UnSubscribeAlarm(route: String, stop: String){
        
        print("routestop")
        print(route + stop)
        
        if let mybustoken = defaults.valueForKey("token")
        {
            let currenturl = UrlDomain + "/Simulation/UnsubscribeBusAlarm/" + route + "/" + stop + "/" + (mybustoken as! String)
            
            
            
            let myurl = NSURL(string: currenturl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            
            print(myurl)
            
            Alamofire.request(.GET, myurl!)
                .responseJSON { response in
                    
                    
                    
            }
            
            
            
        }
        
    }
    
    func SubscribeAlarm(route: String, stop: String, time: String){
        
        print("routestop")
        print(route + stop)
        
//        if let mybustoken = defaults.valueForKey("token")
//        {
//            let currenturl = UrlDomain + "/Simulation/SubscribeBusAlarm/" + route + "/" + stop + "/" + (mybustoken as! String)
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
        
        if let busStopName = self.defaults.valueForKey("busStopName")
        {
            if let mybustoken = self.defaults.valueForKey("apntoken")
            {
                if let busroute = self.defaults.valueForKey("UserSelectedBusRoute")
                {
                    //add to alarm lists
//                    let newlarm = Alarm(busroute: busroute as! String, busstop: busStopName as! String, remaintime: String(self.timeFromTimePicker.text!) , isenable: true)
//                    
//                    mainAlarmSets.alarmList.append(newlarm)
                    
                    
                    var unSubUrl = self.UrlDomain + "/Simulation/SubscribeBusAlarmIOS/" + (busroute as! String) + "/99163" + (busStopName as! String) + "/" + (mybustoken as! String)
                    
                    unSubUrl =  unSubUrl + "/" + time
                    
                    
                    print("alarm sub URL: " + String(unSubUrl))
                    
                    
                    //set this here so that if user select the same stop again, they can unsubribe
                    //defaults.setObject(busStopName, forKey: "previousalarmed")
                   
                    let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                    print("inside unsub conditionnnnnnnn0")
                   // print("subb: " + (myUnSubUrl as! String))
                    Alamofire.request(.GET, myUnSubUrl!)
                    
                    
                }
            }
        }
        
    }

}
