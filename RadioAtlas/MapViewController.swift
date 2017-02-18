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


class MapViewController: UIViewController, MKMapViewDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    //Outlets
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet weak var volumeControl: UISlider!
    // Properties
    
    var appDelegate: AppDelegate!
    var client = Client.sharedInstance()
    var radioInfo = [RadioInfo]()
    var locationManager = CLLocationManager()
    var favoriteStation = [Station]()
    var favorite : Bool = false
    var annotations = [MKAnnotation]()
    @IBOutlet weak var playAndPause: UIButton!
    
    @IBOutlet weak var favoriteButton: UIButton!
    // Core Data Convenience. Useful for fetching, adding and saving objects
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
   // var music = Music.sharedInstance()

    
    // Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setNetworkActivityIndicatorVisible(visible: true)

              mapView.delegate = self
                self.addAnnotation()
    }
    
  
    func determineCurrentLocation() {
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
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 10.01, longitudeDelta: 10.01))
        
        mapView.setRegion(region, animated: true)
            }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    
    
    func addAnnotation(){
        
        client.getStations { (result, error) in
            
            
            if Reachability.isConnectedToNetwork() == true {
                
                if error == nil {
                    
                    
                    for dictionary in result!{
                        
                        
                        // Notice that the float values are being used to create CLLocationDegree values.
                        // This is a version of the Double type.
                        
                        if dictionary.latitude != nil   && dictionary.longitude != nil && dictionary.streamUrl != nil {
                            
                            
                            /* Get the lat and lon values to create a coordinate */
                            let upperBound = 0.09
                            let lowerBound = 0.01
                            
                            let range = upperBound - lowerBound
                            var randomValue = (Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)) * range + lowerBound
                            let  y = Double(round(randomValue * 100000)/100000)
                            
                             print(CLLocationDegrees(dictionary.latitude!))
                             print(CLLocationDegrees(dictionary.longitude!))
                            
                            let lat = CLLocationDegrees(dictionary.latitude!) + CLLocationDegrees(y)
                            let lon = CLLocationDegrees(dictionary.longitude!) + CLLocationDegrees(y)
                            print(lat)
                            print(lon)
                            
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
                            
                            let annotation = PinAnnotation(id: id!, name: name!, streamUrl:streamUrl!, websiteURL: webUrl!,location: location, latitude: dictionary.latitude!, longitude: dictionary.longitude! )
                            
                            annotation.streamUrl = streamUrl
                            
                            
                            
                            // Finally we place the annotation in an array of annotations.

                            self.annotations.append(annotation)
                        }
                        
                        
                        print("The annotations are: ", self.annotations)
                        
                                
                        // When the array is complete, we add the annotations to the map.
                        self.mapView.addAnnotations(self.annotations)
                        
                    }
                    
                    self.appDelegate.setNetworkActivityIndicatorVisible(visible: false)
                    
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
    

    
    func tappedOnMap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TableView") as! TableView
        vc.modalPresentationStyle = .popover
        // vc.preferredContentSize = CGSizeMake(200, 150)
        
        if let popoverController = vc.popoverPresentationController {
            // Create popover at tapped point.
            popoverController.delegate = self
            //   popoverController.sourceRect = CGRectMake(location.x, location.y, 20, 10)
            popoverController.sourceView = self.view
            self.present(vc, animated: true, completion: nil)
        }
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
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation
        {
            return nil
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
    
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        for annotation in annotations {
            
            if (annotation.coordinate.latitude == view.annotation?.coordinate.latitude) && (annotation.coordinate.longitude == view.annotation?.coordinate.latitude) {
                let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tappedOnMap:"))
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(tapGesture)
                print("This coordinate already exist")
                
            }
            
        }
        
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        
         view.image = UIImage(named: "pinView")
        appDelegate.setNetworkActivityIndicatorVisible(visible: false)
        
        sharedContext.perform {
            
            
            let annotationView = view.annotation as! PinAnnotation
            
            
            if (self.checkIfExists(name: annotationView.name))
            {
                view.leftCalloutAccessoryView = nil
            }
            
            if let toOpen = annotationView.streamUrl {
                
                print("Music stream playing",toOpen)
               
                Music.sharedInstance.musicStream(music: toOpen)
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
            print(result)
            
            for found in result {
                print((found as! Station).name)
                if ((found as! Station).name == name) {
                    print(name)
                    
                    return true
                }
                
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
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
                    return "http://" + urlString
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
    
    
    // Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "favoriteStations":
            print("segue called")
            
            let dest = segue.destination as! TableViewController
            dest.station = favoriteStation
            print("There is data in favories", dest.station)
            
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



