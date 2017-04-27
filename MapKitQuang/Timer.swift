//
//  Timer.swift
//  Thrifa
//
//  Created by Quang Nguyen on 7/6/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import Foundation



class Main {
    
    var name = NSTimer()
    var isPaused = 0
    
    init(name:NSTimer) {
        self.name = name
    }
}


var mainInstance = Main(name: NSTimer())




class Alarm
{
    var busRoute = String()
    var busStop = String()
    var remainTime = String()
    var enable = Bool()

    init(busroute : String, busstop: String, remaintime : String, isenable : Bool)
    {
        self.busRoute = busroute
        self.busStop = busstop
        self.remainTime = remaintime
        self.enable = isenable
        
    }
}


var mainAlarm = Alarm(busroute: "Bus Routes", busstop: "Bus Stop", remaintime: "Time", isenable : true)

class AlarmSets
{
    var alarmList = [Alarm]()
    //var isSet = Bool()
    
    init ()
    {
        self.alarmList = [Alarm]()
        //self.isSet = Bool()
    }
    
    func AddAlarm(alarm: Alarm)
    {
        alarmList.append(alarm)
    }
    
    func GetAlarms() -> [Alarm]
    {
        return alarmList
    }
    
    func DoesContain(routeid : String, stopid: String) -> Bool
    {
        //print("blehh")
        print(routeid)
        print(stopid)
        for i in 0 ..< alarmList.count {
         
            if(alarmList[i].busRoute == routeid && alarmList[i].busStop == stopid && alarmList[i].enable == true)
            {
                return true
            }
        }
    
        return false
    }

}

var mainAlarmSets = AlarmSets()




