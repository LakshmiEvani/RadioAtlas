//
//  Convenience.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import CoreData

extension Client {
    
   
    func getStations(completionHandler: @escaping (_ result: [RadioInfo]?, _ errorString: String?) -> Void){
        
        
        taskForGetMethodWithParameters( completionHandler: {
            (results, error) in
            
            
            if error != nil {
                completionHandler(nil, "Could not get results. in result")
                
            } else {
                
                // print("The parsed result of values are:",parsedResult?["values"] )
                
                if let result =  results?["values"] as? [NSArray]{
                    
                    var resultList = [NSArray]()
                    
                    var count = 0
                    
                    for i in result {
                        
                do {
                    
                        count = count+1
                    //print(count)
                    
                                           
                    
                         //  print(i)
                        
                      _ = try i[0] as? String
                        _ = try i[1] as? String
                        _ = try i[5] as? String
                        _ = try i[6] as? String
                        _ = try i[7] as? String
                        _ = try i[8] as? String
                        _ = try i[9] as? String
                        let latitude =  i[3] as? String
                        let longitude =  i[4] as? String
                        let streamUrl = i[2] as? String
                        
                        let x = try NumberFormatter().number(from: latitude!)?.doubleValue
                        
                        let y = try NumberFormatter().number(from: longitude!)?.doubleValue
                        
                      //  if id == nil || name == nil || websiteURL == nil  || city == nil || state == nil  || country == nil  {
                        
                        if x != nil && y != nil && streamUrl != nil  {
                            
                            //  print(" x, y: ", "\(x)\(y)")
                            
                            try resultList.append(i)
                            
                        } else {
                            
                            print("Error in latitude or longitude")
                        }
                        
                      } catch {
                            
                            print("Error in the element",i)
                    }
                
                }
                    
                    
                    
                    // print("Student resultList",resultList)
                    
                    let value = result[0] as? NSArray
                    
                    let name = value?[1] as? String
                    
                    
                    // Response dictionary
                    
                    self.radioStations = RadioInfo.locationsFromDictionaries(resultList)
                    
                    
                    completionHandler(self.radioStations, nil)
                    
                } else {
                    
                     completionHandler([], "Could not get results. in result")
                }
                
                
            }
            
        })
        
    }
    
    
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}
