//
//  TableView.swift
//  RadioAtlas
//
//  Created by Souji on 2/15/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class TableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var appDelegate: AppDelegate!
    var client = Client.sharedInstance()

    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.dataSource = self
        tableView?.delegate = self
        
       /* if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector("setLayoutMargins:") {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        self.tableView.layoutIfNeeded()*/
        
        }
    
    
    //Function for defining the contents for each row
    
    
    func tableView(_ tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return 20
    }
    
    func tableView(_ tableView: UITableView!, cellForRowAt indexPath: IndexPath!) -> UITableViewCell!
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "TableViewCell")
        cell.textLabel?.text="row#\(indexPath.row)"
        cell.detailTextLabel?.text="subtitle#\(indexPath.row)"
        
        return cell
    }

/*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        return cell
}*/
  /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        studentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "studentCell")
        let cell = studentTableView.dequeueReusableCell(withIdentifier: "StudentLocationTableViewCell") as! StudentLocationTableViewCell
        let location = StudentInformation.sharedInstance().studentLocation[indexPath.row]
        cell.configureWithStudentLocation(location)
        cell.textLabel?.text = location.firstName + "" + location.lastName
        cell.detailTextLabel!.text = location.mediaURL
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let app = UIApplication.shared
        app.openURL(URL(string: url!)!)
        
    }

  */
}
