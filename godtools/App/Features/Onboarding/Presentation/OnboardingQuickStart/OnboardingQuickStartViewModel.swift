//
//  OnboardingQuickStartViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingQuickStartViewModel: ObservableObject {
    
    private let quickStartItems: [OnboardingQuickStartItemDomainModel]
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let getOnboardingQuickStartItemsUseCase: GetOnboardingQuickStartItemsUseCase
    private let trackActionAnalytics: TrackActionAnalytics
    
    private weak var flowDelegate: FlowDelegate?
    
    let title: String
    let skipButtonTitle: String
    let endTutorialButtonTitle: String
    
    @Published var numberOfQuickStartItems: Int = 0
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, getOnboardingQuickStartItemsUseCase: GetOnboardingQuickStartItemsUseCase, trackActionAnalytics: TrackActionAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.getOnboardingQuickStartItemsUseCase = getOnboardingQuickStartItemsUseCase
        self.trackActionAnalytics = trackActionAnalytics
        
        title = localizationServices.stringForSystemElseEnglish(key: "onboardingQuickStart.title")
        skipButtonTitle = localizationServices.stringForSystemElseEnglish(key: "navigationBar.navigationItem.skip")
        endTutorialButtonTitle = localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.getStartedButton.title")
        quickStartItems = getOnboardingQuickStartItemsUseCase.getOnboardingQuickStartItems()
        numberOfQuickStartItems = quickStartItems.count
    }
    
    private var analyticsScreenName: String {
        return "onboarding-quick-start"
    }
    
    func getQuickStartItemViewModel(index: Int) -> OnboardingQuickStartItemViewModel {
        
        return OnboardingQuickStartItemViewModel(item: quickStartItems[index])
    }
}

// MARK: - Inputs

extension OnboardingQuickStartViewModel {
    
    func quickStartItemTapped(index: Int) {
        
        let item = quickStartItems[index]
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: item.analyticsEventActionName,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
        
        flowDelegate?.navigate(step: item.actionFlowStep)
    }
    
    @objc func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingQuickStart)
    }
    
    func endTutorialTapped() {
        
        flowDelegate?.navigate(step: .endTutorialFromOnboardingQuickStart)
    }
}
