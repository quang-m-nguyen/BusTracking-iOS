//
//  ViewController.swift
//  MapKitQuang
//
//  Created by Quang Nguyen on 3/6/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import SwiftyJSON
import Alamofire
import Toast_Swift


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet var toPicker: UIButton!
   
    @IBOutlet var searchbar: UISearchBar!
    
    @IBOutlet var testbutton: UIButton!
    var rcvString = "Route I"
     //var cellColor = ["#EC7A08", "#B6BF00", "#3CB6CE", "#DBCEAC"]
    //var cellColor = ["#9E83E3", "#169CFF", "#70E588", "#F85E35", "FFFF63"]
    var cellColor = [String]()
    //var cellColor1 = ["#2f5055"]
    //var currentBusPositionID = ["99163ICurrentPosition", "99163ECurrentPosition", "99163SouthCurrentPosition"]
    var currentLat = 0.0
    var currentLong = 0.0
    
    var busname = [String]()
    var buscoordinates = [String]()
    
    var BusID = [String]()
    //var UrlDomain = "http://sudokit.com:3000"
      var UrlDomain = "http://52.32.160.105:3000"
    
  
  
  
    var latestBusPotitionPin =  [MKAnnotation]()

    
      let defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    var UsrSlctedStop = -1;
    
    let locationManager = CLLocationManager()
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    //    @IBOutlet weak var latLabel: UILabel!
    //    @IBOutlet weak var longLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var myRoute:MKRoute = MKRoute()
    var directionsResponse:MKDirectionsResponse = MKDirectionsResponse()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
            var helloWorldTimer = NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: #selector(ViewController.GetBusLocation), userInfo: nil, repeats: true)
        
        
        if let cColor = defaults.objectForKey("DisplayColor")
        {
            cellColor = cColor as! [String]
        }
        
        
        if let busid = defaults.objectForKey("DisplayRouteId")
        {
            BusID = busid as! [String]
        }
        
        defaults.setInteger(0, forKey: "tracker")
        
        
        searchbar.text = ""
       
        //        var mytoken = FIRInstanceID.instanceID().token()!
        //        print(mytoken)
        
        // _ = NSUserDefaults.standardUserDefaults()
        //print(defaults.stringForKey("token"))
        
        //print(rcvString)
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.RoutePicker.delegate = self
        //self.RoutePicker.dataSource = self
        //        self.mapView.removeAnnotations(self.mapView.annotations)
        //        let ol = self.mapView.overlays
        //
        //        for o in ol
        //        {
        //            self.mapView.removeOverlay(o)
        //        }
        //
        //        print("heyyyyyyyyyyyyy")
        
       
       
        searchbar.layer.borderWidth = 1
  
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        //if we don't do this, then the blue dot wont show
        self.mapView.showsUserLocation =  true
        self.mapView.mapType = MKMapType.Standard
        
        self.searchbar.delegate = self
        
        //let settingsStatus = defaults.objectForKey("settings")
        if((defaults.boolForKey("settings")) )
        {
        HighLightRoute(rcvString)
        }
        //add the pins
        GetBusStops(rcvString);
        
        //        Alamofire.request(.GET, "http://52.33.19.46/GetBusStops/E")
        //            .responseJSON { response in
        //                if let JSON1 = response.result.value {
        //                    print(JSON(JSON1)[0]["lat"])
        //                }
        //        }
        
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(observeUserDefaults), name:
//            NSUserDefaultsDidChangeNotification, object: nil)
        
 
        
        
        self.mapView.delegate = self
        

        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.searchbar.endEditing(true)
    
    }
    
    //function to draw on map
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(overlay: overlay)
        myLineRenderer.strokeColor = UIColor.darkGrayColor()
        myLineRenderer.lineWidth = 4
        
        return myLineRenderer
    }
    
    
    func observeUserDefaults() {
        
        
        
        
      
//        for i in 0 ..< currentBusPositionID.count {
//            print("bus keeeey")
//            print(currentBusPositionID[i])
//        
//            var buskey  = currentBusPositionID[i]
//            if let rcvlat = defaults.objectForKey(buskey)
//            {
//                print("rcvlatttttttttttttttttt")
//
//                print(rcvlat)
//                
//            }
//        
//        }
//        
        if let selectedRoute = defaults.objectForKey("SelectedRoute")
        {
            
            
        if let rcvPositions = defaults.objectForKey("BusesPosition")
        {
            
            print(selectedRoute)
            
            let newmsg = JSON(rcvPositions).rawString()
            
            var newjson = JSON.parse(newmsg!)
            
            var rcvedrid = newjson[0]["RouteID"].stringValue
            
            if(selectedRoute as! String == rcvedrid)
            {
 
                
            if((self.latestBusPotitionPin.count) > 0)
            {
                for i in 0 ..< self.latestBusPotitionPin.count {
                self.mapView.removeAnnotation(self.latestBusPotitionPin[i])
                }
                
                
            }
            self.latestBusPotitionPin =  [MKAnnotation]()
                
            
   
            
            
            
            
            

             for i in 0 ..< newjson.count {
                

                
                let  routeid = newjson[i]["RouteID"].stringValue
                let  busnum = newjson[i]["busnum"].stringValue
                let lat = newjson[i]["lat"].doubleValue
                let lng = newjson[i]["lng"].doubleValue
                

                let currentBusLocation = CustomPointAnnotation()
                currentBusLocation.coordinate = CLLocationCoordinate2DMake(lat, lng)
                let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
                currentBusLocation.title = routeid + " " + busnum + " last seen : " + timestamp
                
                
                
                print("routeiddddd")
                print(routeid)
                
                
                if(routeid == "99163Crimson")
                {
                    currentBusLocation.imageName = UIImage(named: "BusIconGray")
                }
                else
                {
                    currentBusLocation.imageName = UIImage(named: "BusIcon")
                }
                
                         dispatch_async(dispatch_get_main_queue()) {
                self.latestBusPotitionPin.append(currentBusLocation)
                            
                            
                

                self.mapView.addAnnotation(currentBusLocation)
                    }
                
                
                
            }
            }
            

            
            print("qqqqqqqqqqqq")
            
            
        }
        }
        
        
//        if let rcvlat = defaults.objectForKey("busLat")?.doubleValue
//        {
//            //            print("rcvlat")
//            //            print(rcvlat)
//            if let rcvlong = defaults.objectForKey("busLong")?.doubleValue
//            {
//                
//                
//                print("rcvlat")
//                print(rcvlat)
//                
//                if(currentLat != rcvlat  || currentLong != rcvlong )
//                {
//                    currentLat = rcvlat
//                    currentLong = rcvlong
//                    print("currentLat")
//                    print(currentLat)
//                    
//                    
//                    //remove previous pin
//                    if((latestBusPotitionPin) != nil)
//                    {
//                    
//                        mapView.removeAnnotation(latestBusPotitionPin)
//                    }
//                    
//
//                    
//                    let currentBusLocation = CustomPointAnnotation()
//                    currentBusLocation.coordinate = CLLocationCoordinate2DMake(currentLat, currentLong)
//                    let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
//                    currentBusLocation.title = "last seen : " + timestamp
//
//                    
//                    
//                    
//                    currentBusLocation.imageName = UIImage(named: "BusIcon")
//                    
//                    
//                    latestBusPotitionPin = currentBusLocation
//                    
//                    
//                    self.mapView.addAnnotation(currentBusLocation)
//                    
//                    
//                   
//                }
//                
//                
//            }
//        }
        
    }

    func GetBusLocation()
    {
        //NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: #selector(GetBusLocation), userInfo: nil, repeats: true)
        
        print("inside get BusLocation")
        
        
        if let selectedroute = defaults.objectForKey("SelectedRoute")
        {
        
//           var route =  (selectedroute.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString("")
            
            let unSubUrl = UrlDomain + "/GetBusPosition/" + (selectedroute as! String)

            print(unSubUrl)
            let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            
            print("GetBusPosition url : " + (unSubUrl ))
            Alamofire.request(.GET, myUnSubUrl!)
                .validate()
                .responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    print("Response String: \(response.result.value)")
                    if(response.result.isSuccess == false)
                    {
                        return
                    }
                    
                    if(response.result.value == "[]")
                    {
                        let alert = UIAlertView()
                        alert.title = "Thrifa No Buses Alert"
                        alert.message = "There are no buses running for this route at this time.  Please refer to offline schedule for more details."
                        alert.addButtonWithTitle("Okay")
                        alert.show()
                        
                        
                        
                        self.defaults.setObject("", forKey: "SelectedRoute")
                        
                    }
                    
                    
                    
                    //clearing out old markers
                    if((self.latestBusPotitionPin.count) > 0)
                    {
                        for i in 0 ..< self.latestBusPotitionPin.count {
                            self.mapView.removeAnnotation(self.latestBusPotitionPin[i])
                        }
                        
                        
                    }
                    self.latestBusPotitionPin =  [MKAnnotation]()
                    
                    
                     let newmsg = response.result.value!
                    
                        
                    var mnewmsg = JSON(newmsg).rawString()
                    var newjson = JSON.parse(mnewmsg!)
                    print("yoyooyo")
                    print(newjson)
                    

                    
                    for i in 0 ..< newjson.count {
                        
                        
                        
                        let  routeid = newjson[i]["routeID"].stringValue
                        //let  busnum = newjson[i]["busnum"].stringValue
                        let lat = newjson[i]["lat"].doubleValue
                        let lng = newjson[i]["lng"].doubleValue
                        let bid = newjson[i]["busID"].intValue
                        
                        
                        let currentBusLocation = CustomPointAnnotation()
                        currentBusLocation.coordinate = CLLocationCoordinate2DMake(lat, lng)
                        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
                        
                        
                        currentBusLocation.title = "Bus #" + String(bid)
                        
                        
                        
                        
                        if(routeid == "99163Crimson")
                        {
                            currentBusLocation.imageName = UIImage(named: "BusIconGray")
                        }
                        else
                        {
                            currentBusLocation.imageName = UIImage(named: "BusIcon")
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.latestBusPotitionPin.append(currentBusLocation)
                            
                            
                            self.mapView.addAnnotation(currentBusLocation)
                        }
                        
                        
                        
                    }
                    
                    
                    
            }
            
            
        
        }
        
     
    
    }
    
    
    func serResponse(mystr: String)
    {
        let tracker = defaults.integerForKey("tracker")
        
          print("Going to the next VC!")
        print(mystr)
        self.view.makeToast("Click on Home Tab to Close Popup", duration: 4.0, position: .Bottom)
        if(tracker != 0)
        {
            
           
                self.presentedViewController!.dismissViewControllerAnimated(false, completion: nil)
                if let mybustoken = FIRInstanceID.instanceID().token() {
                    
                    if(defaults.valueForKey("UnSubBusStopName") != nil)
                    {
                        if let unsubStop = defaults.valueForKey("UnSubBusStopName")
                        {
                            let unSubUrl = UrlDomain + "/Simulation/UnsubscribeBusstop/99163" + (unsubStop as! String) + "/" + mybustoken
                            let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                            print("inside unsub conditionnnnnnnn")
                            //mainInstance.name.invalidate()
                            mainInstance.isPaused = 1
                            //mainInstance.name.invalidate()
                            print("unsub: " + (unsubStop as! String))
                            Alamofire.request(.GET, myUnSubUrl!)
                                .responseJSON { response in
                                    
                                    if(response.result.isSuccess == false)
                                    {
                                        print("UnsubscribeBusstop fail....")
                                        return
                                        
                                    }
                                    
                            }
                        }
                    }
                }
             
            

        }
        defaults.setObject(mystr, forKey: "SavedStringArray")
        defaults.synchronize()
        //defaults.setObject("somestring", forKey: "SavedStringArray")
        
        let array = defaults.valueForKey("SavedStringArray") as! String
        
        print(String(array))
        
        
        
        //save the lat and long of selected bus stop before we switch to a new screen
        if let busStopName = defaults.valueForKey("busStopName")
        {
            
            
            
            var name = busStopName as? String
             for i in 0 ..< busname.count {
                
                if(name == busname[i])
                {
                    var destsrc = buscoordinates[i]
                    defaults.setObject(destsrc, forKey: "destkey")
                    
                    
                    print("woooooooooow")
                    print(busname[i])
                    print(buscoordinates[i])
                
                }
                
            }
            
            
            
        }
        
        
        
        performSegueWithIdentifier("showView", sender: self)
        defaults.setInteger(1, forKey: "tracker")
        
       
    }
    
    // When user taps on the disclosure button you can perform a segue to navigate to another view controller
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
       
          // print(view.annotation!.title) // annotation's title
        
        if control == view.rightCalloutAccessoryView{
            
            
            
            //print(view.annotation!.title) // annotation's title
            //print("getting the title :")
            // print(String(view.annotation!.title))
            if let title = view.annotation!.title{
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(title, forKey: "busStopName")
                defaults.synchronize()
                
               // print("anotation titleeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
                
               // let blah = defaults.stringForKey("busStopName")
                
               // print("selecting this bus stop name; " + String(blah))
//                if (title == "Davis and Cory Ln.") {
//                    print("equql")
//                }
                
                
             

                
            }
//            if(String((view.annotation!.title)) == "Optional(\"Grand & Stadium\")"){
//                print(String(view.annotation!.title))
//            }
//            if(String(view.annotation!.title) == "Optional(\"Grand & Stadium\")")
//            {
//                print("inside if")
//            print(view.annotation!.title)
//            }
            //print(view.annotation!.subtitle) // annotation's subttitle
            
            //Perform a segue here to navigate to another viewcontroller
            // On tapping the disclosure button you will get here
            
            //let newString = String(view.annotation!.subtitle)
           
            if control == view.rightCalloutAccessoryView {
                serResponse("doesntmatter")
             //   print("anotation titleeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")

                
               
             
               
                
                //when users are going to the next page, we call an API to get all routes name that contain certain bus stop
                
//                Alamofire.request(.GET, "http://52.33.19.46/GetBusStops/E")
//                    .responseJSON { response in
// 
//                     dispatch_async(dispatch_get_main_queue()) {
//                        if((response.result.value) != nil)
//                        {
//                            self.serResponse("saving the response")
//                        }
//                        }
//                        
//                        
//                       // defaults.synchronize()
//                        
//
//                        //print(response.result.value)
//                        
//                }

                
            }
            
       
            
            
//            if let newString = view.annotation!.subtitle {
//                var mynewstr = newString!.componentsSeparatedByString(" ")
//                //print(mynewstr[0])
//                
//                //SetNotification(Int(mynewstr[0])!)
//                
//                self.UsrSlctedStop = Int(mynewstr[0])!
//                
//                
//                //                var updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.SetNotification), userInfo: nil, repeats: true)
//                //
//                
//                SetNotification()
//                
//            }
            
            //print(newString)
            
            //var newStringInt = Int(newString)
            
            //print("new string: ®" + newString)
            
            //            var SetNotificationTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("SetNotification"), userInfo: newString, repeats: true)
            //
            
            // SetNotification(newStringInt!)
            
            
        }
    }
    


    
    //popup a modal when user click showView
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let screenSize:CGRect = UIScreen.mainScreen().bounds
        if segue.identifier == "showView"
        {
            mainInstance.isPaused = 0
            let vc =  segue.destinationViewController
            
            _ =  vc.popoverPresentationController
            
            
            if segue.identifier == "showView" {
                if let controller = segue.destinationViewController as? UIViewController {
                    controller.popoverPresentationController!.delegate = self
                    controller.preferredContentSize = CGSize(width: screenSize.width, height: screenSize.height * 0.3)


                    
                    let popContoller = controller.popoverPresentationController
                  
                    
                    popContoller?.delegate = self
                   // popContoller?.sourceView = self.view
                    popContoller?.backgroundColor = UIColor.clearColor()
                    
                    //popContoller?.permittedArrowDirections = UIPopoverArrowDirection()
                    popContoller!.sourceRect = CGRectMake(0,-screenSize.height * 0.24,screenSize.width,screenSize.height * 0.3)
                  
                    
                    popContoller?.passthroughViews = [self.mapView]
                    

                    
                   // popContoller?.arrowDirection = UIPopoverArrowDirection()
                    //self.presentViewController(nav, animated: true, completion: nil)
                    if let busStopName = defaults.valueForKey("busStopName")
                    {
                        
                        
                       
                            searchbar.text = busStopName as? String
                        
                    }
                }
                
     
            }
            
//            if (controller != nil)
//            {
//                controller?.delegate = self
//                
//            }
        }
    }

    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        defaults.setInteger(0, forKey: "tracker")
        print("popover is closed")
