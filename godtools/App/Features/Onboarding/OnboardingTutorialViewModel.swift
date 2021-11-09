//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 10/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewModel: TutorialPagerViewModel {
    
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let viewBuilder: CustomViewBuilderType
    private let localizationServices: LocalizationServices
        
    required init(flowDelegate: FlowDelegate, animationCache: AnimationCache, analyticsContainer: AnalyticsContainer, onboardingTutorialItemsRepository: OnboardingTutorialItemsRepositoryType, onboardingTutorialAvailability: OnboardingTutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, customViewBuilder: CustomViewBuilderType, localizationServices: LocalizationServices) {
        
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.viewBuilder = customViewBuilder
        self.localizationServices = localizationServices
        
        let tutorialPagerAnalyticsModel = TutorialPagerAnalytics(screenName: "onboarding", siteSection: "onboarding", siteSubsection: "", continueButtonTappedActionName: "On-Boarding Start", continueButtonTappedData: ["cru.onboarding_start": 1], screenTrackIndexOffset: 2)
        
        super.init(flowDelegate: flowDelegate, animationCache: animationCache, analyticsContainer: analyticsContainer,  tutorialItems: onboardingTutorialItemsRepository.tutorialItems, tutorialPagerAnalyticsModel: tutorialPagerAnalyticsModel, skipButtonTitle: localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip"))
        
        onboardingTutorialAvailability.markOnboardingTutorialViewed()
    }
    
    required init(flowDelegate: FlowDelegate, animationCache: AnimationCache, analyticsContainer: AnalyticsContainer, tutorialItems: [TutorialItemType], tutorialPagerAnalyticsModel: TutorialPagerAnalytics, skipButtonTitle: String) {
        fatalError("init(flowDelegate:animationCache:analyticsContainer:tutorialItems:tutorialPagerAnalyticsModel:skipButtonTitle:) has not been implemented")
    }
    
    override var customViewBuilder: CustomViewBuilderType? {
        return viewBuilder
    }
    
    override var navigationStepForSkipTapped: FlowStep? {
        return .skipTappedFromOnboardingTutorial
    }
    
    override var navigationStepForContinueTapped: FlowStep? {
        return .endTutorialFromOnboardingTutorial
    }
    
    override func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
        
        super.tutorialItemWillAppear(index: index)
    }
    
    override func skipTapped() {
        
        super.skipTapped()
    }
    
    override func pageDidChange(page: Int) {
                
        switch page {
        case 0:
            skipButtonHidden.accept(value: true)
            continueButtonTitle.accept(value: localizationServices.stringForMainBundle(key: "onboardingTutorial.beginButton.title"))
       
        default:
            skipButtonHidden.accept(value: false)
            continueButtonTitle.accept(value: localizationServices.stringForMainBundle(key: "onboardingTutorial.nextButton.title"))
        }
        
        super.pageDidChange(page: page)
    }
    
    override func continueTapped() {
        
        super.continueTapped()
    }
}
