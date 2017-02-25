//
//  MapViewController.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import AVFoundation
import CoreLocation


extension MKMapView {
    
    // delta is the zoom factor
    // 2 will zoom out x2
    // .5 will zoom in by x2
    
    func setZoomByDelta(delta: Double, animated: Bool, center: CLLocationCoordinate2D) {
        var _region = region;
        var _span = region.span;
        _span.latitudeDelta *= delta;
        _span.longitudeDelta *= delta;
        _region.span = _span;
        _region.center = center
        
        setRegion(_region, animated: animated)
    }
}

struct PlayNext {
    var name : String
    var city : String
    var country : String
    var stationData : String
}



class MapViewController: UIViewController, MKMapViewDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate,RadioAVPlayerItemDelegate {
    
    //Outlets
    @IBOutlet weak var favorite: UIBarButtonItem!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var btnWorld: UIButton!
    @IBOutlet weak var progressMessage: UITextView!
    @IBOutlet weak var volumeControl: UISlider!
    // Properties
    
    var appDelegate: AppDelegate!
    var client = Client.sharedInstance()
    var radioInfo = [RadioInfo]()
    var locationManager = CLLocationManager()
    var favoriteStation = [Station]()
   // var favorite : Bool = false
    var annotations = [MKAnnotation]()
    var mapViewZoomStepperValue: Double = -1.0
    private var playerItemContext = 0

    
    
    
    let clusteringManager = FBClusteringManager()
    let configuration = FBAnnotationClusterViewConfiguration.default()
    //var userLoc : CLLocation = 0.0
    var playerItem : AVPlayerItem? = nil
    var nowPlayingData : String = ""
    var playNextData : String = ""
    
    var previousStationData : String = ""
    

    
    @IBOutlet weak var playAndPause: UIButton!
    
  

    
    
