//
//  TableViewController.swift
//  RadioAtlas
//
//  Created by Souji on 1/18/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import AVFoundation

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // Variable Declaration
    
    @IBOutlet var favoriteTableView: UITableView!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var station = [Station]()
    // Properties
    var client = Client.sharedInstance()
    
    // Core Data Convenience. Useful for fetching, adding and saving objects
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
    var fetchedResultsController: NSFetchedResultsController<Station>!
    
    var audioPlayer:AVPlayer!
    var selectedIndexPath: [IndexPath]!
   // var music = Music.sharedInstance()
    
    //life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        
        print("Items in Station:", station)
        let fetchRequest: NSFetchRequest<Station> =  Station.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "streamURL", ascending: true)]
        
        print("The fetch request is", fetchRequest)
        
        // Create the Fetched Results Controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        perFormFetch()
        fetchedResultsController.delegate = self
        print("Items in fetched Results controller: ",fetchedResultsController)
    }
    
    // MARK: - TableViewController (Fetches)
    
    func perFormFetch() {
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        
        
    }
    
    
    // MARK: Table View Data Source
    
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        guard let selectedObject = fetchedResultsController.object(at: indexPath as IndexPath) as? Station else { fatalError("Unexpected Object in FetchedResultsController") }
        // Populate cell from the NSManagedObject instance
        print("Object for configuration: \(selectedObject)")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let fc = fetchedResultsController {
            print("numberofsections \(fc.sections?.count)")
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let fc = fetchedResultsController {
            print("numberofsectionsinrow \(fc.sections![section].numberOfObjects)")
            
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let favoriteObject = (fetchedResultsController?.object(at: indexPath))! as Station
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        
        sharedContext.perform {
            cell.name.text = favoriteObject.name
            cell.location.text = favoriteObject.location
            
            
            
            // Set image
            self.configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let favoriteObject = (fetchedResultsController?.object(at: indexPath))! as Station
        
       Music.sharedInstance.musicStream(music: favoriteObject.streamURL!)
        
        
    }
    
    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    private func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            
            DispatchQueue.main.async {
                
                if self.fetchedResultsController == nil {
                    print("error when trying to delete object from managed object")
                    
                } else if (editingStyle == UITableViewCellEditingStyle.delete) {
                    
                    
                    let context: NSManagedObjectContext = self.fetchedResultsController.managedObjectContext
                    context.delete(self.fetchedResultsController.object(at: indexPath))
                    CoreDataStackManager.sharedInstance().saveContext()
                }
                
                
            }
            
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate functions
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            favoriteTableView.insertSections(set, with: .fade)
        case .delete:
            favoriteTableView.deleteSections(set, with: .fade)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            favoriteTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            favoriteTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            favoriteTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            favoriteTableView.deleteRows(at: [indexPath!], with: .fade)
            favoriteTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.endUpdates()
    }
    
}

