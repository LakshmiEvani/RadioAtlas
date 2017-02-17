//
//  Music.swift
//  RadioAtlas
//
//  Created by Souji on 2/10/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Music {
    
    static var sharedInstance = Music()
    var isPlaying = false
    var audioPlayer:AVPlayer!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private init() {
        print(musicStream)
    }


       func musicStream(music: String){
        
        
        //Setting music stream
        
        DispatchQueue.global(qos: .background).async {
            
            do
            {
                
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                
                let fileURL = NSURL(string: music)
                let playerItem = AVPlayerItem(url: fileURL as! URL)
                self.audioPlayer = AVPlayer(playerItem: playerItem)
                self.audioPlayer!.play()
                self.isPlaying = true
                self.appDelegate.setNetworkActivityIndicatorVisible(visible: true)
                
            } catch let error as NSError {
                self.audioPlayer = nil
                print(error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
                
            }
        }
    }
       
}
