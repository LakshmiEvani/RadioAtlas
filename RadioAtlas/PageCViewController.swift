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
       
        Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
  
    internal func updateTimer() {
        
     /*   let pvcs = PageViewController?.childViewControllers as! [PageCViewController]
        let itemIndex = pvcs[0].updateCounter
        let firstController = getItemController(itemIndex: itemIndex+1)!
        let startingViewControllers = [firstController]
        PageViewController!.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
 */
     if updateCounter < 3  {
     
     pageControl.currentPage = updateCounter
  //  imageView.image = UIImage(named: String(updateCounter + 1) + ".png")
    
     PageViewController?.scrollToViewController(index: pageControl.currentPage)
     //pageControl.setViewControllers([PageViewController], direction: .Forward, animated: true, completion: nil)
     updateCounter = updateCounter + 1
     } else {
     
     updateCounter = 0
     }
     
}
    

    
  /*  private func getItemController(itemIndex: Int) -> PageCViewController? {
        
        if itemIndex < pageControl.numberOfPages {
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "PageCViewController") as! PageCViewController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = pageControl[itemIndex]
            return pageItemController
        }
        
        return nil
    }*/

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
