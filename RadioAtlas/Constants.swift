//
//  Constants.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit

extension Client{
    
    
    
    struct Constants {      
        
    }
    
    
    struct ParameterValues {
        
        static let ResponseFormat = "json"
        static let per_page = 20
        static let page = 0
        static let offset = 0
    }
    
    // MARK: Radio Station Response Keys
    struct JSONResponseKeys {
        static let ID = "id"
        static let Name = "name"
        static let Description = "description"
        static let Country = "country"
        static let Website = ""
        static let url = "url"
        static let Format = "json"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    // MARK: Radio Station Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let token = "api_key"
        static let Format = "format"
        static let Page = "page"
        static let per_page = "per_page"
        static let offset = "offset"
    }
    
    struct Colors {
        static let DARK_FOREGROUND_COLOR = UIColor(red:0.04, green:0.29, blue:0.60, alpha:1.0)
        static let DISABLED_COLOR = UIColor.init(white: 0.8, alpha: 1.0)
        static let ALERT_COLOR = UIColor(red:0.83, green:0.08, blue:0.35, alpha:1.0)
        static let LIGHT_BACKGROUND_COLOR = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)

    }
    
    
}
