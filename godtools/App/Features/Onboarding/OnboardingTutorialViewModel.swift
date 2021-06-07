//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewModel: OnboardingTutorialViewModelType {
        
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let tutorialItems: ObservableValue<[OnboardingTutorialItem]> = ObservableValue(value: [])
    let skipButtonTitle: String
    let continueButtonTitle: String
    let showMoreButtonTitle: String
    let getStartedButtonTitle: String
        
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, analytics: AnalyticsContainer, onboardingTutorialProvider: OnboardingTutorialProviderType, onboardingTutorialAvailability: OnboardingTutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.openTutorialCalloutCache = openTutorialCalloutCache
        
        skipButtonTitle = localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip")
        continueButtonTitle = localizationServices.stringForMainBundle(key: "onboardingTutorial.continueButton.title")
        showMoreButtonTitle = localizationServices.stringForMainBundle(key: "onboardingTutorial.showMoreButton.title")
        getStartedButtonTitle = localizationServices.stringForMainBundle(key: "onboardingTutorial.getStartedButton.title")
        
        var tutorialItemsArray: [OnboardingTutorialItem] = Array()
        tutorialItemsArray.append(contentsOf: onboardingTutorialProvider.aboutTheAppItems)
        tutorialItemsArray.append(onboardingTutorialProvider.appUsageListItem)
        
        tutorialItems.accept(value: tutorialItemsArray)
                        
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
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: "onboarding", siteSubSection: "", url: nil))
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
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: "On-Boarding More", siteSection: "", siteSubSection: "", url: nil, data: ["cru.onboarding_more": 1]))
    }
    
    func getStartedTapped() {
        flowDelegate?.navigate(step: .getStartedTappedFromOnboardingTutorial)
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: "On-Boarding Start", siteSection: "", siteSubSection: "", url: nil, data: ["cru.onboarding_start": 1]))
    }
}
