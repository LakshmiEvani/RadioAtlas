//
//  PinAnnotation.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import MapKit
import Foundation

class PinAnnotation: NSObject, MKAnnotation {
    
    
    var id: String
    var name: String!
    var streamUrl: String!
    var websiteURL: String!
    var city: String!
    var state: String!
    var country : String!
    var location : String!
    var latitude : Double
    var longitude : Double
    
    
    init(id: String, name: String,streamUrl: String, websiteURL: String, location : String, latitude: Double, longitude: Double) {
        self.name = name
        self.streamUrl = streamUrl
        self.websiteURL = websiteURL
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
        
        super.init()
        
    }
    
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return location
    }
    
    var coordinate : CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
