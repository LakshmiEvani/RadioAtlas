//
//  SettingsController.swift
//  RadioAtlas
//
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
    
    @IBOutlet weak var muteSwitch: UISwitch!
    @IBOutlet var tvSettings: UITableView!
    @IBOutlet weak var lblReport: UITableViewCell!
    @IBOutlet weak var lblMuteTuner: UITableViewCell!
    @IBOutlet weak var lblMuteTunerText: UILabel!
    let DARK_FOREGROUND_COLOR = UIColor(red:0.04, green:0.29, blue:0.60, alpha:1.0)
    let FONT_SIZE : CGFloat = 25.0
    let ICON_SIZE : CGFloat = 25.0
    var delegate : SettingsControllerDelegate?
    var initialMuteSwitch : Bool = false
    
    override func viewDidLoad() {
        
        initUI()
        
    }
    
    private let kSeparatorId = 123
    private let kSeparatorHeight: CGFloat = 1.5
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.viewWithTag(kSeparatorId) == nil //add separator only once
        {
            let frame = CGRect(x: 0, y: cell.frame.height - kSeparatorHeight, width: cell.frame.width, height: kSeparatorHeight)
            let separatorView = UIView(frame: frame)
            separatorView.tag = kSeparatorId
            separatorView.backgroundColor = UIColor(red:0.89, green:0.93, blue:0.97, alpha:1.0)
            separatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            cell.addSubview(separatorView)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var url : String = ""
        
        if (indexPath.section == 0) {
            
            switch indexPath.row {
            case 1:
                url =  "http://thoughtnerve.com/radioatlas/add-a-radio-station/"
                
                
            case 2:
                url = "http://thoughtnerve.com/radioatlas/report-feedback/"
                
            default: break
                
            }
            
            UIApplication.shared.open(NSURL(string: url)! as URL, options: [:], completionHandler: nil)

            
        }
        else {
            
            switch indexPath.row {
            case 0:
                url =  "http://thoughtnerve.com/radioatlas/about-radio-atlas/"
                
                
            case 1:
                url = "https://github.com/LakshmiEvani/RadioAtlas"
                
            default: break
                
            }
            
            UIApplication.shared.open(NSURL(string: url)! as URL, options: [:], completionHandler: nil)
            
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 65.0;//Choose your custom row height
    }
    
    func cellValues(cell: UITableViewCell) {
        cell.textLabel?.textColor = DARK_FOREGROUND_COLOR
    }
    @IBAction func muteSwitchChanged(_ sender: Any) {
        
        setMuteSwitchStatus(isOn: muteSwitch.isOn)
    }
    
    func setMuteSwitchStatus(isOn : Bool) {
        
        if (isOn) {
            
            lblMuteTunerText?.setFAText(prefixText: "   ", icon: FAType.FAVolumeOff, postfixText: "   Unmute Tuner Sound", size: FONT_SIZE,iconSize: ICON_SIZE)
            delegate?.muteTunerSound(muted: true)
            
        }
        else
        {
            lblMuteTunerText?.setFAText(prefixText: "   ", icon: FAType.FAVolumeUp, postfixText: "   Mute Tuner Sound", size: FONT_SIZE,iconSize: ICON_SIZE)
            delegate?.muteTunerSound(muted: false)
        }
        
    }
    
    
    
    
    func initUI() {
        
        // let frame = CGRect(x: 20, y: 20, width: 140, height: 65)
        // lblAboutRA.frame(forAlignmentRect: frame)
        lblAboutRA.textLabel?.setFAText(prefixText: "", icon: .FAExternalLink, postfixText: "  More About Radio Atlas", size: FONT_SIZE,iconSize: ICON_SIZE)
        lblAboutRA.textLabel?.textColor = DARK_FOREGROUND_COLOR
        
        
        lblAboutRA.sizeToFit()
        //lblAboutRA.accessoryView?.tintColor = DARK_FOREGROUND_COLOR
        
        
        //lblMuteTunerText.setFAText(prefixText: "   ", icon: FAType.FAVolumeUp, postfixText: "   Mute Tuner Sound", size: FONT_SIZE,iconSize: ICON_SIZE)
        
        lblMuteTunerText.textColor = DARK_FOREGROUND_COLOR
        muteSwitch.isOn = initialMuteSwitch
        //setMuteSwitchStatus(isOn: initialMuteSwitch)
        
        if (initialMuteSwitch) {
            
            lblMuteTunerText?.setFAText(prefixText: "   ", icon: FAType.FAVolumeOff, postfixText: "   Unmute Tuner Sound", size: FONT_SIZE,iconSize: ICON_SIZE)
            
            //delegate?.muteTunerSound(muted: true)
            
        }
        else
        {
            lblMuteTunerText?.setFAText(prefixText: "   ", icon: FAType.FAVolumeUp, postfixText: "   Mute Tuner Sound", size: FONT_SIZE,iconSize: ICON_SIZE)
            //delegate?.muteTunerSound(muted: false)
        }
        
        
        muteSwitch.backgroundColor = DARK_FOREGROUND_COLOR
        muteSwitch.layer.cornerRadius = 16.0
        
        //lblMuteTunerText.sizeToFit()
        //lblMuteTuner.accessoryView?.tintColor = DARK_FOREGROUND_COLOR
        
        
        lblAddRadioStation.textLabel?.setFAText(prefixText: "", icon: FAType.FAExternalLink, postfixText: "  Submit a Radio Station", size: FONT_SIZE,iconSize: ICON_SIZE)
        
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
