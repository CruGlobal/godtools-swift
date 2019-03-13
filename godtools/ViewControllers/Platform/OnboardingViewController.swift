//
//  OnboardingViewController.swift
//  godtools
//
//  Created by Devserker on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class OnboardingViewController: BaseViewController {
    
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
        
        let anyTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(anyTap)
        let swipeUpDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUpDown.direction = [.down, .up]
        view.addGestureRecognizer(swipeUpDown)
        let swipeleftRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeleftRight.direction = [.left, .right]
        view.addGestureRecognizer(swipeleftRight)

        page2View.transform = CGAffineTransform(translationX: 0, y: 0)
        setupButtonAndLabels()
        displayPage2()
    }
    
    private func setupButtonAndLabels() {
        languagesOkayButton.titleLabel?.font = UIFont.gtLight(size: 26.0)
        languagesOkayButton.borderColor = .clear
        numberOfLanguagesLabel.text = "language_onboard".localized
        addLanguagesLabel.text = "share_god_tools_native_language".localized
        languagesOkayButton.setTitle("OK".localized, for: .normal)
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
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
    }
    
    // MARK: - Helpers
    
    fileprivate func dismissOnboarding() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Add accessibility identifiers
    
    override func addAccessibilityIdentifiers() {
        page2View.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.addLanguagesView
        languagesOkayButton.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.languagesOkayButton
        numberOfLanguagesLabel.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.numberOfLanguagesLabel
        addLanguagesLabel.accessibilityIdentifier = GTAccessibilityConstants.Onboarding.addLanguagesLabel
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
