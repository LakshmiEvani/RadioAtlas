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
    
    // MARK: RadioStation API
    func getStations(completionHandler: @escaping (_ result: [RadioInfo]?, _ errorString: String?) -> Void){
        
        
        taskForGetMethodWithParameters( completionHandler: {
            (results, error) in
            
           
                
            let parsedResult = results
            //   print("The parsedResult are: ",parsedResult)
            
            if error != nil {
                completionHandler(nil, "Could not get results. in result")
                
            } else {
                
                // print("The parsed result of values are:",parsedResult?["values"] )
                
                if let result =  parsedResult?["values"] as? [NSArray]{
                    
                    var resultList = [NSArray]()
                    
                    var count = 0
                    
                    for i in result {
                        
                        count = count+1
                        
                        if count > 1500 {
                            break
                        }
                           print(i)
                        
                        let id = i[0] as? String
                        let name = i[1] as? String
                        let websiteURL = i[5] as? String
                        let city = i[6] as? String
                        let state = i[7] as? String
                        let country = i[8] as? String
                        let latitude = i[3] as? String
                        let longitude = i[4] as? String
                        let streamUrl = i[2] as? String
                        
                        let x = NumberFormatter().number(from: latitude!)?.doubleValue
                        
                        let y = NumberFormatter().number(from: longitude!)?.doubleValue
                        
                      //  if id == nil || name == nil || websiteURL == nil  || city == nil || state == nil  || country == nil  {
                        
                        if x != nil && y != nil && streamUrl != nil {
                            
                            //  print(" x, y: ", "\(x)\(y)")
                            
                            resultList.append(i)
                            
                        } else {
                            
                            print("Error in latitude or longitude")
                        }
                        
                      //  } else {
                            
                            
                        //}
                
                }
                    
                    // print("Student resultList",resultList)
                    
                    let value = result[0] as? NSArray
                    
                    let name = value?[1] as? String
                    
                    
                    // Response dictionary
                    
                    self.radioStations = RadioInfo.locationsFromDictionaries(resultList)
                    
                    
                    completionHandler(self.radioStations, nil)
                    
                }
                
                
            }
            
        })
        
    }
    
    
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}
