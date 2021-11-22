//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialViewModel: TutorialViewModelType {
        
    private let getTutorialItemsUseCase: GetTutorialItemsUseCase
    private let localizationServices: LocalizationServices
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let analytics: AnalyticsContainer
    private let tutorialPagerAnalyticsModel: TutorialPagerAnalytics
    private let customViewBuilder: TutorialItemViewBuilder
    
    private var tutorialItems: [TutorialItemType] = Array()
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let numberOfTutorialItems: ObservableValue<Int> = ObservableValue(value: 0)
    let continueTitle: String
    let startUsingGodToolsTitle: String
    
    required init(flowDelegate: FlowDelegate, getTutorialItemsUseCase: GetTutorialItemsUseCase, localizationServices: LocalizationServices, analytics: AnalyticsContainer, tutorialVideoAnalytics: TutorialVideoAnalytics, deviceLanguage: DeviceLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.getTutorialItemsUseCase = getTutorialItemsUseCase
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
        self.customViewBuilder = TutorialItemViewBuilder(deviceLanguage: deviceLanguage)
        self.continueTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        self.startUsingGodToolsTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.startUsingGodTools")
                
        tutorialPagerAnalyticsModel = TutorialPagerAnalytics(
            screenName: "tutorial",
            siteSection: "tutorial",
            siteSubsection: "",
            continueButtonTappedActionName: "",
            continueButtonTappedData: nil,
            screenTrackIndexOffset: 1
        )
        
        getTutorialItems()
    }
    
    private func getTutorialItems() {
        
        tutorialItems = getTutorialItemsUseCase.getTutorialItems()
        numberOfTutorialItems.accept(value: tutorialItems.count)
    }
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
        
        return TutorialCellViewModel(
            item: tutorialItems[index],
            customViewBuilder: customViewBuilder,
            tutorialVideoAnalytics: tutorialVideoAnalytics,
            analyticsScreenName: tutorialPagerAnalyticsModel.analyticsScreenName(page: index)
        )
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromTutorial)
    }
    
    func pageDidChange(page: Int) {
                
        self.page = page
    }
    
    func pageDidAppear(page: Int) {
                    
        let isFirstPage: Bool = page == 0
        let isLastPage: Bool = page == tutorialItems.count - 1
        
        self.page = page
        
        let analyticsScreenName = tutorialPagerAnalyticsModel.analyticsScreenName(page: page)
        
        let trackScreenData = TrackScreenModel(screenName: analyticsScreenName, siteSection: tutorialPagerAnalyticsModel.siteSection, siteSubSection: tutorialPagerAnalyticsModel.siteSubsection)
        let trackActionData = TrackActionModel(screenName: analyticsScreenName, actionName: analyticsScreenName, siteSection: tutorialPagerAnalyticsModel.siteSection, siteSubSection: tutorialPagerAnalyticsModel.siteSubsection, url: nil, data: nil)
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreenData)
        
        if isFirstPage {
            analytics.appsFlyerAnalytics.trackAction(actionName: trackActionData.actionName, data: trackActionData.data)
        }
        else if isLastPage {
            analytics.appsFlyerAnalytics.trackAction(actionName: trackActionData.actionName, data: trackActionData.data)
        }
    }
    
    func continueTapped() {
        
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= tutorialItems.count
        
        if reachedEnd {
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
        }
    }
}
