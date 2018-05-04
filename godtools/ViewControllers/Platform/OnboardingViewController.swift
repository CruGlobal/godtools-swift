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
    @IBOutlet weak var addLanguagesLabel: GTLabel!
    @IBOutlet weak var numberOfLanguagesLabel: GTLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        
        let anyTap = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
        //swipeAny.direction = [.down, .up, .left, .right]
        view.addGestureRecognizer(anyTap)
        let swipeUpDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUpDown.direction = [.down, .up]
        view.addGestureRecognizer(swipeUpDown)
        let swipeleftRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeleftRight.direction = [.left, .right]
        view.addGestureRecognizer(swipeleftRight)

        page2View.transform = CGAffineTransform(translationX: 0, y: 0)
        setupButtonLabels()
        displayPage2()
    }
    
    private func setupButtonLabels() {
        languagesOkayButton.titleLabel?.font = UIFont.gtLight(size: 26.0)
        languagesOkayButton.borderColor = .clear
        numberOfLanguagesLabel.text = "60+ Languages".localized
        addLanguagesLabel.text = "Share GodTools with someone in their native language.".localized
        languagesOkayButton.setTitle("OK".localized, for: .normal)
    }
    
    @objc fileprivate func handleGesture(gesture: UITapGestureRecognizer) {
        dismissOnboarding()
    }
    
    @objc fileprivate func handleSwipe(gesture: UISwipeGestureRecognizer) {
        dismissOnboarding()
    }
    
    // MARK: - Actions
    
    @IBAction func pressLanguagesOkayButton(_ sender: Any) {
        dismissOnboarding()
    }
    
    // MARK: Movement
    
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
        languagesOkayButton.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.languagesOkayButton
        numberOfLanguagesLabel.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.numberOfLanguagesLabel
        addLanguagesLabel.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.addLanguagesLabel
    }
}
