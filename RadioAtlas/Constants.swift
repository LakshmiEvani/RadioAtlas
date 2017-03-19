//
//  Constants.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
extension Client{
    
    
    // MARK: Radio Station Constant values
    struct Constants {
        
        //static let BaseUrl = "https://sheets.googleapis.com/v4/spreadsheets/1BTI4xTfrAu3oSrXATb6VfpXxVHhS85BdD7hLW7sJvBU/values/A2:J10000?key=AIzaSyBo1OtS_4J6SFtSwtGZldqgW3ZnMypJljc"
 
        static let BaseUrl = "https://swift-capsule-129116.appspot.com/echo-get?key=AIzaSyACnV26v6oLjI6mWwGX9-K7leFaLEGu3g0"
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
    
    
}
