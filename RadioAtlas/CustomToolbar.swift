//
//  CustomToolbar.swift
//  RadioAtlas
//
//  Created by s2 on 2/27/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit

class CustomToolbar: UIToolbar {
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var newSize: CGSize = super.sizeThatFits(size)
        newSize.height = 100  // there to set your toolbar height
        
        return newSize
    }
    
}
