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


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    
    var rcvString = "Route E"
    
    
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
        
        
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        //if we don't do this, then the blue dot wont show
        self.mapView.showsUserLocation =  true
        self.mapView.mapType = MKMapType.Standard
        
        
        
        
        //add the pins
        //HighLightRoute(rcvString)
        GetBusStops(rcvString);
        
        //        Alamofire.request(.GET, "http://52.33.19.46/GetBusStops/E")
        //            .responseJSON { response in
        //                if let JSON1 = response.result.value {
        //                    print(JSON(JSON1)[0]["lat"])
        //                }
        //        }
        
        
        self.mapView.delegate = self
        
        //        var info1 = CustomPointAnnotation()
        //        info1.coordinate = CLLocationCoordinate2DMake(26.889281, 75.836042)
        //        info1.title = "Info1"
        //        info1.subtitle = "Subtitle"
        //        info1.imageName = "pin.png"
        //
        //        var info2 = CustomPointAnnotation()
        //        info2.coordinate = CLLocationCoordinate2DMake(26.862280, 75.815098)
        //        info2.title = "Info2"
        //        info2.subtitle = "Subtitle"
        //        info2.imageName = "pin.png"
        //
        //        mapView.addAnnotation(info1)
        //        mapView.addAnnotation(info2)
        
        
        
    }
    
    //function to draw on map
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: (myRoute.polyline))
        myLineRenderer.strokeColor = UIColor.darkGrayColor()
        myLineRenderer.lineWidth = 3
        
        return myLineRenderer
    }
    
    func serResponse(mystr: String)
    {
          print("Going to the next VC!")
        defaults.setObject(mystr, forKey: "SavedStringArray")
        //defaults.setObject("somestring", forKey: "SavedStringArray")
        
        var array = defaults.valueForKey("SavedStringArray") as! String
        
        print(String(array))
        
        performSegueWithIdentifier("showView", sender: self)
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
             //   print("anotation titleeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")

                
               
             
               
                
                //when users are going to the next page, we call an API to get all routes name that contain certain bus stop
                
                Alamofire.request(.GET, "http://52.33.19.46/GetBusStops/E")
                    .responseJSON { response in
 
                     
                        if((response.result.value) != nil)
                        {
                            self.serResponse("saving the response")
                        }
                        
                        
                       // defaults.synchronize()
                        

                        //print(response.result.value)
                        
                }

                
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
            let vc =  segue.destinationViewController
            
            _ =  vc.popoverPresentationController
            
            
            if segue.identifier == "showView" {
                if let controller = segue.destinationViewController as? UIViewController {
                    controller.popoverPresentationController!.delegate = self
                    controller.preferredContentSize = CGSize(width: screenSize.width, height: screenSize.height * 0.3)

                    
                    let popContoller = controller.popoverPresentationController
                  
                    
                    popContoller?.delegate = self
                    popContoller?.sourceView = self.view
                    popContoller?.backgroundColor = UIColor.clearColor()
                    
                    //popContoller?.permittedArrowDirections = UIPopoverArrowDirection()
                    popContoller!.sourceRect = CGRectMake(0,-97,screenSize.width,screenSize.height * 0.3)
                  
                   // popContoller?.arrowDirection = UIPopoverArrowDirection()
                    //self.presentViewController(nav, animated: true, completion: nil)
                    
                }
            }
            
//            if (controller != nil)
//            {
//                controller?.delegate = self
//                
//            }
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
        
        anView!.image = UIImage(named:cpa.imageName)
       
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
        
        if(route == "Route I" )
        {
            selectedRoute = "http://52.33.19.46/GetBusStops/" + "I"
        }
        else if(route == "Route E")
        {
            selectedRoute = "http://52.33.19.46/GetBusStops/" + "E"
        }
        
        
        let url = NSURL(string: selectedRoute)
        
        Alamofire.request(.GET, url!)
            .responseJSON { response in
                if let JSON1 = response.result.value {
                    let total = JSON(JSON1).count
                    for i in 0 ..< total {
                        //print("i: " + String(i))
                        //print(JSON(JSON1)[i]["lat"])
                        
                        let info1 = CustomPointAnnotation()
                        info1.coordinate = CLLocationCoordinate2DMake(JSON(JSON1)[i]["lat"].double!, JSON(JSON1)[i]["long"].double!)
                        //print("title")
                        //print(JSON(JSON1)[i]["stopname"].stringValue)
                        info1.title = JSON(JSON1)[i]["stopname"].stringValue
                        info1.subtitle = "  tap for more details"
                     
                        info1.imageName = "orangedot.png"
                        
                        
                        
                        self.mapView.addAnnotation(info1)

                    }
                    
                    
                    //zoom into the last marker generated on the map
                    let point2 = MKPointAnnotation()
                    
                    point2.coordinate = CLLocationCoordinate2DMake(JSON(JSON1)[total / 3 ]["lat"].double!, JSON(JSON1)[total / 3 ]["long"].double!)
                    
                    self.mapView.setRegion(MKCoordinateRegionMake(point2.coordinate, MKCoordinateSpanMake(0.05,0.05)), animated: false)
                    
                }
        }
        
    }
    
    
    func HighLightRoute(route: String){
        
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
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
            _ = [""]
            
            var selectedRoute = ""
            
            if(route == "Route I" )
            {
                selectedRoute = "http://52.33.19.46/GetBusStops/" + "I"
            }
            else if(route == "Route E")
            {
                selectedRoute = "http://52.33.19.46/GetBusStops/" + "E"
            }
            
            
            let url = NSURL(string: selectedRoute)
            
            Alamofire.request(.GET, url!)
                .responseJSON { response in
                    if let JSON1 = response.result.value {
                        let total = JSON(JSON1).count
                        dispatch_async(dispatch_get_main_queue(), {
                            for i in 0 ..< total {
                               // print("i: " + String(i))
                               // print(JSON(JSON1)[i]["lat"])
                                
                                let point1 = MKPointAnnotation()
                                let point2 = MKPointAnnotation()
                                
                                
                                if(boolCount == 0){
                                    sourceLat = JSON(JSON1)[i]["lat"].double!
                                    sourceLong = JSON(JSON1)[i]["lat"].double!
                                    sourceName = JSON(JSON1)[i]["stopname"].stringValue
                                    boolCount = 1
                                }
                                if(boolCount == 1)
                                {
                                    
                                    //clear previous map if any
                                    
                                    //self.mapView.removeAnnotations(self.mapView.annotations)
                                    
                                    //set coordiantes
                                    
                                    destiantionLat = JSON(JSON1)[i]["lat"].double!
                                    destiantionLong = JSON(JSON1)[i]["long"].double!
                                    destinationName = JSON(JSON1)[i]["stopname"].stringValue
                                    
                                    //then draw map
                                    
                                    point1.coordinate = CLLocationCoordinate2DMake(sourceLat , sourceLong)
                                    // point1.title = sourceName
                                    // point1.subtitle = "Pullman"
                                    //self.mapView.addAnnotation(point1)
                                    
                                    point2.coordinate = CLLocationCoordinate2DMake(destiantionLat, destiantionLong)
                                    // point2.title = destinationName
                                    // point2.subtitle = "Pullman"
                                    // self.mapView.addAnnotation(point2)
                                    // self.mapView.centerCoordinate = point2.coordinate
                                    self.mapView.delegate = self
                                    
                                    //Span of the map
                                    self.mapView.setRegion(MKCoordinateRegionMake(point2.coordinate, MKCoordinateSpanMake(0.1,0.1)), animated: false)
                                    
                                    let directionsRequest = MKDirectionsRequest()
                                    let markTaipei = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point1.coordinate.latitude, point1.coordinate.longitude), addressDictionary: nil)
                                    let markChungli = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point2.coordinate.latitude, point2.coordinate.longitude), addressDictionary: nil)
                                    
                                    source = MKMapItem(placemark: markChungli)
                                    destination = MKMapItem(placemark: markTaipei)
                                    
                                    directionsRequest.source = source;
                                    directionsRequest.destination = destination;
                                    directionsRequest.transportType = MKDirectionsTransportType.Automobile
                                    let directions = MKDirections(request: directionsRequest)
                                    directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error:NSError?) -> Void in
                                        
                                        if error == nil {
                                            self.directionsResponse = response!
                                            self.myRoute = self.directionsResponse.routes[0]
                                            self.mapView.addOverlay(self.myRoute.polyline, level: MKOverlayLevel.AboveRoads)
                                        } else {
                                            print(error)
                                        }
                                    }
                                    
                                    
                                    //boolCount = 0
                                    
                                    
                                    //then set current cordiantes to old
                                    sourceLat = JSON(JSON1)[i]["lat"].double!
                                    sourceLong = JSON(JSON1)[i]["long"].double!
                                    
                                    
                                }
                                
                                
                            }
                            boolCount = 0
                            
                        }) // end of dispatch async
                        
                        
                    }
            }
            
            
            
        }
        
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
        
        
        
        
        //uncomment this line when you want to zoom in user location
        //self.mapView.setRegion(region, animated: true)
        
    }
    
    
    
    //after the user clicked the bus stop, we check and send notification here
    func SetNotification(){
        let defaults = NSUserDefaults.standardUserDefaults()
        print("SetNotification is being called.")
        let token = defaults.stringForKey("token")
        
        let route = "/" + String(DetermineRoute(rcvString))
        
        let busStop = "/" + String(self.UsrSlctedStop)
        
        print(route)
        print(busStop)
        
        let urltoken = "http://sudokit.com:3000/Register/"+token!+route+busStop
        
        //save url in user default
        // var storage = NSUserDefaults.standardUserDefaults()
        defaults.setObject(urltoken, forKey: "urltoken")
        
        
        //                let url = NSURL(string: urltoken)
        //
        //                let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
        //                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        //                   // _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
        //
        //
        //                }
        //
        //                task.resume()
        
        
        //        var token = defaults.stringForKey("token")
        //        var route = "/" + String(DetermineRoute(rcvString))
        //        var busStop = "/" + String(self.UsrSlctedStop)
        //
        //        var registerUrl = "http://52.33.19.46/Register/" + token! + route + busStop
        //        print(registerUrl)
        //
        //        let url = NSURL(string: registerUrl)
        //
        //        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
        //            var receivedStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
        //            if((error) != nil)
        //            {
        //                print(error)
        //            }
        //
        //            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        ////            let receivedStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
        ////
        ////            //write code to handle the array here
        ////
        ////            let currentStop = Int((receivedStr?.intValue)!)
        ////
        ////
        ////            print(self.UsrSlctedStop)
        ////            print(currentStop)
        ////
        ////            if(currentStop == self.UsrSlctedStop)
        ////            {
        ////                print("matched")
        ////
        ////            //clean up all notifications upon start
        ////            UIApplication.sharedApplication().cancelAllLocalNotifications()
        ////            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        ////
        ////
        ////
        ////            //setting up TEST notification
        ////            let notification = UILocalNotification()
        ////            notification.fireDate = NSDate (timeIntervalSinceNow: 1)
        ////            notification.alertBody = "Your bus is here"
        ////            //notification.soundName = "gc.mp3"
        ////            notification.timeZone = NSTimeZone.localTimeZone()
        ////            notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        ////            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        ////            
        ////      
        ////            
        ////            }
        //            
        //            
        //            
        //        }
        //        
        //        task.resume()
        
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
    //    func TriggerBG(){
    //        
    //        backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
    //            
    //            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!)
    //        })
    //    }
    
    
    
    
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
    var imageName: String!
}