//        if((latestBusPotitionPin) != nil)
//        {
//        mapView.removeAnnotation(latestBusPotitionPin)
//        }
            self.searchbar.text = ""
        
        if let mybustoken = FIRInstanceID.instanceID().token() {
            
        if(defaults.valueForKey("UnSubBusStopName") != nil)
        {
            if let unsubStop = defaults.valueForKey("UnSubBusStopName")
            {
                let unSubUrl = UrlDomain + "/Simulation/UnsubscribeBusstop/99163" + (unsubStop as! String) + "/" + mybustoken
                let myUnSubUrl = NSURL(string: unSubUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                print("inside unsub conditionnnnnnnn")
                //mainInstance.name.invalidate()
                mainInstance.isPaused = 1
                //mainInstance.name.invalidate()
                print("unsub: " + (unsubStop as! String))
                Alamofire.request(.GET, myUnSubUrl!)
                    .responseJSON { response in
                        
                        
                        
                }
            }
        }
        }
        
    }
    

    //force to use a popup instead of a modal
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    // Here we add disclosure button inside annotation window
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //        //print("viewForannotation")
        //        //print(annotation.title)
        //        if annotation is MKUserLocation {
        //            //return nil
        //            return nil
        //        }
        //
        //        let reuseId = "annotation"
        //        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        //
        //
        //       // print(pinView)
        //
        //        if pinView == nil {
        //            //println("Pinview was nil")
        //            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        //            pinView!.canShowCallout = true
        ////            pinView!.animatesDrop = false
        //
        //        }
        //        else {
        //            pinView!.annotation = annotation
        //        }
        //        //change this to get different button type
        //        //let button = UIButton(type: .DetailDisclosure) // button with info sign in it
        //
        //
        //        //pinView?.rightCalloutAccessoryView = button
        //
        //        pinView!.image = UIImage(named:"pin.png")
        //
        //        return pinView
        
        
        
        // print("delegate called")
        
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        
        anView!.image = cpa.imageName
       
        let button = UIButton(type: .DetailDisclosure) // button with info sign in it
        //
        //
        anView?.rightCalloutAccessoryView = button
        
        return anView
    }
    
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        //start updating in viewDidAppear as instructed
        //print("view diiiid appear")
        self.locationManager.startUpdatingLocation()
        self.locationManager.stopUpdatingLocation()
    }
    override func viewDidDisappear(animated: Bool) {
        //start updating in viewDidDisappear as instructed
        // print("view diiiid disspearappear")
        self.locationManager.stopUpdatingLocation()
    }
    
