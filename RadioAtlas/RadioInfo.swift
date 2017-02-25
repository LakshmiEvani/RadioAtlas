//
//  RadioInfo.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import MapKit
import CoreData

struct RadioInfo {
    
    
    // MARK: Properties
    
    var id: String?
    var name: String?
    var streamUrl: String?
    var latitude: Double?
    var longitude: Double?
    var websiteURL: String?
    var city: String?
    var state: String?
    var country : String?
    
    static var radioInfo = [RadioInfo]()
    
    
    // MARK: Initializers
    
    init(stations : NSArray) {
        
        // print("stations value",stations)
        
        id = stations[0] as? String
        name = stations[1] as? String
        streamUrl = stations[2] as? String
        latitude = Double((stations[3] as? String)!)
        longitude = Double((stations[4] as? String)!)
        websiteURL = stations[5] as? String
        city = stations[6] as? String
        state = stations[7] as? String
        country = stations[8] as? String
        
        //   print("The latitude & The longitude", "\(latitude)\(longitude)")
    }
    
    
    static func locationsFromDictionaries(_ dictionaries: [NSArray]) -> [RadioInfo] {
        
        var radioInfo = [RadioInfo]()
        
        for Dictionary in dictionaries {
            
            radioInfo.append(RadioInfo(stations: Dictionary))
            
        }
        //print("The radioinfo is: ", radioInfo)
        return radioInfo
        
    }
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        
    }
    
    
}
