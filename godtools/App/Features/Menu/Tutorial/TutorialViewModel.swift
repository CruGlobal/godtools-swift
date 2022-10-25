//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialViewModel: TutorialViewModelType {
        
    private let getTutorialUseCase: GetTutorialUseCase
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    private let tutorialPagerAnalyticsModel: TutorialPagerAnalytics
    
    private var tutorialModel: TutorialModel?
    
    private weak var flowDelegate: FlowDelegate?
    
    let hidesBackButton: ObservableValue<Bool> = ObservableValue(value: false)
    let currentPage: ObservableValue<Int> = ObservableValue(value: 0)
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let continueTitle: ObservableValue<String> = ObservableValue(value: "")
    
    init(flowDelegate: FlowDelegate, getTutorialUseCase: GetTutorialUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer, tutorialVideoAnalytics: TutorialVideoAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.getTutorialUseCase = getTutorialUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
                
        tutorialPagerAnalyticsModel = TutorialPagerAnalytics(
            screenName: "tutorial",
            siteSection: "tutorial",
            siteSubsection: "",
            continueButtonTappedActionName: "",
            continueButtonTappedData: nil,
            screenTrackIndexOffset: 1
        )
        
        reloadTutorial(tutorial: getTutorialUseCase.getTutorial())
    }
    
    private func reloadTutorial(tutorial: TutorialModel) {
        
        self.tutorialModel = tutorial
        numberOfPages.accept(value: tutorial.tutorialItems.count)
    }
    
    private var tutorialItems: [TutorialItemType] {
        return tutorialModel?.tutorialItems ?? []
    }
    
    func tutorialPageWillAppear(index: Int) -> TutorialCellViewModelType {
        
        return TutorialCellViewModel(
            item: tutorialItems[index],
            customViewBuilder: nil,
            tutorialVideoAnalytics: tutorialVideoAnalytics,
            analyticsScreenName: tutorialPagerAnalyticsModel.analyticsScreenName(page: index),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase
        )
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromTutorial)
    }
    
    func pageDidChange(page: Int) {
                  
        currentPage.accept(value: page)
        
        let isFirstPage: Bool = page == 0
        let isOnLastPage: Bool = page >= tutorialItems.count - 1
        
        hidesBackButton.accept(value: isFirstPage)
                
        let continueTitleValue: String
        if isOnLastPage {
            continueTitleValue = tutorialModel?.lastPageContinueButtonTitle ?? ""
        }
        else {
            continueTitleValue = tutorialModel?.defaultContinueButtonTitle ?? ""
        }
        
        continueTitle.accept(value: continueTitleValue)
    }
    
    func pageDidAppear(page: Int) {
                    
        let isFirstPage: Bool = page == 0
        let isLastPage: Bool = page == tutorialItems.count - 1
                
        currentPage.accept(value: page)
        
        let analyticsScreenName = tutorialPagerAnalyticsModel.analyticsScreenName(page: page)
        let analyticsSiteSection = tutorialPagerAnalyticsModel.siteSection
        let analyticsSiteSubSection = tutorialPagerAnalyticsModel.siteSubsection
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
                
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: nil
        )
        
        if isFirstPage {
            analytics.appsFlyerAnalytics.trackAction(actionName: trackAction.actionName, data: trackAction.data)
        }
        else if isLastPage {
            analytics.appsFlyerAnalytics.trackAction(actionName: trackAction.actionName, data: trackAction.data)
        }
    }
    
    func continueTapped() {
        
        let nextPage: Int = currentPage.value + 1
        let reachedEnd: Bool = nextPage >= tutorialItems.count
        
        if reachedEnd {
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
        }
    }
}