    @IBOutlet weak var favoriteButton: UIButton!
    // Core Data Convenience. Useful for fetching, adding and saving objects
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
   // var music = Music.sharedInstance()

    
    // Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.showsPointsOfInterest = true
      // navigationController?.istrans
        initializations()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
         navigationController?.isToolbarHidden = true
    }
    
    
    func initializations() {
        
        
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setNetworkActivityIndicatorVisible(visible: true)
        
        setWorldRegion(animated: false)
        mapView.delegate = self
        self.addAnnotation()
 
        
        
    }
    
    func setWorldRegion(animated: Bool) {
        var worldRegion : MKCoordinateRegion
        worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld)
        mapView.setRegion(worldRegion,animated: animated)

    }

    
   
  
    func determineCurrentLocation() {
        
        //Paint the annotations by setting region
        setWorldRegion(animated: false)
        activityIndicator.isHidden = true
        progressMessage.isHidden = true
        
        locationManager = CLLocationManager()
        
        // For use in foreground
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations.first! as CLLocation
        //userLoc = userLocation
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
         let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 4.075, longitudeDelta: 4.075))
        
        //mapView.setRegion(region, animated: true)
        
       
            }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    
    @IBAction func btnWorldClick(_ sender: Any) {
        
        setWorldRegion(animated: true)
        
    }
    
    func addAnnotation(){
        
        var closestStation : String
        var distanceToStation : CLLocationDegrees
        distanceToStation = 200.0
        
        client.getStations { (result, error) in
            
            
            if Reachability.isConnectedToNetwork() == true {
                
                if error == nil {
                    
                    //RE* Begin
                    
                    var counter : Int
                    counter = 0
                    for dictionary in result!{
                        
                        counter = counter + 1
                        
                        
                        // Notice that the float values are being used to create CLLocationDegree values.
                        // This is a version of the Double type.
                        
                        if dictionary.latitude != nil   && dictionary.longitude != nil && dictionary.streamUrl != nil {
                            
                            
                            /* Get the lat and lon values to create a coordinate */
                            let upperBound = 0.09
                            let lowerBound = 0.01
                            var lat_temp : CLLocationDegrees
                            var lon_temp : CLLocationDegrees
                            
                            
                            
                            let range = upperBound - lowerBound
                            var randomValue = (Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)) * range + lowerBound
                            let  y = Double(round(randomValue * 100000)/100000)
                            
                            // print(CLLocationDegrees(dictionary.latitude!))
                            // print(CLLocationDegrees(dictionary.longitude!))
                            
                            if (counter % 8 == 0 || counter % 9 == 0) {
                                lat_temp = CLLocationDegrees(dictionary.latitude!) + CLLocationDegrees(y)
                                lon_temp = CLLocationDegrees(dictionary.longitude!) + CLLocationDegrees(y)
                            }
                            else if (counter % 6 == 0 || counter % 7 == 0) {
                                lat_temp = CLLocationDegrees(dictionary.latitude!) - CLLocationDegrees(y)
                                lon_temp = CLLocationDegrees(dictionary.longitude!) - CLLocationDegrees(y)
                            }
                            else if (counter % 4 == 0 || counter % 5 == 0) {
                                lat_temp = CLLocationDegrees(dictionary.latitude!) - CLLocationDegrees(y)
                                lon_temp = CLLocationDegrees(dictionary.longitude!) + CLLocationDegrees(y)
                            }
                            else {
                                lat_temp = CLLocationDegrees(dictionary.latitude!) + CLLocationDegrees(y)
                                lon_temp = CLLocationDegrees(dictionary.longitude!) - CLLocationDegrees(y)
                            }
                      
                            
                            let lat = lat_temp
                            let lon = lon_temp
                            
                            //RE* End
                            
                            // print(lat)
                            // print(lon)
                            
                            let name = dictionary.name
                            let city = dictionary.city
                            let state = dictionary.state
                            let country = dictionary.country
                            let streamUrl = dictionary.streamUrl
                            let webUrl = dictionary.websiteURL
                            let id = dictionary.id
                            var location: String!
                            
                            if state != "" && state != nil {
                                
                                location = city! + ", " + state! +  ", " + country!
                                
                            } else {
                                
                                location = city! +  ", " + country!
                                
                            }
                            
                            // Here we create the annotation and set its coordiate, title, and subtitle properties
                            
                            let annotation = PinAnnotation(id: id!, name: name!, streamUrl:streamUrl!, websiteURL: webUrl!,location: location, latitude: lat, longitude: lon )
                            
                            annotation.streamUrl = streamUrl
                            
                            
                            
                            // Finally we place the annotation in an array of annotations.
                            
                            self.annotations.append(annotation)
                            
                            //RE* begin
                            DispatchQueue.main.async() {
                                
                                //self.mapView.addAnnotation(annotation)
                                self.progressMessage.text = "Loading " + String(counter) + " Radio Stations"
                                
                            }
                            //RE* end
                        }
                        
                        
                        // print("The annotations are: ", self.annotations)
                        
                        
                        // When the array is complete, we add the annotations to the map.
                        //self.mapView.addAnnotations(self.annotations)
                        
                    }
                    
                    //RE* begin
                    DispatchQueue.main.async() {
                        
                        self.clusteringManager.add(annotations: self.annotations)
                        self.clusteringManager.delegate = self
                        self.appDelegate.setNetworkActivityIndicatorVisible(visible: false)
                        self.determineCurrentLocation()
                        
                    }
                    
                    
                  
                    //RE* end
                    
                    
                } else {
                    
                    print("Map download failed")
                    
                    let alertTitle = "Map Download error"
                    let alertMessage = "Map could not download"
                    let actionTitle = "OK"
                    self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                    
                }
                
            } else {
                
                let alertTitle = "No Internet Connection"
                let alertMessage = "Make sure your device is connected to the internet"
                let actionTitle = "OK"
                self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                
            }
            
        }
    }

    
    
    func playMusic(music: String) {
        
        previousStationData = ""
        
        statusUpdate(message: "Tuning ..")
        
        
        if (playerItem != nil)
        {
            removeObservers(playerItem: playerItem!)
        }
        
         playerItem = RadioAVPlayerItem(url: NSURL(string: music) as! URL)
         addObservers(playerItem: playerItem!)
        
        Music.sharedInstance.musicStream(playerItem: playerItem! as! RadioAVPlayerItem)
        self.playAndPause.setImage(UIImage(named: "pause"), for: .normal)
        
    }
    
    func removeObservers(playerItem: AVPlayerItem) {
        
        playerItem.removeObserver(self, forKeyPath: "timedMetadata")
        playerItem.removeObserver(self, forKeyPath:"status")
    }
    
    func addObservers(playerItem: AVPlayerItem) {
        
        
        playerItem.addObserver(self,
                                //  forKeyPath: #keyPath(AVPlayerItem.status),
            forKeyPath: "timedMetadata",
            options: [.old, .new],
            //options: .new,
            //context: &self.playerItemContext)
            context: nil)
        
        
        playerItem.addObserver(self,
                                // forKeyPath: #keyPath(AVPlayerItem.status),
            forKeyPath: "status",
            options: [.old, .new],
            context: nil)
        
    }
    
    func removePlayerItemObserver(playerItem: RadioAVPlayerItem)
    {
        playerItem.removeObserver(self, forKeyPath: "timedMetadata")
        playerItem.removeObserver(self, forKeyPath: "status")
    }

    
    
    @IBAction func playAndPauseAction(_ sender: Any) {
        
        if Music.sharedInstance.isPlaying == true {
            
            Music.sharedInstance.audioPlayer.pause()
            playAndPause.setImage(UIImage(named: "play"), for: .normal)
            Music.sharedInstance.isPlaying = false
            appDelegate.setNetworkActivityIndicatorVisible(visible: false)
            
        } else if Music.sharedInstance.isPlaying == false {
            
            Music.sharedInstance.audioPlayer.play()
            playAndPause.setImage(UIImage(named: "pause"), for: .normal)
            Music.sharedInstance.isPlaying = true
            appDelegate.setNetworkActivityIndicatorVisible(visible: true)
        }
    }
    
    
 
    @IBAction func volumeControlAction(_ sender: Any) {
        
        let currentValue = volumeControl.value
        Music.sharedInstance.audioPlayer?.volume = currentValue
    }
    
 
    func zoomInPinAnnotationLocation(targetMapViewName : MKMapView?, delta: Double)
    {
        var region: MKCoordinateRegion = targetMapViewName!.region
        region.span.latitudeDelta /= delta
        region.span.longitudeDelta /= delta
        targetMapViewName!.region = region
        
    }
    func zoomOutPinAnnotationLocation(targetMapViewName : MKMapView?,delta: Double)
    {
        var region: MKCoordinateRegion = targetMapViewName!.region
        region.span.latitudeDelta *= delta
        region.span.longitudeDelta *= delta
        targetMapViewName!.region = region
    }

    
   

    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation is MKUserLocation
        {
            return nil
        }
        
        if annotation is FBAnnotationCluster {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if clusterView == nil {
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configuration)
            } else {
                clusterView?.annotation = annotation
            }
            
            return clusterView
            
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")

        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = true
            
            
            //Left Accesory View
            
            let button = UIButton(type: .detailDisclosure)
            button.backgroundRect(forBounds: CGRect(x: 0, y: 0, width: 60, height: 60))
            button.setImage(UIImage(named: "favorite3"), for: .normal)
            annotationView?.leftCalloutAccessoryView = button
            
            // Right accessory view
            
            let button1 = UIButton(type: .detailDisclosure)
            button1.backgroundRect(forBounds: CGRect(x: 0, y: 0, width: 60, height: 60))
            button1.setImage(UIImage(named: "open3"), for: .normal)
            annotationView?.rightCalloutAccessoryView = button1
            
            
        }else{
            annotationView?.annotation = annotation
        }

        
       if checkIfExists(name:annotation.title!!){
            
            annotationView?.image = UIImage(named: "favorite")
        }
        
        else {
        annotationView?.image = UIImage(named: "mappoint")
            
        }
        return annotationView
       
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
            
            DispatchQueue.main.async {
                self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
            }
        }
        
    }
    
    func findClosestStation(annotations:[MKAnnotation], coordinate:CLLocationCoordinate2D) -> MKAnnotation {
        var closest : MKAnnotation = annotations[0]
        
        //Max possible distance between 2 points
        var distance = CLLocationDistance(20036332.8)
        
        
        for annotation in annotations {
            
            let annotationCoord : CLLocation = CLLocation(latitude: annotation.coordinate.latitude,longitude: annotation.coordinate.longitude)
            let clusterCoord : CLLocation = CLLocation(latitude: coordinate.latitude,longitude: coordinate.longitude)
            
            if (clusterCoord.distance(from: annotationCoord) <= distance) {
                closest = annotation
                distance = clusterCoord.distance(from: annotationCoord)
            }
            
        }
        
        return closest
    }
  
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        
        if view is FBAnnotationClusterView {
            //let annotationCluster = view.annotation as! FBAnnotation
            
            var clusterAnnotations : [MKAnnotation]
            var closestStation : MKAnnotation
            
            let cView = view as! FBAnnotationClusterView
            clusterAnnotations = cView.getClusterAnnotations()
            closestStation = findClosestStation(annotations: cView.getClusterAnnotations(),coordinate: (cView.annotation?.coordinate)!)
     
            
            mapView.setZoomByDelta(delta: 0.03125, animated: true, center: closestStation.coordinate)
            
            let annotationView = closestStation as! PinAnnotation
            
            if (self.checkIfExists(name: annotationView.name))
            {
                view.leftCalloutAccessoryView = nil
            }
            
            mapView.addAnnotation(closestStation)
            mapView.selectAnnotation(closestStation, animated: true)
            
            
            return
            
        }
        
        
        
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        
         view.image = UIImage(named: "pinView")
        appDelegate.setNetworkActivityIndicatorVisible(visible: false)
        
        sharedContext.perform {
            
            
            let annotation = view.annotation as! PinAnnotation
            
            
            if (self.checkIfExists(name: annotation.name))
            {
                view.leftCalloutAccessoryView = nil
            }
            
            if let toOpen = annotation.streamUrl {
                
              //  print("Music stream playing",toOpen)
                
                self.playNextData = annotation.name
                if (annotation.location != nil) {
                   self.playNextData + " ∞∞ " + annotation.location
                }
                self.playMusic(music: toOpen)
            }
            
        }
        
    }
    
    
    func checkIfExists(name:String) -> Bool {
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Station", in: self.sharedContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.sharedContext.fetch(fetchRequest)
            //print(result)
            
            for found in result {
              //  print((found as! Station).name)
                if ((found as! Station).name == name) {
                 //   print(name)
                    
                    return true
                }
                
            }
            
        } catch {
            let fetchError = error as NSError
          //  print(fetchError)
        }
        
        return false
    }
    
    func verifyUrl (urlString: String?) -> String {
        //Check for nil
        
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                
                
                let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
                let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
                if (predicate.evaluate(with: urlString) == false)
                {
                    //return "http://" + urlString
                    return urlString

                }
                
            }
        }
        return urlString!
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotationView = view.annotation as! PinAnnotation
        
        if control == view.rightCalloutAccessoryView {
            
            if annotationView.websiteURL != nil {
                if let toOpen = annotationView.websiteURL{
                    var urlString = verifyUrl(urlString: toOpen)

                    UIApplication.shared.open(NSURL(string: urlString)! as URL, options: [:], completionHandler: nil)
                    
                }
            } else {
                let alertTitle = "No Website url"
                let alertMessage = "There is no website url for this station"
                let actionTitle = "OK"
                self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                
                
            }
        } else {
            
            if control == view.leftCalloutAccessoryView {
                
                    
                    //Data is in this case the name of the entity
                    do {
                        
                        
                        if (self.checkIfExists(name: annotationView.name))
                        {
                            let alertTitle = "Favorite Exists"
                            let alertMessage = "This station is already in your favorites"
                            let actionTitle = "OK"
                            self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                        }
                        else
                        {
                            let stationDetails   = Station(id: annotationView.id,name: annotationView.name, streamUrl: annotationView.streamUrl, websiteURL: annotationView.websiteURL, latitude: annotationView.latitude, longitude: annotationView.longitude, location: annotationView.location, context: self.sharedContext)
                            self.favoriteStation = [stationDetails]

                            view.image = UIImage(named: "favorite")
                            CoreDataStackManager.sharedInstance().saveContext()
                            
                            //lighten the favorites icon
                            view.leftCalloutAccessoryView = nil
                            
                                                        
                        }
                        
                        
                }
                
            }
            
        }
        
        
    }
    
    //print details of playing stream
