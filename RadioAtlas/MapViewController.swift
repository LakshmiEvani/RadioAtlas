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
import MarqueeLabel
import Font_Awesome_Swift


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
    
    func changeCenter(center: CLLocationCoordinate2D) {
        
        region.center = center
    }
    
    func longitudeToPixelSpaceX(longitude : Double) -> Double {
        let mercadorRadius : Double =  85445659.44705395
        let mercadorOffset : Double = 268435456
        
        return round(mercadorOffset + mercadorRadius * longitude * M_PI / 180.0)
    }
    
    func getZoomLevel() -> Double {
        let mercadorRadius : Double =  85445659.44705395
        let mercadorOffset : Double = 268435456
        
        let centerPixelX = self.longitudeToPixelSpaceX(longitude: centerCoordinate.longitude);
        let centerPixelY = self.longitudeToPixelSpaceX(longitude: centerCoordinate.latitude);
        
    
        
      
        let maxGoogleLevels = log2(MKMapSizeWorld.width / 256.0)
        
        let longitudeDelta : CLLocationDegrees = self.region.span.longitudeDelta
        let mapWidthInPixes = self.bounds.size.width
        //print("longitudeDelta: ", longitudeDelta)
        
        let zoomScale = longitudeDelta * mercadorRadius * M_PI / (180.0 * Double(mapWidthInPixes))
        var zoomer  = ceil(maxGoogleLevels - log2(zoomScale))
        
        if (zoomer < 0 ) {
            zoomer = 0
        }
            
        return zoomer
        
    }
}

extension UIImage {
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


class MapViewController: UIViewController, MKMapViewDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate,RadioAVPlayerItemDelegate,RadioAVPlayerDelegate ,UIGestureRecognizerDelegate, TableViewControllerDelegate {
    
    //Outlets
    @IBOutlet weak var favorite: UIBarButtonItem!
    
    @IBOutlet weak var btnSettings: UIBarButtonItem!
    @IBOutlet weak var centerFocus: UIImageView!
    
    @IBOutlet weak var fastForward: UIBarButtonItem!
    
    @IBOutlet weak var reWind: UIBarButtonItem!
    @IBOutlet weak var playAndPauseBar: UIBarButtonItem!
    
    @IBOutlet var mapView: MKMapView!
    // @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var btnZoomIn: UIBarButtonItem!
    
    @IBOutlet weak var barBtnWorld: UIBarButtonItem!
    @IBOutlet weak var nowPlayingLabel: MarqueeLabel!
    
    // @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var btnZoomOut: UIBarButtonItem!
    
    @IBOutlet weak var progressMessage: UITextView!
    @IBOutlet weak var volumeControl: UISlider!
    
    @IBOutlet weak var tunerToggle: UISwitch!
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
    private var isUpdating = false
    var isMapLoaded = false
    var playAllTimer: Timer!
    
    
    var regionWillChangeAnimatedCalled : Bool = false
    var regionChangedBecauseAnnotationSelected : Bool = false
    var selectedFromRegionChange : Bool = false
    var skipRegionAnnotationSelection : Bool = false
    var skipRegionClustering : Bool = false
    var mapDragged : Bool = false
   
    var currentlyPlaying: MKAnnotation? = nil
    var playNext: PinAnnotation? = nil
    var tunerTurnedOff: Bool = false
    private let PlayerStatusObservingContext = UnsafeMutablePointer<Int>(bitPattern: 1)
    
    @IBOutlet weak var mapViewZoomStepper: UIStepper!
    @IBOutlet weak var tunerLabel: UILabel!
    //var mapViewZoomStepperValue: Double = -1.0
    
    
    let clusteringManager = FBClusteringManager()
    let configuration = FBAnnotationClusterViewConfiguration.default()
    let DARK_FOREGROUND_COLOR = UIColor(red:0.04, green:0.29, blue:0.60, alpha:1.0)
    let DISABLED_COLOR = UIColor.init(white: 0.8, alpha: 1.0)
    let LIGHT_BACKGROUND_COLOR = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
    let TOOLBAR_BUTTON_SIZE : CGFloat = 25
    let PLAY_BUTTON_SIZE : CGFloat = 35
    let MAX_ZOOM_OUT = 18.0
    var prevZoomLevel : Double = 18.0
    let MAX_ZOOM_IN = 5.0
    let PLAY_ALL_MODE : Bool = false
    let TIMER_INTERVAL  = 0.5
    //var tunerMode : Bool = false
    
    
    //var userLoc : CLLocation = 0.0
    var playerItem : AVPlayerItem? = nil
    //var nowPlayingData : String = ""
    var playNextData : String = ""
    
    
    var previousStationData : String = ""
    var prevStationHistory = [PinAnnotation]()
    var nextStationHistory = [PinAnnotation]()
    
    
    // @IBOutlet weak var playAndPause: UIButton!
    
