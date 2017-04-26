//
//  OnboardingViewController.swift
//  godtools
//
//  Created by Devserker on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class OnboardingViewController: BaseViewController {
    
    @IBOutlet weak var page1View: UIView!
    @IBOutlet weak var page2View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    fileprivate func initialSetup() {
        let viewWidth = self.view.frame.width
        self.page2View.transform = CGAffineTransform(translationX: viewWidth, y: 0)
    }
    
    @objc fileprivate func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            displayPage1()
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            displayPage2()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func pressOkayButton(_ sender: Any) {
        displayPage2()
    }
    
    @IBAction func pressNowButton(_ sender: Any) {
    }
    
    @IBAction func pressLaterButton(_ sender: Any) {
    }
    
    // MARK: Movement
    
    fileprivate func displayPage1() {
        let viewWidth = self.view.frame.width
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.page2View.transform = CGAffineTransform(translationX: viewWidth, y: 0)
                        self.page1View.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
    }
    
    fileprivate func displayPage2() {
        let viewWidth = self.view.frame.width
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.page2View.transform = CGAffineTransform(translationX: 0, y: 0)
                        self.page1View.transform = CGAffineTransform(translationX: -(viewWidth), y: 0) },
                       completion: nil )
    }
    
}
