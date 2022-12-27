//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 10/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewModel: TutorialPagerViewModel {
    
    private let viewBuilder: CustomViewBuilderType
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    private let localizationServices: LocalizationServices
        
    init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analyticsContainer: AnalyticsContainer, tutorialVideoAnalytics: TutorialVideoAnalytics, onboardingTutorialItemsRepository: OnboardingTutorialItemsRepository, onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository, customViewBuilder: CustomViewBuilderType, localizationServices: LocalizationServices) {
        
        self.viewBuilder = customViewBuilder
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
        self.localizationServices = localizationServices
        
        let tutorialPagerAnalyticsModel = TutorialPagerAnalytics(screenName: "onboarding", siteSection: "onboarding", siteSubsection: "", continueButtonTappedActionName: "Onboarding Start", continueButtonTappedData: [AnalyticsConstants.Keys.onboardingStart: 1], screenTrackIndexOffset: 2)
        
        let tutorialItems: [OnboardingTutorialItemDataModel] = onboardingTutorialItemsRepository.getTutorialItems()
        
        super.init(flowDelegate: flowDelegate, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase, analyticsContainer: analyticsContainer, tutorialVideoAnalytics: tutorialVideoAnalytics,  tutorialItems: tutorialItems, tutorialPagerAnalyticsModel: tutorialPagerAnalyticsModel, skipButtonTitle: localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip"))
        
        onboardingTutorialViewedRepository.storeOnboardingTutorialViewed(viewed: true)
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
