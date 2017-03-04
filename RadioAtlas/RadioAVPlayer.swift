//
//  RadioAVPlayer.swift
//  RadioAtlas
//
//  Created by Ravi Evani on 2/24/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol RadioAVPlayerDelegate {
    func addPlayerObservers(player: RadioAVPlayer)
    func removePlayerObservers(player: RadioAVPlayer)
}

class RadioAVPlayer : AVPlayer {
    
    var delegate : RadioAVPlayerDelegate?
    
    override init() {
        super.init()
    }
    
    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        
    }
    
    func addObservers(del : RadioAVPlayerDelegate)
    {
        if (delegate != nil) {
            delegate?.addPlayerObservers(player: self)
        }
    }

    
    deinit {
        if (delegate != nil) {
            delegate?.removePlayerObservers(player: self)
        }
        
        //removeObserver(self.observer, forKeyPath: keyPath)
    }

}
