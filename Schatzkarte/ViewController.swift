//
//  ViewController.swift
//  Schatzkarte
//
//  Created by Jan Winter on 15.10.14.
//  Copyright (c) 2014 HSR. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var map: RMMapView!
    let mapSource: RMTileSource = RMMBTilesSource(tileSetResource: "hsr", ofType: "mbtiles")
    let hsrCoords: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 47.223252, longitude: 8.817011)
    let app: UIApplication = UIApplication.sharedApplication()
    //var topGuide: UILayoutSupport!
    var locManager:CLLocationManager!
    var markerIndex: Int!
    var solutionLogger: SolutionLogger!
    @IBOutlet var markerProgress: UIActivityIndicatorView!
    @IBOutlet var progressContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.topGuide = self.topLayoutGuide
        
        self.markerIndex = 1
        self.solutionLogger = SolutionLogger(viewController: self)
        
        self.initMap()
        self.view.addSubview(map)
        
        self.initLocationManager()
        
        self.initMarkerProgress()
        
        //self.createLayout()
    }
    
    func initMap() {
        self.map = RMMapView(frame: self.view.bounds, andTilesource: self.mapSource)
        self.map.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth;
        self.map.minZoom = 15
        self.map.maxZoom = 20
        self.map.zoom = 18
        self.map.setCenterCoordinate(hsrCoords, animated: false)
    }
    
    func initLocationManager() {
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        //locManager.distanceFilter = 1
    }
    
    func initMarkerProgress() {
        self.markerProgress.hidesWhenStopped = true
        //self.markerProgress.color = UIColor(red: 194, green: 0, blue: 0, alpha: 1)
        //self.view.bringSubviewToFront(self.markerProgress)
        self.progressContainer.hidden = true
        self.progressContainer.layer.cornerRadius = 10
        self.view.bringSubviewToFront(self.progressContainer)
    }
    
    func startCustomMProgressAnimation() {
        self.progressContainer.hidden = false
        self.markerProgress.startAnimating()
    }
    
    func stopCustomMProgressAnimation() {
        self.markerProgress.stopAnimating()
        self.progressContainer.hidden = true
    }
    
    func isLocServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            return true
        }
        
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if self.isLocServicesEnabled() {
            if authStatus == CLAuthorizationStatus.NotDetermined {
                locManager.requestWhenInUseAuthorization()
                println("not determined")
            } else if authStatus == CLAuthorizationStatus.Restricted || authStatus == CLAuthorizationStatus.Denied {
                var alert=UIAlertController(title:"Ortungsdienste erlauben",message:"Bitte die Ortungsdienste für diese APP in den Einstellungen erlauben.",preferredStyle:UIAlertControllerStyle.Alert);
                
                alert.addAction(UIAlertAction(title: "OK",style:UIAlertActionStyle.Default,handler:{
                (ACTION:UIAlertAction!) in
                    exit(1)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                println("denied or restricted")
            }
        } else {
            var alert=UIAlertController(title:"Ortungsdienste einschalten",message:"Bitte die Ortungsdienste einschalten.",preferredStyle:UIAlertControllerStyle.Alert);
            
            alert.addAction(UIAlertAction(title: "OK",style:UIAlertActionStyle.Default,handler:{
                (ACTION:UIAlertAction!) in
                exit(1)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //locManager.startUpdatingLocation()
    }
    
    @IBAction func setMarker(sender: AnyObject) {
        /*var marker:RMPointAnnotation = RMPointAnnotation(mapView: self.map, coordinate: CLLocationCoordinate2D(latitude: 47.223252, longitude: 8.817011), andTitle: "Marker")
        var marker2:RMPointAnnotation = RMPointAnnotation(mapView: self.map, coordinate: CLLocationCoordinate2D(latitude: 8.817011, longitude: 47.223252), andTitle: "Marker2")
        /*marker2.coordinate = CLLocationCoordinate2D(latitude: 8.817011, longitude: 47.223252)
        marker.coordinate = CLLocationCoordinate2D(latitude: 47.223252, longitude: 8.817011)
        marker.mapView = self.map
        marker2.mapView = self.map*/
        self.map.addAnnotation(marker)
        self.map.addAnnotation(marker2)
        println(self.map.annotations)*/
        if self.isLocServicesEnabled()  {
            locManager.startUpdatingLocation()
            //self.markerProgress.startAnimating()
            self.startCustomMProgressAnimation()
        } else {
            var alert=UIAlertController(title:"Ortungsdienste einschalten",message:"Bitte die Ortungsdienste einschalten.",preferredStyle:UIAlertControllerStyle.Alert);
            
            alert.addAction(UIAlertAction(title: "OK",style:UIAlertActionStyle.Default,handler:nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //println(locations)
        //println(manager.location.timestamp)
        //println(manager.location.timestamp.timeIntervalSinceNow)
        //println(locations.last)
        //println(manager.location)
        let locAge: NSTimeInterval = -manager.location.timestamp.timeIntervalSinceNow
        println(locAge)
        
        if locAge > 6.0 {
            return
        }
        
        if manager.location.horizontalAccuracy < 0 {
            return
        }
        
        println(manager.location.horizontalAccuracy)
        //println(manager.desiredAccuracy)
        println(self.locManager.desiredAccuracy)
        
        if manager.location.horizontalAccuracy <= 20.0 {
            self.locManager.stopUpdatingLocation()
            
            var uKey:String = "Marker \(self.markerIndex)"
            
            var marker:RMPointAnnotation = RMPointAnnotation(mapView: self.map, coordinate: CLLocationCoordinate2D(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude), andTitle: uKey)
            self.map.addAnnotation(marker)
            
            println(map.annotations)
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            var markerToSave : [NSObject : AnyObject] = [
                "latitude" : manager.location.coordinate.latitude,
                "longitude" : manager.location.coordinate.longitude
            ]
            
            println("Lat: \(manager.location.coordinate.latitude)")
            println("Lon: \(manager.location.coordinate.longitude)")
            
            userDefaults.setObject(markerToSave, forKey: uKey)
            var success:Bool = userDefaults.synchronize()
            
            //self.markerProgress.stopAnimating()
            self.stopCustomMProgressAnimation()
            
            if !success {
                var alert=UIAlertController(title:"Speicherfehler",message:"Der Marker konnte leider nicht gespeichert werden.",preferredStyle:UIAlertControllerStyle.Alert);
                
                alert.addAction(UIAlertAction(title: "OK",style:UIAlertActionStyle.Default,handler:nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.markerIndex = self.markerIndex + 1
            }
        }
    }
    
    @IBAction func logSolution(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var uDDictionary: [NSObject: AnyObject] = userDefaults.dictionaryRepresentation()
        //println(uDDictionary)
        //println(uDDictionary.values.array)
        var markerCollection: [NSObject: AnyObject]!
        
        for (key, value) in uDDictionary {
            var strKey = key as NSString
            println(strKey)
            
            if startsWith(String(strKey), "Marker") {
                println(String(strKey))
                
                println(value)
                markerCollection[key] = value as AnyObject
                
            }
        }
        
        println(markerCollection)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    /*override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.toRaw())
    }
    
    func createLayout() {
        

        //map.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        
        /*let viewsDictionary = ["map": self.map, "topGuide": self.topGuide]
        
        let map_constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[map]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let map_constraint_V:NSArray = NSLayoutConstraint.constraintsWithaVisualFormat("V:|-0-[topGuide]-0-[map]-0-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDictionary)
        
        self.view.addConstraints(map_constraint_H)
        self.view.addConstraints(map_constraint_V)*/
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

