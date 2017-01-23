//
//  Client.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import MapKit


class Client: NSObject {
    
    // Shared session
    var session: URLSession
    var radioStations = [RadioInfo]()
    // MARK: Initializers
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    //Get Method
    
    func taskForGetMethodWithParameters(completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        // Build and configure GET request
        let urlString = Constants.BaseUrl
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        print("The request is:",request)
        // Make the request
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            // GUARD: Was there an error
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(error)"]
                completionHandler(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? HTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey: "Your Request returned an invalid respons! Status code: \(response.statusCode)!"]
                    completionHandler(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                    completionHandler(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                }
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request!"]
                completionHandler(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            // Parse and use data
            
            Client.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        })
        
        //start the request
        task.resume()
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject!
        } catch {
            
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
            
        }
        completionHandler(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        
        return Singleton.sharedInstance
    }
    
    func openURL(_ urlString: String) {
        let url = URL(string: urlString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
}
