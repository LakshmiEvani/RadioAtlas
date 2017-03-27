//
//  InsetLabel.swift
//  RadioAtlas
//
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit




class AlertLabel: UILabel {
    
     let DARK_FOREGROUND_COLOR = UIColor(red:0.04, green:0.29, blue:0.60, alpha:1.0)
     let ALERT_COLOR = UIColor(red:0.83, green:0.08, blue:0.35, alpha:1.0)
     let LIGHT_BACKGROUND_COLOR = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)))
    }
    
    func showAlert(view: UIView) {
        self.isHidden = false
        self.backgroundColor = LIGHT_BACKGROUND_COLOR
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5.0
        //self.setFAText(prefixText: "Tuning to a different station every 20 seconds. Tap ", icon: FAType.FAGlobe, postfixText: " to stop.", size: 25)
        self.setFAColor(color: ALERT_COLOR)
        
        //lblNew.text = "Tuning to a different station every 20 seconds. Tap globe to stop"
        self.textColor = DARK_FOREGROUND_COLOR
        self.textAlignment = .center
        self.alpha = 0.96
        self.numberOfLines = 3
        
        /*
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 300)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
        var constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterX,
            metrics: nil,
            views: ["superview":view, "label":self])
        
        view.addConstraints(constraints)
        
        // Center vertically
        constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllBottom,
            metrics: nil,
            views: ["superview":view, "label":self])
        
        view.addConstraints(constraints)
        view.addConstraints([ widthConstraint, heightConstraint]) */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.isHidden = true
        }
        
        
    }

}
