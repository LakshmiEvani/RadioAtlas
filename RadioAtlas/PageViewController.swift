//
//  PageViewController.swift
//  RadioAtlas
//
//  Created by s2 on 3/5/17.
//  Copyright © 2017 Souji. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    weak var tutorialDelegate: PageViewControllerDelegate?
    // MARK: - Stored Properties
    
    enum SceneDescriptionFor {
        static let header = ["Capture Your Moment",
                             "Share Your Joy"]
                            // "Sync Your Life"]
        
        static let subheader = ["Take pictures with incredible filters and control.",
                                "Connect with your friends. Sharing is caring."]
                               // "Synchronize your data across iOS devices seamlessly."]
    }
    
    let images = ["link", "play&pause"]
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        
        
        return [self.newColoredViewController(color: "Grey"),
                self.newColoredViewController(color: "Blue"),
                self.newColoredViewController(color: "Green")]
    }()
    
    private func newColoredViewController(color: String) -> UIViewController {
        return
            UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewController(withIdentifier: "\(color)ViewController")

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        
       
        // Do any additional setup after loading the view.
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(initialViewController)
            //viewControllerAtIndex(0)
           
        }
        tutorialDelegate?.PageViewController(self,didUpdatePageCount: orderedViewControllers.count)
        
    }
    
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
            viewControllerAfter: visibleViewController) {
            scrollToViewController(nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    fileprivate func newColoredViewController(_ color: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(color)ViewController")
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    fileprivate func scrollToViewController(_ viewController: UIViewController,
                                            direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    fileprivate func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            tutorialDelegate?.PageViewController(self,didUpdatePageIndex: index)
        }
    }

    
    // MARK - Helper Methods
    
 /*   fileprivate func viewControllerAtIndex(_ index: Int) -> PageCViewController? {
        guard index != NSNotFound || (index >= 0 && index < SceneDescriptionFor.header.count) else { return nil }
        guard let validStoryboard = self.storyboard, let validPageContentViewController = validStoryboard.instantiateViewController(withIdentifier: "PageCViewController") as? PageCViewController else { return nil }
        
        validPageContentViewController.pageIndex = index
        validPageContentViewController.headerDescription = SceneDescriptionFor.header[index]
        validPageContentViewController.subheaderDescription = SceneDescriptionFor.subheader[index]
        validPageContentViewController.imageFile = self.images[index]
        
        return validPageContentViewController
        
    }*/
}

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard var viewControllerIndex = orderedViewControllers.index(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
        
      
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

protocol PageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func PageViewController(_ PageViewController: PageViewController,
                            didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func PageViewController(_ PageViewController: PageViewController,
                            didUpdatePageIndex index: Int)
    
    
    
}


