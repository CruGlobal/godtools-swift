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
    
    private let trackActionAnalytics: TrackActionAnalytics
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, trackActionAnalytics: TrackActionAnalytics) {
        
        title = localizationServices.stringForMainBundle(key: "onboardingQuickStart.title")
        skipButtonTitle = localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip")
        endTutorialButtonTitle = localizationServices.stringForMainBundle(key: "onboardingTutorial.getStartedButton.title")
        
        self.flowDelegate = flowDelegate
        
        self.trackActionAnalytics = trackActionAnalytics
        
        quickStartItems = [
            OnboardingQuickStartItem(
                title: localizationServices.stringForMainBundle(key: "onboardingQuickStart.0.title"),
                linkButtonTitle: localizationServices.stringForMainBundle(key:  "onboardingQuickStart.0.button.title"),
                linkButtonFlowStep: .readArticlesTappedFromOnboardingQuickStart,
                linkButtonAnalyticsAction: AnalyticsConstants.ActionNames.onboardingQuickStartArticles
            ),
            OnboardingQuickStartItem(
                title: localizationServices.stringForMainBundle(key: "onboardingQuickStart.1.title"),
                linkButtonTitle: localizationServices.stringForMainBundle(key:  "onboardingQuickStart.1.button.title"),
                linkButtonFlowStep: .tryLessonsTappedFromOnboardingQuickStart,
                linkButtonAnalyticsAction: AnalyticsConstants.ActionNames.onboardingQuickStartLessons
            ),
            OnboardingQuickStartItem(
                title: localizationServices.stringForMainBundle(key: "onboardingQuickStart.2.title"),
                linkButtonTitle: localizationServices.stringForMainBundle(key:  "onboardingQuickStart.2.button.title"),
                linkButtonFlowStep: .chooseToolTappedFromOnboardingQuickStart,
                linkButtonAnalyticsAction: AnalyticsConstants.ActionNames.onboardingQuickStartTools
            ),
        ]
        
        quickStartItemCount = quickStartItems.count
    }
    
    private var analyticsScreenName: String {
        return "onboarding-quick-start"
    }
    
    func quickStartCellWillAppear(index: Int) -> OnboardingQuickStartCellViewModelType {
        
        return OnboardingQuickStartCellViewModel(item: quickStartItems[index])
    }
    
    func quickStartCellTapped(index: Int) {
        let item = quickStartItems[index]
        
        trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: item.linkButtonAnalyticsAction, siteSection: "", siteSubSection: "", url: nil, data: nil))
        
        flowDelegate?.navigate(step: item.linkButtonFlowStep)
    }
    
    func skipButtonTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingQuickStart)
    }
    
    func endTutorialButtonTapped() {
        
        flowDelegate?.navigate(step: .endTutorialFromOnboardingQuickStart)
    }
}
