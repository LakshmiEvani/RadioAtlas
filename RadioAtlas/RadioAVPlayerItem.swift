//
//  RadioAVPlayerItem.swift
//  RadioAtlas
//
//  Created by Ravi Evani on 2/25/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreMedia


protocol RadioAVPlayerItemDelegate {
    func removePlayerItemObserver(playerItem: RadioAVPlayerItem)
}


class RadioAVPlayerItem : AVPlayerItem {
    
 
    var delegate : RadioAVPlayerItemDelegate?


    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        
        super.init(asset: asset , automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)

    }
    
    
    
    override func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?) {
        
        super.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
    }
    
    deinit {
        if (delegate != nil) {
            delegate?.removePlayerItemObserver(playerItem: self)
        }
        
        //removeObserver(self.observer, forKeyPath: keyPath)
        }
        
    
    
}
