//
//  OnboardingQuickStartViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class OnboardingQuickStartViewModel: OnboardingQuickStartViewModelType {
    
    private let quickStartItems: [OnboardingQuickStartItem]
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let trackActionAnalytics: TrackActionAnalytics
    
    private weak var flowDelegate: FlowDelegate?
    
    let title: String
    let skipButtonTitle: String
    let endTutorialButtonTitle: String
    let quickStartItemCount: Int
    
    init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, trackActionAnalytics: TrackActionAnalytics) {
        
        title = localizationServices.stringForMainBundle(key: "onboardingQuickStart.title")
        skipButtonTitle = localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip")
        endTutorialButtonTitle = localizationServices.stringForMainBundle(key: "onboardingTutorial.getStartedButton.title")
        
        self.flowDelegate = flowDelegate
        
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
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
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: item.linkButtonAnalyticsAction,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: nil
        )
        
        trackActionAnalytics.trackAction(trackAction: trackAction)
        
        flowDelegate?.navigate(step: item.linkButtonFlowStep)
    }
    
    func skipButtonTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingQuickStart)
    }
    
    func endTutorialButtonTapped() {
        
        flowDelegate?.navigate(step: .endTutorialFromOnboardingQuickStart)
    }
}
