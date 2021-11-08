//
//  OnboardingQuickStartView.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingQuickStartView: UIViewController {
    
    enum DismissOnboardingTutorialType {
        case readArticles
        case tryLessons
        case chooseTool
    }
    
    private let viewModel: OnboardingQuickStartViewModelType
    
    private var skipButton: UIBarButtonItem?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var endTutorialButton: OnboardPrimaryButton!
    
    required init(viewModel: OnboardingQuickStartViewModelType) {
        
        self.viewModel = viewModel

        super.init(nibName: String(describing: OnboardingQuickStartView.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
        
        endTutorialButton.addTarget(self, action: #selector(handleEndTutorial), for: .touchUpInside)
    }
    
    private func setupLayout() {
        
        titleLabel.text = viewModel.title
        
        endTutorialButton.setTitle(viewModel.endTutorialButtonTitle, for: .normal)
        
        setSkipButton()
    }
    
    private func setupBinding() {
        
    }
    
    private func reloadData() {
        
    }
    
    private func setSkipButton() {
        
        let skipButtonPosition: ButtonItemPosition = .right
        
        if skipButton == nil {
            skipButton = addBarButtonItem(
                to: skipButtonPosition,
                title: viewModel.skipButtonTitle,
                style: .plain,
                color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
                target: self,
                action: #selector(handleSkip(barButtonItem:))
            )
        }
        else if let skipButton = skipButton {
            addBarButtonItem(item: skipButton, barPosition: skipButtonPosition)
        }
    }
    
    @objc func handleSkip(barButtonItem: UIBarButtonItem) {
        
        viewModel.skipButtonTapped()
    }
    
    @objc func handleEndTutorial() {
        
        viewModel.endTutorialButtonTapped()
    }
}

// MARK: - OnboardingQuickStartCellDelegate

extension OnboardingQuickStartView: OnboardingQuickStartCellDelegate {
    
    func buttonTapped(flowStep: FlowStep) {
        viewModel.quickStartCellLinkButtonTapped(flowStep: flowStep)
    }
}

