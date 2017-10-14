//
//  TutorialPageViewController.swift
//  Progress
//
//  Created by James Tran on 9/27/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit

class TutorialPageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageControl = UIPageControl()
    var orderedViewController : [UIViewController] = {
        var page1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Page1ViewController")
        var page2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Page2ViewController")
        var page3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Page3ViewController")
        var page4 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Page4ViewController")
        
        return [page1, page2, page3, page4]
    }()
    let defaults:UserDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
                
        if let firstViewController = orderedViewController.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        self.delegate = self
        configurePageControl()
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewController.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewController.index(of: viewController) else {
            return nil
        }
        
        let afterIndex = viewControllerIndex + 1
        
        if afterIndex >= orderedViewController.count {
            return orderedViewController.first
        } else {
            return orderedViewController[afterIndex]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewController.index(of: viewController) else {
            return nil
        }
        
        let beforeIndex = viewControllerIndex - 1
        
        if beforeIndex < 0 {
            return orderedViewController.last
        } else {
            return orderedViewController[beforeIndex]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewController.index(of: pageContentViewController)!
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Tutorial", message: "Do you want to show this tutorial next time you open Progress?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak alert] (_) in
            self.defaults.set(false, forKey: "DontShowTutorial")
            alert?.dismiss(animated: true, completion: nil)
            self.navigationController?.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.defaults.set(true, forKey: "DontShowTutorial")
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