    @IBOutlet weak var favoriteButton: UIButton!
    // Core Data Convenience. Useful for fetching, adding and saving objects
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUIAttributes()
        initializations()
        
    }
    
    func invalidateTimer()
    {
        if (playAllTimer != nil) {
            playAllTimer.invalidate()
        }
        
    }
    
    deinit {
        invalidateTimer()
    }
    
    
    func setUIAttributes()
    {
        //mapView.mapType = MKMapType.hybrid
        mapView.showsPointsOfInterest = true
        
        
        
        fastForward.setFAIcon(icon: .FAStepForward, iconSize: TOOLBAR_BUTTON_SIZE)
        fastForward.tintColor = DARK_FOREGROUND_COLOR
        fastForward.isEnabled = false
        
        
        fastForward.setTitlePositionAdjustment(UIOffset(horizontal: 10, vertical: 100), for: UIBarMetrics.default)
        
        reWind.setFAIcon(icon: .FAStepBackward, iconSize: TOOLBAR_BUTTON_SIZE)
        reWind.tintColor = DARK_FOREGROUND_COLOR
        //*reWind.isEnabled = false
        
        //reWind.setTitleTextAttributes([NSForegroundColorAttributeName:DISABLED_COLOR], for: UIControlState.disabled)
        
        
        // reWind.imageInsets = UIEdgeInsets.init(top: 0, left: -15, bottom: -20, right: 0)
        
        playAndPauseBar.setFAIcon(icon: .FAPlay, iconSize: PLAY_BUTTON_SIZE)
        playAndPauseBar.tintColor = DARK_FOREGROUND_COLOR
        playAndPauseBar.isEnabled = false
        
        
        barBtnWorld.setFAIcon(icon: .FAGlobe, iconSize: TOOLBAR_BUTTON_SIZE)
        barBtnWorld.tintColor = DARK_FOREGROUND_COLOR
        barBtnWorld.isEnabled = false
        
        favorite.setFAIcon(icon: .FAHeart, iconSize: TOOLBAR_BUTTON_SIZE)
        favorite.tintColor = DARK_FOREGROUND_COLOR
        
        
        btnZoomIn.setFAIcon(icon: .FASearchPlus, iconSize: TOOLBAR_BUTTON_SIZE)
        btnZoomIn.tintColor = DARK_FOREGROUND_COLOR
        
        btnZoomOut.setFAIcon(icon: .FASearchMinus, iconSize: TOOLBAR_BUTTON_SIZE)
        btnZoomOut.tintColor = DARK_FOREGROUND_COLOR
        btnZoomOut.isEnabled = false
        
        tunerToggle.backgroundColor = DARK_FOREGROUND_COLOR
        tunerToggle.layer.cornerRadius = 16.0
        
        btnSettings.setFAIcon(icon: .FAInfoCircle, iconSize: TOOLBAR_BUTTON_SIZE)
        btnSettings.tintColor = DARK_FOREGROUND_COLOR
        btnSettings.isEnabled = true
        
        /*
         let button = UIButton(type: .custom)
         button.titleLabel?.numberOfLines = 2
         button.titleLabel?.lineBreakMode = .byWordWrapping
         button.titleLabel?.textColor = DARK_FOREGROUND_COLOR
         button.setTitle("Tuner\nOn", for: .normal)
         button.sizeToFit()
         
         btnMode.customView = button
         */
        // btnMode.setFAIcon(icon: .FADotCircleO, iconSize: TOOLBAR_BUTTON_SIZE)
        
        
        //btnMode.tintColor = DARK_FOREGROUND_COLOR
        
        
        let btnFont = UIFont.boldSystemFont(ofSize: 14)
        
        //btnMode.setTitleTextAttributes([NSFontAttributeName : btnFont], for: .normal)
        //btnMode.setBackgroundVerticalPositionAdjustment(-200, for: .default)
        //btnMode.setBackgroundImage(UIImage().makeImageWithColorAndSize(color:DARK_FOREGROUND_COLOR, size: CGSize(width: 1, height: 1)), for: .normal, barMetrics: .default)
        // btnMode.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: 30), for: .default)
        
        nowPlayingLabel.backgroundColor = self.LIGHT_BACKGROUND_COLOR
        
        //fastForward.setFAText(prefixText: "testting", icon: nil, postfixText: "", size: 20)
        
        
        //btnNext.isHidden = true
        // payAndPauseBar.isOpaque = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        // navigationController?.isToolbarHidden = true
    }
    
