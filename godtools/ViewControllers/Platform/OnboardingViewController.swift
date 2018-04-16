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
    
    @IBOutlet weak var languagesOkayButton: TransparentButton!
    @IBOutlet weak var toolsOkayButton: TransparentButton!
    
    @IBOutlet weak var addToolsLabel: GTLabel!
    @IBOutlet weak var addLanguagesLabel: GTLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    private func initialSetup() {
        let viewWidth = view.frame.width
        page2View.transform = CGAffineTransform(translationX: viewWidth, y: 0)
        pageControl.transform = CGAffineTransform(scaleX: 2.0, y: 2.0);
        
        setupButtonLabels()
    }
    
    private func setupButtonLabels() {
        toolsOkayButton.setTitle("okay".localized, for: .normal)
        languagesOkayButton.setTitle("okay".localized, for: .normal)
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
    
    @IBAction func pressToolsOkayButton(_ sender: Any) {
        displayPage2()
    }

    @IBAction func pressLanguagesOkayButton(_ sender: Any) {
        dismissOnboarding()
    }
    
    // MARK: Movement
    
    fileprivate func displayPage1() {
        pageControl.currentPage -= 1
        let viewWidth = view.frame.width
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.page2View.transform = CGAffineTransform(translationX: viewWidth, y: 0)
                        self.page1View.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
    }
    
    fileprivate func displayPage2() {
        pageControl.currentPage += 1
        let viewWidth = view.frame.width
        
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
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Add accessibility identifiers
    
    override func addAccessibilityIdentifiers() {
        page1View.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.addToolsView
        page2View.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.addLanguagesView
        toolsOkayButton.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.toolsOkayButton
        languagesOkayButton.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.languagesOkayButton
        addToolsLabel.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.addToolsLabel
        addLanguagesLabel.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.addLanguagesLabel
    }
}


