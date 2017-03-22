//
//  SettingsController.swift
//  RadioAtlas
//
//  Created by Ravi Evani on 3/21/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

protocol SettingsControllerDelegate {
    
    func muteTunerSound(muted: Bool)
    
}

class SettingsController : UITableViewController {
    
    @IBOutlet weak var lblAboutRA: UITableViewCell!
    @IBOutlet weak var lblAboutCreator: UITableViewCell!
    @IBOutlet weak var lblAddRadioStation: UITableViewCell!
    @IBOutlet weak var lblGitHub: UITableViewCell!
    
    @IBOutlet var tvSettings: UITableView!
    @IBOutlet weak var lblReport: UITableViewCell!
    @IBOutlet weak var lblMuteTuner: UITableViewCell!
    let DARK_FOREGROUND_COLOR = UIColor(red:0.04, green:0.29, blue:0.60, alpha:1.0)
    let FONT_SIZE : CGFloat = 25.0
    let ICON_SIZE : CGFloat = 25.0
    var delegate : SettingsControllerDelegate?
    
    override func viewDidLoad() {
        
        initUI()
        
    }
    
  
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 65.0;//Choose your custom row height
    }
   
    func cellValues(cell: UITableViewCell) {
        cell.textLabel?.textColor = DARK_FOREGROUND_COLOR
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
        
        if(currentCell.textLabel!.text?.contains("Unmute"))! {
            
            lblMuteTuner.textLabel?.setFAText(prefixText: "", icon: FAType.FAVolumeUp, postfixText: "   Mute Tuner Sound", size: FONT_SIZE,iconSize: ICON_SIZE)
            delegate?.muteTunerSound(muted: false)
            
        }
        else
        {
            lblMuteTuner.textLabel?.setFAText(prefixText: "", icon: FAType.FAVolumeOff, postfixText: "   Unmute Tuner Sound", size: FONT_SIZE,iconSize: ICON_SIZE)
            delegate?.muteTunerSound(muted: true)
            
        }
        //print(currentCell.textLabel!.text)
    }

    
    func initUI() {
        
        let frame = CGRect(x: 20, y: 20, width: 140, height: 65)
        lblAboutRA.frame(forAlignmentRect: frame)
        lblAboutRA.textLabel?.setFAText(prefixText: "", icon: .FAExternalLink, postfixText: "  More About Radio Atlas", size: FONT_SIZE,iconSize: ICON_SIZE)
        lblAboutRA.textLabel?.textColor = DARK_FOREGROUND_COLOR
        
        
        lblAboutRA.sizeToFit()
        //lblAboutRA.accessoryView?.tintColor = DARK_FOREGROUND_COLOR
        
        
        lblMuteTuner.textLabel?.setFAText(prefixText: "", icon: FAType.FAVolumeUp, postfixText: "   Mute Tuner Sound", size: FONT_SIZE,iconSize: ICON_SIZE)

        lblMuteTuner.textLabel?.textColor = DARK_FOREGROUND_COLOR
        lblMuteTuner.sizeToFit()
        //lblMuteTuner.accessoryView?.tintColor = DARK_FOREGROUND_COLOR
        
        
        lblAddRadioStation.textLabel?.setFAText(prefixText: "", icon: FAType.FAExternalLink, postfixText: "  Add Your Radio Station", size: FONT_SIZE,iconSize: ICON_SIZE)

        lblAddRadioStation.textLabel?.textColor = DARK_FOREGROUND_COLOR
        lblAddRadioStation.sizeToFit()
        
        lblReport.textLabel?.setFAText(prefixText: "", icon: FAType.FAExternalLink, postfixText: "  Report Problem, Feature or Feedback", size: FONT_SIZE,iconSize: ICON_SIZE)

        lblReport.textLabel?.textColor = DARK_FOREGROUND_COLOR
        lblReport.sizeToFit()
        
        
        lblGitHub.textLabel?.setFAText(prefixText: "", icon: FAType.FAGithub, postfixText: "  View Project on GitHub", size: FONT_SIZE,iconSize: ICON_SIZE)
        
        lblGitHub.textLabel?.textColor = DARK_FOREGROUND_COLOR
        lblGitHub.sizeToFit()
        
    }
}
