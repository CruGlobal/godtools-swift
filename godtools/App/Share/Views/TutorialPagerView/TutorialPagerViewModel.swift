//
//  TutorialPagerViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 10/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TutorialPagerViewModel: TutorialPagerViewModelType {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analyticsContainer: AnalyticsContainer
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let tutorialPagerAnalyticsModel: TutorialPagerAnalytics
    
    let tutorialItems: [TutorialItemType]
    let pageCount: ObservableValue<Int>
    let page: ObservableValue<Int>
    let skipButtonTitle: String
    let skipButtonHidden: ObservableValue<Bool>
    let continueButtonTitle: ObservableValue<String>
    let continueButtonHidden: ObservableValue<Bool>
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analyticsContainer: AnalyticsContainer, tutorialVideoAnalytics: TutorialVideoAnalytics, tutorialItems: [TutorialItemType], tutorialPagerAnalyticsModel: TutorialPagerAnalytics, skipButtonTitle: String) {
        
        self.flowDelegate = flowDelegate
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analyticsContainer = analyticsContainer
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
        self.tutorialPagerAnalyticsModel = tutorialPagerAnalyticsModel
        
        self.tutorialItems = tutorialItems
        self.pageCount = ObservableValue(value: tutorialItems.count)
        self.page = ObservableValue(value: 0)
        self.skipButtonTitle = skipButtonTitle
        self.skipButtonHidden = ObservableValue(value: false)
        self.continueButtonTitle = ObservableValue(value: "")
        self.continueButtonHidden = ObservableValue(value: false)
    }
    
    var customViewBuilder: CustomViewBuilderType? {
        return nil
    }
    
    var navigationStepForSkipTapped: FlowStep? {
        return nil
    }
    
    var navigationStepForContinueTapped: FlowStep? {
        return nil
    }
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
        
        return TutorialCellViewModel(
            item: tutorialItems[index],
            customViewBuilder: customViewBuilder,
            tutorialVideoAnalytics: tutorialVideoAnalytics,
            analyticsScreenName: tutorialPagerAnalyticsModel.analyticsScreenName(page: index),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase
        )
    }
    
    func skipTapped() {
        
        if let step = navigationStepForSkipTapped {
            flowDelegate?.navigate(step: step)
        }
    }
    
    func pageDidChange(page: Int) {
        
        self.page.accept(value: page)
    }
    
    func pageDidAppear(page: Int) {
        
        self.page.accept(value: page)
        
        trackPageDidAppear(page: page)
    }
    
    func continueTapped() {
        
        let reachedEnd = page.value >= pageCount.value - 1
        
        if reachedEnd, let step = navigationStepForContinueTapped {
            flowDelegate?.navigate(step: step)
            
            trackContinueButtonTapped(page: page.value)
        }
    }
    
    private func trackPageDidAppear (page: Int) {
        
        let analyticsScreenName = tutorialPagerAnalyticsModel.analyticsScreenName(page: page)
        
        if !analyticsScreenName.isEmpty {
            
            let trackScreen = TrackScreenModel(
                screenName: analyticsScreenName,
                siteSection: tutorialPagerAnalyticsModel.siteSection,
                siteSubSection: tutorialPagerAnalyticsModel.siteSubsection,
                contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
                secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
            )
            
            analyticsContainer.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
        }
    }
    
    private func trackContinueButtonTapped (page: Int) {
        
        let analyticsScreenName = tutorialPagerAnalyticsModel.analyticsScreenName(page: page)
        
        if !analyticsScreenName.isEmpty, !tutorialPagerAnalyticsModel.continueButtonTappedActionName.isEmpty {
            
            let trackAction = TrackActionModel(
                screenName: analyticsScreenName,
                actionName: tutorialPagerAnalyticsModel.continueButtonTappedActionName,
                siteSection: tutorialPagerAnalyticsModel.siteSection,
                siteSubSection: tutorialPagerAnalyticsModel.siteSubsection,
                contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
                secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
                url: nil,
                data: tutorialPagerAnalyticsModel.continueButtonTappedData
            )
            
            analyticsContainer.trackActionAnalytics.trackAction(trackAction: trackAction)
        }
    }
}
