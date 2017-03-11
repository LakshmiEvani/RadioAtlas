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
    
    var PageViewController: PageViewController? {
        didSet {
            PageViewController?.tutorialDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.addTarget(self, action: #selector(PageCViewController.didChangePageControlValue), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let PageViewController = segue.destination as? PageViewController {
            self.PageViewController = PageViewController
        }
    }
    
       
    @IBAction func goAction(_ sender: Any) {
        
        PageViewController?.scrollToNextViewController()
    }
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
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