//    @objc
 //   override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    
    
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
     {
        
       
        
        var data: AVPlayerItem = object as! AVPlayerItem
        var newData : String = ""
        
        
       if (keyPath == "timedMetadata")
       {
        
            for item in data.timedMetadata! as [AVMetadataItem] {
                if (item != nil)
                {
                    newData.append(" ∞∞ ")
                    newData.append(item.value!.description)
                    
                }
            }
        
        if (newData != nil && newData != previousStationData) {
            previousStationData = newData
            nowPlayingData = playNextData + newData
            print(nowPlayingData)
        }
        
        }
        else if (keyPath == "status")
       {
        
            let playerItem:AVPlayerItem = object as! AVPlayerItem
        
        
        if playerItem.status ==  AVPlayerItemStatus.readyToPlay{
            statusUpdate(message: "Playing ..")
        } else if playerItem.status == AVPlayerItemStatus.failed {
            statusUpdate(message: "Invalid Radio Stream ..")
        }
        
        
        }
       else {
        return
        }
    }
    
    func statusUpdate(message: String) {
        
         NSLog(message)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "favoriteStations":
            print("segue called")
            
            let dest = segue.destination as! TableViewController
            dest.station = favoriteStation
          //  print("There is data in favories", dest.station)
            
        default:
            print("Unknown segue")
        }
        
    }
    // Error help function
    func showAlert(_ alertTitle: String, alertMessage: String, actionTitle: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
  

    
}



extension MapViewController : FBClusteringManagerDelegate {
    
    func cellSizeFactor(forCoordinator coordinator:FBClusteringManager) -> CGFloat {
        return 1.0
    }
}