    @IBAction func playAndPauseBarAction(_ sender: Any) {
        
        if Music.sharedInstance.isPlaying == true {
            
            if (Music.sharedInstance.audioPlayer != nil) {
                
                Music.sharedInstance.audioPlayer.pause()
                playPauseImageUpdate(play: true)
                Music.sharedInstance.isPlaying = false
                appDelegate.setNetworkActivityIndicatorVisible(visible: false)
            }
            
        } else if Music.sharedInstance.isPlaying == false {
            
            if (Music.sharedInstance.audioPlayer != nil) {
                Music.sharedInstance.audioPlayer.play()
                playPauseImageUpdate(play: false)
                Music.sharedInstance.isPlaying = true
                appDelegate.setNetworkActivityIndicatorVisible(visible: true)
            }
        }
    }
    
    
    func initializations() {
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setNetworkActivityIndicatorVisible(visible: true)
        
        
        //setWorldRegion(animated: false)
        mapView.delegate = self
        self.addAnnotation()
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(gestureRecognizer:)))
        mapDragRecognizer.delegate = self
        self.mapView.addGestureRecognizer(mapDragRecognizer)
        
        
        
    }
    
    func addPlayerObservers(player: RadioAVPlayer) {
        
        player.addObserver(self,
                           forKeyPath: "currentItem.status",
                           options: [.new, .initial],
                           context: nil)
        
        player.addObserver(self,
                           forKeyPath: "currentItem.duration",
                           context: nil)
        
        player.addObserver(self,
                           forKeyPath: "rate",
                           context: nil)
        
        
    }
    
    func setWorldRegion(animated: Bool, changeCenter:Bool=false) {
        var worldRegion : MKCoordinateRegion
        worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld)
        skipRegionAnnotationSelection = true
        //set the world zoom level
        self.prevZoomLevel == MAX_ZOOM_OUT
        
        if (changeCenter && currentlyPlaying != nil)
        {
            worldRegion.center = (currentlyPlaying?.coordinate)!
        }
        
        mapView.setRegion(worldRegion,animated: animated)
        
        
        
    }
    
    
    @IBAction func btnZoomInClick(_ sender: Any) {
        
        regionChangedBecauseAnnotationSelected = false
        zoomInPinAnnotationLocation(targetMapViewName: mapView, delta: 2.5)
        
        
        
    }
    
    @IBAction func btnZoomOutClick(_ sender: Any) {
        
        regionChangedBecauseAnnotationSelected = false
        zoomOutPinAnnotationLocation(targetMapViewName: mapView, delta: 2.5)
        btnZoomIn.isEnabled = true
    }
    
    func getZoomLevel() -> Double {
        let mapBoundsWidth = Double(self.mapView.bounds.size.width)
        let mapRectWidth = self.mapView.visibleMapRect.size.width
        let scale = mapBoundsWidth / mapRectWidth
        let zoomLevel : Double = abs(ceil(log2(scale)))
        
        return zoomLevel
        
    }
    
    
    func zoomInPinAnnotationLocation(targetMapViewName : MKMapView?, delta: Double)
    {
        
        //if zoom level just above  min  zoom
        if (getZoomLevel() <= MAX_ZOOM_IN) {
            
            //No more Zoom in allowed
            btnZoomIn.isEnabled = false
            
        } else {
            
            
            var region: MKCoordinateRegion = targetMapViewName!.region
            region.span.latitudeDelta /= delta
            region.span.longitudeDelta /= delta
            if (currentlyPlaying != nil) {
                region.center = (currentlyPlaying?.coordinate)!
            }
            targetMapViewName!.region = region
        }
        
        btnZoomOut.isEnabled = true
        barBtnWorld.isEnabled = true
        
    }
    
    func checkZoomOutButtonStatus() -> Bool {
        
        var status : Bool = false
        
        if (getZoomLevel() >= MAX_ZOOM_OUT - 1 ) {
            //set to world region
            setWorldRegion(animated: true, changeCenter: true)
            btnZoomOut.isEnabled = false
            barBtnWorld.isEnabled = false
            status = true
            
        }
        
        return status
        
    }
    
    @IBAction func tunerToggleChange(_ sender: Any) {
        let tunerON = (sender as! UISwitch).isOn
        
        if (tunerON) {
            turnONTuner()
        }
        else {
            centerFocus.isHidden = true
            tunerLabel.text = "Tuner OFF"
            
            //user explicitly turned off tuner
            tunerTurnedOff = true
        }
    }
    
    func zoomOutPinAnnotationLocation(targetMapViewName : MKMapView?,delta: Double)
    {
        //if zoom level just below max zoom
        if (checkZoomOutButtonStatus() ) {
        }
        else {
            var region: MKCoordinateRegion = targetMapViewName!.region
            region.span.latitudeDelta *= delta
            region.span.longitudeDelta *= delta
            if (currentlyPlaying != nil) {
                region.center = (currentlyPlaying?.coordinate)!
            }
            
            targetMapViewName!.region = region
            //checkZoomOutButtonStatus()
        }
        
        btnZoomIn.isEnabled = true
        
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    
    
    
    func postInitialization() {
        
        //Paint the annotations by setting region
        isMapLoaded = true
        
        
        nowPlayingLabel.text = "Tap dots to play. Turn Tuner ON to play station nearest to map center."
        nowPlayingLabel.triggerScrollStart()
        
        setWorldRegion(animated: false)
        
        activityIndicator.isHidden = true
        progressMessage.isHidden = true
        
        //btnZoomOut.isEnabled = true
        // barBtnWorld.isEnabled = true
        
        if (tunerToggle.isOn) {
            centerFocus.isHidden = false
        }
        
        
        //*locationManager = CLLocationManager()
        
        // For use in foreground
        //*self.locationManager.requestAlwaysAuthorization()
        //*self.locationManager.requestWhenInUseAuthorization()
        //*locationManager.delegate = self
        //*locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //*if CLLocationManager.locationServicesEnabled() {
        //*    locationManager.requestLocation()
            
        //*}
    }
    /*
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations.first! as CLLocation
        //userLoc = userLocation
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 4.075, longitudeDelta: 4.075))
        
        
        //mapView.setRegion(region, animated: true)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    } */

    
   
    var annIndex = 1
    
    func runTimedCode() {
        let anns = self.clusteringManager.allAnnotations()
        if (annIndex <= anns.count) {
            //timedPlay(url: (anns[annIndex - 1] as! PinAnnotation).streamUrl)
            //playFromAnnotation(annotation: anns[annIndex-1] as! PinAnnotation)
            let station = anns[annIndex-1]
            
            mapView.addAnnotation(station)
            mapView.selectAnnotation(station, animated: true)
            annIndex+=1
        }
    }
    
    var audioPlayer : AVAudioPlayer!
    var playAudioRepeatedly = true
    
    func playTunerAudio()
    {
        // set URL of the sound
        let soundURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "RadioTuner", ofType: "m4a")!)
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL as URL)
            audioPlayer.delegate = self
            
            if (audioPlayer!.prepareToPlay())
            {
                audioPlayer!.play()
            }
        }
        catch
        { }
    }
    
    func stopTunerAudio() {
        if (audioPlayer != nil) {
            audioPlayer.stop()
        }
        
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
       // if (playAudioRepeatedly)
       // {
            audioPlayer!.play()
       // }
    }
    
    

    
    @IBAction func barBtnWorldClick(_ sender: Any) {
        
        if (PLAY_ALL_MODE) {
            //tunerToggle.isOn = true
            playAllTimer = Timer.scheduledTimer(timeInterval: TimeInterval(TIMER_INTERVAL), target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            
            
        }
        else {
            
            setWorldRegion(animated: true, changeCenter: true)
            barBtnWorld.isEnabled = false
            btnZoomOut.isEnabled = false
        }
        
        
        
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
                            var lat = dictionary.latitude
                            var lon = dictionary.longitude
                            
                            self.getTempLatLon(lat: &lat!, lon: &lon!, randomizer: counter )
                            
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
                            let isValid = dictionary.isValid
                            var location: String!
                            
                            if state != "" && state != nil {
                                
                                location = city! + ", " + state! +  ", " + country!
                                
                            } else {
                                
                                location = city! +  ", " + country!
                                
                            }
                            
                            // Here we create the annotation and set its coordiate, title, and subtitle properties
                            if (isValid != "N") {
                                let annotation = PinAnnotation(id: id!, name: name!, streamUrl:streamUrl!, websiteURL: webUrl!,location: location, latitude: lat!, longitude: lon! )
                                
                                annotation.streamUrl = streamUrl
                                
                                // Finally we place the annotation in an array of annotations.
                                self.annotations.append(annotation)
                                
                            }
                           
                            //RE* begin
                            DispatchQueue.main.async() {
                                
                                //self.mapView.addAnnotation(annotation)
                                self.progressMessage.text = "Loading " + String(counter) + " Radio Stations..."
                                
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
                        // self.centerFocus.isHidden = false
                        //self.setWorldRegion(animated: true)
                        self.postInitialization()
                        
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
    
    func getTempLatLon(lat: inout Double, lon: inout Double, randomizer: Int) {
        
        let upperBound = 0.09
        let lowerBound = 0.01
        
        
        
        let range = upperBound - lowerBound
        let randomValue = (Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)) * range + lowerBound
        let  y = Double(round(randomValue * 100000)/100000)
        
        
        if (randomizer % 8 == 0 || randomizer % 9 == 0) {
            lat = CLLocationDegrees(lat) + CLLocationDegrees(y)
            lon = CLLocationDegrees(lon) + CLLocationDegrees(y)
        }
        else if (randomizer % 6 == 0 || randomizer % 7 == 0) {
            lat = CLLocationDegrees(lat) - CLLocationDegrees(y)
            lon = CLLocationDegrees(lon) - CLLocationDegrees(y)
        }
        else if (randomizer % 4 == 0 || randomizer % 5 == 0) {
            lat = CLLocationDegrees(lat) - CLLocationDegrees(y)
            lon = CLLocationDegrees(lon) + CLLocationDegrees(y)
        }
        else {
            lat = CLLocationDegrees(lat) + CLLocationDegrees(y)
            lon = CLLocationDegrees(lon) - CLLocationDegrees(y)
        }
        

        
    }
    
    func playMusic(music: String) {
        
        previousStationData = ""
        
        
        playTunerAudio()
        statusUpdate(message: "Tuning to Radio Station..")
        
        
        if (playerItem != nil)
        {
            removePlayerItemObserver(playerItem: playerItem! as! RadioAVPlayerItem)
        }

        
        if (NSURL(string: music) != nil) {
            playerItem = RadioAVPlayerItem(url: NSURL(string: music) as! URL)
            addObservers(playerItem: playerItem!)
            Music.sharedInstance.musicStream(playerItem: playerItem! as! RadioAVPlayerItem, viewController: self)
            playPauseImageUpdate(play: false)
        }
        else
        {
            handleErrorStation(streamUrl: music)
        }
        
    }
    
    
    func removePlayerObservers(player: RadioAVPlayer) {
        player.removeObserver(self, forKeyPath: "currentItem.status")
        player.removeObserver(self, forKeyPath: "currentItem.duration")
        player.removeObserver(self, forKeyPath: "rate")
        
    }
    
    @IBAction func reWindAction(_ sender: Any) {
        
        if (prevStationHistory.count > 1) {
            
            
            
            nextStationHistory.append(prevStationHistory.popLast()!)
            fastForward.isEnabled = true
            //prevStationHistory.removeLast()
            
            //prevStationHistory.popLast()!
            let annotation : PinAnnotation = prevStationHistory.last!
            

            
            let center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
            //navigate map back to the previous annotation
            playNext = annotation
            mapView.setZoomByDelta(delta: 1, animated: false, center: annotation.coordinate)
            //mapView.changeCenter(center: annotation.coordinate)
            
            
            // mapView.setRegion(region,animated: true)
            
            
            if(!tunerToggle.isOn) {
                
                dropAnnotation(annotation: annotation)
                
            }
            
            prevStationHistory.removeLast()
            
            if (prevStationHistory.count < 1)
            {
                
                //reWind.isEnabled = false
                
            }
            
            
        }
        
        
    }
    
    @IBAction func fastForwardAction(_ sender: Any) {
        
        if (nextStationHistory.count > 0) {
            
            reWind.isEnabled = true
            var annotation : PinAnnotation = nextStationHistory.popLast()!
            //prevStationHistory.append(annotation)
            //playFromAnnotation(annotation: annotation)

            let center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
            //navigate map back to the previous annotation
            playNext = annotation

            mapView.setZoomByDelta(delta: 1, animated: false, center: annotation.coordinate)
            //mapView.changeCenter(center: annotation.coordinate)
            // nextStationHistory.removeLast()
            
            if(!tunerToggle.isOn) {
                
                dropAnnotation(annotation: annotation)
                
            }
            
            
            if (nextStationHistory.count == 0)
            {
                fastForward.isEnabled = false
            }
            
            
            
        }
        
    }
    
    var observerRemoved : Bool = false
    
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
        
        observerRemoved = false
        
    }
    
    func removePlayerItemObserver(playerItem: RadioAVPlayerItem)
    {
        if (!observerRemoved) {
            playerItem.removeObserver(self, forKeyPath: "timedMetadata")
            playerItem.removeObserver(self, forKeyPath: "status")
            observerRemoved = true
        }
        
    }
    
    
    @IBAction func volumeControlAction(_ sender: Any) {
        
        let currentValue = volumeControl.value
        Music.sharedInstance.audioPlayer?.volume = currentValue
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
            var favorite_image : UIImage = UIImage(named: "favorite3")!
            
            button.setImage(favorite_image, for: .normal)
            annotationView?.leftCalloutAccessoryView = button
            
            // Right accessory view
            
            let button1 = UIButton(type: .detailDisclosure)
            button1.backgroundRect(forBounds: CGRect(x: 0, y: 0, width: 60, height: 60))
            button1.setImage(UIImage(named: "open3"), for: .normal)
            annotationView?.rightCalloutAccessoryView = button1
            
            
        }else{
            annotationView?.annotation = annotation
        }
        
        
        if checkIfFavorite(name:annotation.title!!){
            
            annotationView?.image = UIImage(named: "favorite")
        }
            
        else {
            annotationView?.image = UIImage(named: "mappoint")
            
        }
        return annotationView
        
        
    }
    
    
    
    
    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        
        if (gestureRecognizer.state == UIGestureRecognizerState.began) {
            //print("Map drag began")
            //centerFocus.isHidden = false
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
            
            // print("Map drag ended")
            mapDragged = true
            //centerFocus.isHidden = true
            
            return
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        regionWillChangeAnimatedCalled = true;
        regionChangedBecauseAnnotationSelected = false;
        
    }
    

    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if (!isMapLoaded) {
            return
        }
        
        if (isUpdating) {
            return
        }
        
        if (skipRegionClustering) {
            skipRegionClustering = false
            return
        }
        
        
        isUpdating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            let zoomLevel : Double = abs(ceil(log2(scale)))
            /*
            print ("mapBoundsWidth: " ,  mapBoundsWidth)
            print ("mapRectWidth: " ,  mapRectWidth)
            print ("scale: " ,  scale)
            print ("zoom level: " ,  zoomLevel)
            print ("new zoom level: " ,  mapView.getZoomLevel()) */
            //let zoomLevel : Double = 20.0 - abs(zoomExponent)
            
            
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
            let annotationNonClusteredArray = self.clusteringManager.allAnnotations()
            
            DispatchQueue.main.async {
                self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
            }
            
            if (self.skipRegionAnnotationSelection) {
                self.skipRegionAnnotationSelection = false
                return
            }
            
            
            //if zoomed in or out then don't select annotation
            if (self.prevZoomLevel == self.MAX_ZOOM_OUT)
            {
                self.prevZoomLevel = zoomLevel
            }
            else if (abs(zoomLevel - self.prevZoomLevel) > 2 ) // Means that map is zoomed in or out
            {
                self.prevZoomLevel = zoomLevel
                //Only if user dragged zoomed the map
                
                if (!self.regionChangedBecauseAnnotationSelected)
                {
                    return
                }
                if (self.mapDragged) {
                    self.mapDragged = false
                    return
                }
                
            }
            
            if (!self.regionChangedBecauseAnnotationSelected) {
                
                var closestStation : MKAnnotation
                if (annotationArray.count > 0)
                {
                    if (!self.tunerToggle.isOn) {
                        return
                    }
                    
                    if (self.playNext != nil)
                    {
                     closestStation = self.playNext!
                     self.playNext = nil
                    }
                    else {
                    closestStation = self.findClosestStation(annotations: annotationNonClusteredArray,coordinate: self.mapView.centerCoordinate)
                    }
                    //print(closestStation.title)
                    DispatchQueue.main.async {
                        // self.playFromAnnotation(annotation: closestStation as! PinAnnotation)
                        self.selectedFromRegionChange = true
                        self.dropAnnotation(annotation: closestStation)
                        self.selectedFromRegionChange = false
                        
                        
                        //   self.mapView.setZoomByDelta(delta: 1, animated: true, center: closestStation.coordinate)
                    }
                    
                    
                }
            }
            
        }
        isUpdating = false
        
        
    }
    
    func playFromFavorites(annotation: PinAnnotation)
    {
        turnONTuner()
        //dropAnnotation(annotation: annotation)
        if (tunerToggle.isOn) {
            playNext = annotation
            
            //let visibleAnnotations  = Array(mapView.annotations(in: mapView.visibleMapRect))
            let annotationNonClusteredArray = self.clusteringManager.allAnnotations()
            
            if (annotationNonClusteredArray.count > 0) {
            for anno in annotationNonClusteredArray {
                if ((anno as! PinAnnotation).id == playNext?.id) {
                    playNext?.latitude = (anno as! PinAnnotation).latitude
                    playNext?.longitude = (anno as! PinAnnotation).longitude
                    break
                }
               
            }
            }
            mapView.changeCenter(center: annotation.coordinate)
        }
        else {
            mapView.changeCenter(center: annotation.coordinate)
            dropAnnotation(annotation: annotation)
          //    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
            self.mapView.selectAnnotation(annotation, animated: false)
               // self.mapView.selectAnnotation(self.mapView.annotations.last!, animated: true)
            //}
        }
        
    }
    
    func dropAnnotation(annotation : MKAnnotation) {
        
        let visibleAnnotations : Set = mapView.annotations(in: mapView.visibleMapRect)
        let isAnnotationVisible : Bool = visibleAnnotations.contains(annotation as! AnyHashable)
        
        if (!isAnnotationVisible) {
            mapView.addAnnotation(annotation)
        }
        
        mapView.selectAnnotation(annotation, animated: true)
        
    }
    
    
    
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        regionChangedBecauseAnnotationSelected = regionWillChangeAnimatedCalled
        
        if view is FBAnnotationClusterView {
            //let annotationCluster = view.annotation as! FBAnnotation
            
            var clusterAnnotations : [MKAnnotation]
            var closestStation : MKAnnotation
            
            let cView = view as! FBAnnotationClusterView
            clusterAnnotations = cView.getClusterAnnotations()
            if (clusterAnnotations.count > 0) {
                closestStation = findClosestStation(annotations: cView.getClusterAnnotations() as! [PinAnnotation],coordinate: (cView.annotation?.coordinate)!)
                
                //do not zoom in if user dragged map, else zoom in if user selected point
                var delta = 0.03125
                if (selectedFromRegionChange) {
                    skipRegionClustering = true
                    delta = 1.0
                }
                
                //if (delta == 1.0)
                //{
                //    mapView.changeCenter(center: closestStation.coordinate)
                //}
                //else {
                    mapView.setZoomByDelta(delta: delta, animated: true, center: closestStation.coordinate)
                //}
                
                btnZoomOut.isEnabled = true
                barBtnWorld.isEnabled = true
                
                
                let annotationView = closestStation as! PinAnnotation
                
                if (self.checkIfFavorite(name: annotationView.name))
                {
                    view.leftCalloutAccessoryView = nil
                }
                
                mapView.addAnnotation(closestStation)
                mapView.selectAnnotation(closestStation, animated: true)
                
                // When zooming into cluster, turn on Tuner mode, unless it's explicitly been turned off
                if (!tunerTurnedOff) {
                    turnONTuner()
                }
            }
            
            
            return
            
        }
        
        
        
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        
        
        let annotation = view.annotation as! PinAnnotation
       
        if (!checkIfFavorite(name: annotation.name)) {
            view.image = UIImage(named: "pinView")
        }
       
        
        appDelegate.setNetworkActivityIndicatorVisible(visible: false)
        
        sharedContext.perform {
            
            
            if (self.checkIfFavorite(name: annotation.name))
            {
                view.leftCalloutAccessoryView = nil
            }
            
            //  print("Music stream playing",toOpen)
            self.playFromAnnotation(annotation: annotation)
            
            
        }
        
        
        
        regionWillChangeAnimatedCalled = false
        regionChangedBecauseAnnotationSelected = false
        
        
    }
    
    func turnONTuner()
    {
        
            tunerToggle.isOn = true
            tunerLabel.text = "Tuner ON"
            centerFocus.isHidden = false
        
    }
    
    func findClosestStation(annotations:[MKAnnotation], coordinate:CLLocationCoordinate2D) -> MKAnnotation {
        
        var closest : MKAnnotation = annotations[0]
        
        
        //Max possible distance between 2 points
        var distance = CLLocationDistance(20036332.8)
        let minDistance : CLLocationDistance = CLLocationDistance(482803.2)
        
        
        for annotation in annotations {
            //Look for only pin annotations and not cluster annotations
            //   if (type(of: annotation) == MKAnnotation.self)
            // {
            let annotationCoord : CLLocation = CLLocation(latitude: annotation.coordinate.latitude,longitude: annotation.coordinate.longitude)
            let clusterCoord : CLLocation = CLLocation(latitude: coordinate.latitude,longitude: coordinate.longitude)
            
            if (clusterCoord.distance(from: annotationCoord) <= distance) {
                closest = annotation
                distance = clusterCoord.distance(from: annotationCoord)
            }
            // }
            
        }
        
        return closest
    }
    
    func playFromAnnotation(annotation: PinAnnotation) {
        
        playNextData = annotation.name
        
        if (annotation.location != nil) {
            self.playNextData = self.playNextData + " ∞∞ " + annotation.location
        }
        
    
        playMusic(music: annotation.streamUrl)
        currentlyPlaying = annotation
        prevStationHistory.append(annotation)
        reWind.isEnabled = true
        if (prevStationHistory.count > 1 )
        {
            reWind.isEnabled = true
        }
        
        
    }
    


    
    
    func checkIfFavorite(name:String) -> Bool {
        
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
                    
                    
                    if (self.checkIfFavorite(name: annotationView.name))
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
        
        
        
        
        
        var newData : String = ""
        var nowPlayingData : String = ""
        
        
        if (keyPath == "timedMetadata")
        {
            
            
            let data: AVPlayerItem = object as! AVPlayerItem
            
            if (data.timedMetadata != nil) {
                
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
                    statusUpdate(message: nowPlayingData)
                    
                }
            }
        }
        else if (keyPath == "status")
        {
            
            let playerItem:AVPlayerItem = object as! AVPlayerItem
            
            
            if playerItem.status ==  AVPlayerItemStatus.readyToPlay{
                
                stopTunerAudio()
                nowPlayingData = playNextData
                playAndPauseBar.isEnabled = true
                if (prevStationHistory.count > 1) {
                    reWind.isEnabled = true
                }
                else
                {
                    // reWind.isEnabled = false
                }
                
                if (nextStationHistory.count > 0) {
                    fastForward.isEnabled = true
                }
                else {
                    //  fastForward.isEnabled = false
                }
                
                playPauseImageUpdate(play: false)
                
                
                statusUpdate(message: nowPlayingData)
            } else if playerItem.status == AVPlayerItemStatus.failed {
                handleErrorStation()
                
                
                
            }
            
            
        }
        else if (keyPath == "rate") {
            //let player:AVPlayer = object as! AVPlayer
            switch (object! as AnyObject).rate as Float {
            case 0.0:
                playPauseImageUpdate(play: true)
                //  payAndPauseBar.isOpaque = false
                
                
            case 1.0:
                playPauseImageUpdate(play: false)
                //  payAndPauseBar.isOpaque = false
                
            default:
                // shouldn't get here...
                true
            }
            
        }
        else {
            return
        }
    }
    
    func handleErrorStation(streamUrl : String="") {
        
        statusUpdate(message: "Unable to play radio stream. Try another station.", error: true)
        
        
        if (currentlyPlaying != nil)
        {
            print(currentlyPlaying?.title)
            print("Invalid Station: ",(currentlyPlaying as! PinAnnotation).streamUrl)
        }
        else{
            print("Invalid Station: ", streamUrl)

        }
        playAndPauseBar.isEnabled = false
        //playPauseImageUpdate(play: true)
        //  payAndPauseBar.isOpaque = true

        
    }
    
    func statusUpdate(message: String,error: Bool = false) {
        
        DispatchQueue.main.async {
            
            self.nowPlayingLabel.text = message
            if(error) {
                self.nowPlayingLabel.textColor = UIColor.white
                self.nowPlayingLabel.font.withSize(20.0)
                self.nowPlayingLabel.backgroundColor = UIColor.red
                self.nowPlayingLabel.fadeLength = 3
            }
            else {
                self.nowPlayingLabel.textColor = self.DARK_FOREGROUND_COLOR
                self.nowPlayingLabel.font.withSize(14.0)
                self.nowPlayingLabel.backgroundColor = self.LIGHT_BACKGROUND_COLOR
                self.nowPlayingLabel.fadeLength = 3
            }
        }
        
        print(message)
        
    }
    
    func playPauseImageUpdate(play: Bool)
    {
        DispatchQueue.main.async {
            if (play) {
                //self.playAndPauseBar.image = UIImage(named: "play")
                self.playAndPauseBar.setFAIcon(icon: .FAPlay, iconSize: self.PLAY_BUTTON_SIZE)
                self.playAndPauseBar.tintColor = self.DARK_FOREGROUND_COLOR
                
            }
            else {
                //self.playAndPauseBar.image = UIImage(named: "pause")
                self.playAndPauseBar.setFAIcon(icon: .FAPause, iconSize: self.PLAY_BUTTON_SIZE-3)
                self.playAndPauseBar.tintColor = self.DARK_FOREGROUND_COLOR
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "favoriteStations":
            //print("segue called")
            
            let dest = segue.destination as! TableViewController
            dest.tvcDelegate = self
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


