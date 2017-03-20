//
//  PageCViewController.swift
//  RadioAtlas
//
//  Created by s2 on 3/11/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import Foundation
import UIKit

class PageCViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var startButton: UIButton!
    
    var pageIndex = 0
    var headerDescription = ""
    var subheaderDescription = ""
    var imageFile = ""
    
   
    var timer : Timer!
    var updateCounter : Int = 0
    
    var PageViewController: PageViewController? {
        didSet {
            PageViewController?.tutorialDelegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.layer.cornerRadius = 4
       
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        timer.fire()
    }
    
  
    internal func updateTimer() {
       
  
     if updateCounter < 3  {
     
        pageControl.currentPage = updateCounter
    
        PageViewController?.scrollToViewController(index: pageControl.currentPage)
        //pageControl.setViewControllers([PageViewController], direction: .Forward, animated: true, completion: nil)
        
        if (updateCounter == 2) {
            timer.invalidate()
        }
        else {
            
            updateCounter = updateCounter + 1
        }
     
     } else {
     
        updateCounter = 0
     }
     
}
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let PageViewController = segue.destination as? PageViewController {
            self.PageViewController = PageViewController
        }
    }
    
    
    
  /*  @IBAction func goAction(_ sender: Any) {
        
        PageViewController?.scrollToNextViewController()
    }*/
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
        
       // Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        PageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension PageCViewController: PageViewControllerDelegate {
    
    func PageViewController(_ PageViewController: PageViewController,
                            didUpdatePageCount count: Int) {
        
        pageControl.numberOfPages = count
    }
    
    func PageViewController(_ PageViewController: PageViewController,
                            didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
