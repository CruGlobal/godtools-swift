//
//  OnboardingWelcomeViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingWelcomeViewModel: OnboardingWelcomeViewModelType {
    
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let logo: ObservableValue<UIImage?>
    let title: ObservableValue<String>
    let beginTitle: ObservableValue<String>
        
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        logo = ObservableValue(value: UIImage(named: "onboarding_welcome_logo"))
        title = ObservableValue(value: localizationServices.stringForMainBundle(key: "onboardingWelcome.titleLabel.welcome"))
        beginTitle = ObservableValue(value: localizationServices.stringForMainBundle(key: "onboardingWelcome.beginButton"))
    }
    
    private var analyticsScreenName: String {
        return "onboarding-1"
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: "onboarding", siteSubSection: "", url: nil))
    }
    
    func changeTitleToTagline() {
        title.accept(value: localizationServices.stringForMainBundle(key: "onboardingWelcome.titleLabel.tagline"))
    }
    
    func beginTapped() {
        flowDelegate?.navigate(step: .beginTappedFromOnboardingWelcome)
    }
}
