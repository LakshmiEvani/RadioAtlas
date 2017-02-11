//
//  Station+CoreDataClass.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Station: NSManagedObject {
    
    public var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func storeImage() -> UIImage?{
        return UIImage(data: self.favoritePinImage! as Data)
    }
    
    convenience init(id: String, name: String,streamUrl: String, websiteURL: String, latitude: Double, longitude: Double, location: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Station", in: context)!
        
        self.init(entity: entity, insertInto: context)
        
        self.id = id
        self.name = name
        self.location = location
        self.streamURL = streamUrl
        self.websiteURL = websiteURL
        self.latitude = latitude
        self.longitude = longitude
        
        try! context.save()
        print("all the fields in Managedobject class: ",self.name!,self.location!, self.streamURL!, self.websiteURL!, self.latitude, self.longitude)
        
    }
    
}

extension Station {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Station> {
        return NSFetchRequest<Station>(entityName: "Station");
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var streamURL: String?
    @NSManaged public var websiteURL: String?
    @NSManaged public var location: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var country: String?
    @NSManaged public var stations: Station?
     @NSManaged public var favoritePinImage: NSData?
    
    
}