//    override func viewWillAppear(animated: Bool) {
//         self.view.superview!.layer.cornerRadius = 0;
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func GetBusStops(route: String){
        var selectedRoute = ""
        var routeColor = ""
        
        
        
        for i in 0 ..< BusID.count {
            
            if(route == BusID[i])
            {
                print("aaaaaaaaa")
                print(route)
                
//                var rid = (route.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString("")
                selectedRoute = UrlDomain + "/GetBusStops/" + route
                routeColor = cellColor[i]
                dispatch_async(dispatch_get_main_queue()) {
                self.testbutton.backgroundColor = hexStringToUIColor(self.cellColor[i])
                self.searchbar.layer.borderColor = hexStringToUIColor(self.cellColor[i]).CGColor
                }
            
            }
            
        }
        
        
        
        //drawing the circle
        
        let url = NSURL(string: selectedRoute)
        
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 15, height: 15), false, 0)
        let context = UIGraphicsGetCurrentContext()
        let rectangle = CGRect(x: 0, y: 0, width: 15, height: 15)
        
        CGContextSetFillColorWithColor(context, hexStringToUIColor(routeColor).CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(context, 1.5)
        
        CGContextAddEllipseInRect(context, rectangle)
        CGContextDrawPath(context, .FillStroke)
        
        var img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
         //drawing the circle
        
        Alamofire.request(.GET, url!)
            .responseJSON { response in
                if let JSON1 = response.result.value {
                    let total = JSON(JSON1).count
                    
                    for i in 0 ..< total {
                        autoreleasepool {

                        let info1 = CustomPointAnnotation()
                        info1.coordinate = CLLocationCoordinate2DMake(JSON(JSON1)[i]["lat"].double!, JSON(JSON1)[i]["long"].double!)

                        info1.title = JSON(JSON1)[i]["stopname"].stringValue
                        info1.subtitle = "Tap for Arrival Time"
                     
                            
                        //saving this into an array so that we can get the lat and long for specific bus stop later
                        self.busname.append(JSON(JSON1)[i]["stopname"].stringValue)
                        let destlatlong = JSON(JSON1)[i]["lat"].stringValue + "," + JSON(JSON1)[i]["long"].stringValue
                        
                        self.buscoordinates.append(destlatlong)
                            
                        info1.imageName = img
                        
                        
                        
                        
                        dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.addAnnotation(info1)
                            }
                           // img = nil

                    }
                    }
                    img = nil
                    
                    
                    //zoom into the last marker generated on the map
                    let point2 = MKPointAnnotation()
                    
                    point2.coordinate = CLLocationCoordinate2DMake(JSON(JSON1)[total / 3 ]["lat"].double!, JSON(JSON1)[total / 3 ]["long"].double!)
                    
                    self.mapView.setRegion(MKCoordinateRegionMake(point2.coordinate, MKCoordinateSpanMake(0.025,0.025)), animated: false)
                    
                }
        }
            //get bus position 
           GetBusLocation()
       
        
    }
    
    
    func HighLightRoute(route: String){
        
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        //dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            // self.viewDidLoad()
            //testing marking the map
            var source:MKMapItem?
            var destination:MKMapItem?
            
            
        
            
            var boolCount = 0 //use this to know which one is the next bus stop
            var sourceLat = 0.0
            var sourceLong = 0.0
            var sourceName = ""
            var destiantionLat = 0.0
            var destiantionLong = 0.0
            var destinationName = ""

            
            var selectedRoute = ""
            
             for i in 0 ..< self.BusID.count {
                
                if(route == self.BusID[i])
                {
//                    var rid = (route.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()) as NSArray).componentsJoinedByString("")
                    selectedRoute = self.UrlDomain + "/GetPath/" + route
                    print("GetPath URL")
                    print(selectedRoute)
                }
                
                
            }
            


            
            let url = NSURL(string: selectedRoute)
            
            Alamofire.request(.GET, url!)
                .responseJSON { response in
                    if let JSON1 = response.result.value {
                        let total = JSON(JSON1).count
//                        dispatch_async(dispatch_get_main_queue(), {
                            for i in 0 ..< total {
                               // print("i: " + String(i))
                               // print(JSON(JSON1)[i]["lat"])

                                
                                
                                
                                    
                                    //clear previous map if any
                                    
                                    //self.mapView.removeAnnotations(self.mapView.annotations)
                                    
                                    //set coordiantes
                                    
                                    destiantionLat = JSON(JSON1)[i]["lat"].double!
                                    destiantionLong = JSON(JSON1)[i]["long"].double!
                                    destinationName = JSON(JSON1)[i]["stopname"].stringValue
                                    
                                    //then draw map
                                if(i + 1 < total)
                                {
                                
                                let point1 = MKPointAnnotation()
                                let point2 = MKPointAnnotation()
                                    point1.coordinate = CLLocationCoordinate2DMake(JSON(JSON1)[i]["lat"].double! , JSON(JSON1)[i]["long"].double!)

                                    point2.coordinate = CLLocationCoordinate2DMake(JSON(JSON1)[i+1]["lat"].double!, JSON(JSON1)[i+1]["long"].double!)

                                    self.mapView.delegate = self
                                    
                                    //Span of the map
                                    self.mapView.setRegion(MKCoordinateRegionMake(point2.coordinate, MKCoordinateSpanMake(0.025,0.025)), animated: false)
                                    
                                    let directionsRequest = MKDirectionsRequest()
//                                    let markTaipei = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point1.coordinate.latitude, point1.coordinate.longitude), addressDictionary: nil)
//                                    let markChungli = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point2.coordinate.latitude, point2.coordinate.longitude), addressDictionary: nil)
                                
                                    
                                    let c1 = CLLocationCoordinate2DMake(point1.coordinate.latitude, point1.coordinate.longitude)
                                    let c2 = CLLocationCoordinate2DMake(point2.coordinate.latitude, point2.coordinate.longitude)
                                    var a = [c1, c2]
                                    
                                    var polyline = MKPolyline(coordinates: &a, count: a.count)
                                    dispatch_async(dispatch_get_main_queue()) {
                                    self.mapView.addOverlay(polyline)
                                    }
                                    
                                }

                                
                                    
                                    
//                                    source = MKMapItem(placemark: markChungli)
//                                    destination = MKMapItem(placemark: markTaipei)
//                                    
//                                    directionsRequest.source = source;
//                                    directionsRequest.destination = destination;
//                                    directionsRequest.transportType = MKDirectionsTransportType.Automobile
//                                    let directions = MKDirections(request: directionsRequest)
//                                    directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error:NSError?) -> Void in
//                                        
//                                        if error == nil {
//                                            self.directionsResponse = response!
//                                            self.myRoute = self.directionsResponse.routes[0]
//                                            self.mapView.addOverlay(self.myRoute.polyline, level: MKOverlayLevel.AboveRoads)
//                                        } else {
//                                            print(error)
//                                        }
//                                    }
                                    
                                    
                                    //boolCount = 0
                                    
                                    
//                                    //then set current cordiantes to old
//                                    sourceLat = JSON(JSON1)[i]["lat"].double!
//                                    sourceLong = JSON(JSON1)[i]["long"].double!
                                    
                                    
                                }
                                
                                
                            
                          //  boolCount = 0
                            
                       // }) // end of dispatch async
                        
                        
                    }
            }
            
            
            
        //}
        
    }
    
    
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        

        //grab locations fromdidUpdateLocations delegate
        let location = locations.last
        let center = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        //let center = CLLocationCoordinate2DMake(46.7298, 117.1817)
        //update our long and lats here
        //longLabel.text = "Longtitude: " + String(location!.coordinate.longitude)
        //latLabel.text = "Latitude: " + String(location!.coordinate.latitude)
        //after configuring our locations, set the zoom ration
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        //add to map
        //i set animated to false because it cause my computer to lag then crash lol...
        
        var latlng = String(location!.coordinate.latitude) + "," + String(location!.coordinate.longitude)
        defaults.setObject(latlng, forKey: "srckey")
        
        
        //uncomment this line when you want to zoom in user location
        if((defaults.boolForKey("zoom")) )
        {
            self.mapView.setRegion(region, animated: false)
        }
        
        
    }
    
    
    

    
    func DetermineRoute(busStop: String) -> Int{
        
        if(busStop == "Route E")
        {
            return 1
        }
        else if (busStop == "Route I")
        {
            return 2
        }
        
        return -1;
    }
        func TriggerBG(){
            
            backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                
                UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!)
            })
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


class CustomPointAnnotation: MKPointAnnotation {
    var imageName: UIImage!
}






