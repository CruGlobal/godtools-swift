//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewModel: OnboardingTutorialViewModelType {
        
    private let analytics: AnalyticsContainer
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let tutorialItems: ObservableValue<[OnboardingTutorialItem]> = ObservableValue(value: [])
    let skipButtonTitle: String = NSLocalizedString("navigationBar.navigationItem.skip", comment: "")
    let continueButtonTitle: String = NSLocalizedString("onboardingTutorial.continueButton.title", comment: "")
    let showMoreButtonTitle: String = NSLocalizedString("onboardingTutorial.showMoreButton.title", comment: "")
    let getStartedButtonTitle: String = NSLocalizedString("onboardingTutorial.getStartedButton.title", comment: "")
        
    required init(flowDelegate: FlowDelegate, analytics: AnalyticsContainer, onboardingTutorialProvider: OnboardingTutorialProviderType, onboardingTutorialAvailability: OnboardingTutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        self.openTutorialCalloutCache = openTutorialCalloutCache
        
        var tutorialItemsArray: [OnboardingTutorialItem] = Array()
        tutorialItemsArray.append(contentsOf: onboardingTutorialProvider.aboutTheAppItems)
        tutorialItemsArray.append(onboardingTutorialProvider.appUsageListItem)
        
        tutorialItems.accept(value: tutorialItemsArray)
                
        pageDidChange(page: 0)
        pageDidAppear(page: 0)
        
        onboardingTutorialAvailability.markOnboardingTutorialViewed()
    }
    
    private var analyticsScreenName: String {
        return "onboarding-\(page + 2)"
    }
    
    func skipTapped() {
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    func pageDidChange(page: Int) {
                
        self.page = page
    }
    
    func pageDidAppear(page: Int) {
        
        self.page = page
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: analyticsScreenName,
            siteSection: "onboarding",
            siteSubSection: ""
        )
    }
    
    func continueTapped() {
                
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= tutorialItems.value.count
        
        if reachedEnd {
            flowDelegate?.navigate(step: .getStartedTappedFromOnboardingTutorial)
        }
    }
    
    func showMoreTapped() {
        openTutorialCalloutCache.disableOpenTutorialCallout()
        flowDelegate?.navigate(step: .showMoreTappedFromOnboardingTutorial)
        
        analytics.trackActionAnalytics.trackAction(screenName: analyticsScreenName, actionName: "On-Boarding More", data: ["cru.onboarding_more": 1])
    }
    
    func getStartedTapped() {
        flowDelegate?.navigate(step: .getStartedTappedFromOnboardingTutorial)
        
        analytics.trackActionAnalytics.trackAction(screenName: analyticsScreenName, actionName: "On-Boarding Start", data: ["cru.onboarding_start": 1])
    }
}
