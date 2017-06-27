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
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var nowButton: TransparentButton!
    @IBOutlet weak var laterButton: TransparentButton!
    @IBOutlet weak var okayButton: TransparentButton!
    
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
    
    private func initialSetup() {
        let viewWidth = self.view.frame.width
        self.page2View.transform = CGAffineTransform(translationX: viewWidth, y: 0)
        self.pageControl.transform = CGAffineTransform(scaleX: 2.0, y: 2.0);
        
        setupButtonLabels()
    }
    
    private func setupButtonLabels() {
        nowButton.setTitle("now".localized, for: .normal)
        okayButton.setTitle("okay".localized, for: .normal)
        laterButton.setTitle("later".localized, for: .normal)
    }
    
    @objc fileprivate func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            displayPage1()
        } else if gesture.direction == .left {
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
        dismissOnboarding()
        NotificationCenter.default.post(name: .presentLanguageSettingsNotification, object: nil)
    }
    
    @IBAction func pressLaterButton(_ sender: Any) {
        dismissOnboarding()
    }
    
    // MARK: Movement
    
    fileprivate func displayPage1() {
        self.pageControl.currentPage -= 1
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
        self.pageControl.currentPage += 1
        let viewWidth = self.view.frame.width
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.page2View.transform = CGAffineTransform(translationX: 0, y: 0)
                        self.page1View.transform = CGAffineTransform(translationX: -(viewWidth), y: 0) },
                       completion: nil )
    }
    
    // MARK: - Helpers
    
    fileprivate func dismissOnboarding() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
