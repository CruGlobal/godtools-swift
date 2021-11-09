//
//  OnboardingQuickStartViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class OnboardingQuickStartViewModel: OnboardingQuickStartViewModelType {
    
    let title: String
    let skipButtonTitle: String
    let endTutorialButtonTitle: String
    let quickStartItemCount: Int
    
    private let quickStartItems: [OnboardingQuickStartItem]
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices) {
        
        title = localizationServices.stringForMainBundle(key: "onboardingQuickStart.title")
        skipButtonTitle = localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip")
        endTutorialButtonTitle = localizationServices.stringForMainBundle(key: "onboardingTutorial.getStartedButton.title")
        
        self.flowDelegate = flowDelegate
        
        quickStartItems = [
            OnboardingQuickStartItem(
                title: localizationServices.stringForMainBundle(key: "onboardingQuickStart.0.title"),
                linkButtonTitle: localizationServices.stringForMainBundle(key:  "onboardingQuickStart.0.button.title"),
                linkButtonFlowStep: .readArticlesTappedFromOnboardingQuickStart
            ),
            OnboardingQuickStartItem(
                title: localizationServices.stringForMainBundle(key: "onboardingQuickStart.1.title"),
                linkButtonTitle: localizationServices.stringForMainBundle(key:  "onboardingQuickStart.1.button.title"),
                linkButtonFlowStep: .readArticlesTappedFromOnboardingQuickStart
            ),
            OnboardingQuickStartItem(
                title: localizationServices.stringForMainBundle(key: "onboardingQuickStart.2.title"),
                linkButtonTitle: localizationServices.stringForMainBundle(key:  "onboardingQuickStart.2.button.title"),
                linkButtonFlowStep: .readArticlesTappedFromOnboardingQuickStart
            ),
        ]
        
        quickStartItemCount = quickStartItems.count
    }
    
    func quickStartCellWillAppear(index: Int) -> OnboardingQuickStartItem {
        
        return quickStartItems[index]
    }
    
    func quickStartCellLinkButtonTapped(flowStep: FlowStep) {
        
        flowDelegate?.navigate(step: flowStep)
    }
    
    func skipButtonTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingQuickStart)
    }
    
    func endTutorialButtonTapped() {
        
        flowDelegate?.navigate(step: .endTutorialFromOnboardingQuickStart)
    }
}
