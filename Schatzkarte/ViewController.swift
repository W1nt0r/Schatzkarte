//
//  ViewController.swift
//  Schatzkarte
//
//  Created by Jan Winter und Adrian Tang on 15.10.14.
//  Copyright (c) 2014 HSR. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var map: RMMapView!
    var mapSource: RMTileSource!
    let hsrCoords: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 47.223252, longitude: 8.817011)
    let app: UIApplication = UIApplication.sharedApplication()
    var locManager:CLLocationManager!
    var markerIndex: Int!
    var solutionLogger: SolutionLogger!
    @IBOutlet var markerProgress: UIActivityIndicatorView!
    @IBOutlet var progressContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapSource = RMMBTilesSource(tileSetResource: "hsr", ofType: "mbtiles")
        
        self.markerIndex = 1
        self.solutionLogger = SolutionLogger(viewController: self)
        
        self.initMap()
        self.view.addSubview(map)
        
        self.initLocationManager()
        
        self.initMarkerProgress()
        
        self.loadMarker()
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
    }
    
    func initMarkerProgress() {
        self.markerProgress.hidesWhenStopped = true
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
    }
    
    @IBAction func setMarker(sender: AnyObject) {
        if self.isLocServicesEnabled()  {
            locManager.startUpdatingLocation()
            self.startCustomMProgressAnimation()
        } else {
            var alert=UIAlertController(title:"Ortungsdienste einschalten",message:"Bitte die Ortungsdienste einschalten.",preferredStyle:UIAlertControllerStyle.Alert);
            
            alert.addAction(UIAlertAction(title: "OK",style:UIAlertActionStyle.Default,handler:nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func loadMarker() {
        if let markerCollection = self.getMarker() {
            self.markerIndex = self.markerIndex + markerCollection.count
            
            for val in markerCollection {
                let latitude: Double = val["lat"] as Double
                let longitude: Double = val["lon"] as Double
                
                let marker: RMPointAnnotation = RMPointAnnotation(mapView: self.map, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), andTitle: "Marker")
                self.map.addAnnotation(marker)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let locAge: NSTimeInterval = -manager.location.timestamp.timeIntervalSinceNow
        
        if locAge > 6.0 {
            return
        }
        
        if manager.location.horizontalAccuracy < 0 {
            return
        }
        
        if manager.location.horizontalAccuracy <= 20.0 {
            self.locManager.stopUpdatingLocation()
            
            var uKey:String = "Marker \(self.markerIndex)"
            
            var marker:RMPointAnnotation = RMPointAnnotation(mapView: self.map, coordinate: CLLocationCoordinate2D(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude), andTitle: uKey)
            marker.mapView = self.map
            self.map.addAnnotation(marker)
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            var markerToSave : [NSObject : AnyObject] = [
                "lat" : manager.location.coordinate.latitude,
                "lon" : manager.location.coordinate.longitude
            ]
            
            userDefaults.setObject(markerToSave, forKey: uKey)
            var success:Bool = userDefaults.synchronize()
            
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
    
    func getMarker() -> Array<[NSObject: AnyObject]>? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let uDDictionary: [NSObject: AnyObject] = userDefaults.dictionaryRepresentation()
        var markerCollection = Array<[NSObject: AnyObject]>()
        
        for (key, value) in uDDictionary {
            let strKey = key as NSString
            let keyStr = String(strKey)
            
            if startsWith(keyStr, "Marker") {
                markerCollection.append(value as [NSObject: AnyObject])
            }
        }
        
        if markerCollection.isEmpty {
            return nil
        } else {
            return markerCollection
        }
    }
    
    @IBAction func logSolution(sender: AnyObject) {
        if let markerCollection = self.getMarker() {
            if let solution = self.parseJSON(self.parseMikrograd(markerCollection)) {
                self.solutionLogger.logSolution(solution, taskName: "Schatzkarte")
            }
        }
    }
    
    func parseMikrograd(markerColl: Array<[NSObject: AnyObject]>) -> Array<[NSObject: AnyObject]> {
        var markerCollection = Array<[NSObject: AnyObject]>()
        
        for val in markerColl {
            let latitude: Double = val["lat"] as Double * pow(10, 6)
            let longitude: Double = val["lon"] as Double * pow(10, 6)
            
            let marker: [NSObject: AnyObject] = ["lat": latitude, "lon": longitude]
            
            markerCollection.append(marker)
        }
        
        return markerCollection
    }
    
    func parseJSON(obj: AnyObject) -> String? {
        var err: NSError?
        let data: NSData! = NSJSONSerialization.dataWithJSONObject(obj,options: NSJSONWritingOptions(0), error: &err)
        if err != nil {
            println(err)
            return nil
        } else {
            return NSString(data: data, encoding: NSUTF8StringEncoding)!
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

