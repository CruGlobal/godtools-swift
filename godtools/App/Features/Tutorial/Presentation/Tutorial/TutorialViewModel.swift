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
    private let localizationServices: LocalizationServices
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let analytics: AnalyticsContainer
    private let tutorialPagerAnalyticsModel: TutorialPagerAnalytics
    
    private var tutorialModel: TutorialModel = TutorialModel(tutorialItems: [])
    
    private weak var flowDelegate: FlowDelegate?
    
    let hidesBackButton: ObservableValue<Bool> = ObservableValue(value: false)
    let currentPage: ObservableValue<Int> = ObservableValue(value: 0)
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let continueTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, getTutorialUseCase: GetTutorialUseCase, localizationServices: LocalizationServices, analytics: AnalyticsContainer, tutorialVideoAnalytics: TutorialVideoAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.getTutorialUseCase = getTutorialUseCase
        self.localizationServices = localizationServices
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
        
        getTutorial()
    }
    
    private func getTutorial() {
        
        tutorialModel = getTutorialUseCase.getTutorial()
        numberOfPages.accept(value: tutorialModel.tutorialItems.count)
    }
    
    func tutorialPageWillAppear(index: Int) -> TutorialCellViewModelType {
        
        return TutorialCellViewModel(
            item: tutorialModel.tutorialItems[index],
            customViewBuilder: nil,
            tutorialVideoAnalytics: tutorialVideoAnalytics,
            analyticsScreenName: tutorialPagerAnalyticsModel.analyticsScreenName(page: index)
        )
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromTutorial)
    }
    
    func pageDidChange(page: Int) {
                  
        currentPage.accept(value: page)
        
        let isFirstPage: Bool = page == 0
        let isOnLastPage: Bool = page >= tutorialModel.tutorialItems.count - 1
        
        hidesBackButton.accept(value: isFirstPage)
                
        let continueTitleKey: String
        if isOnLastPage {
            continueTitleKey = "tutorial.continueButton.title.startUsingGodTools"
        }
        else {
            continueTitleKey = "tutorial.continueButton.title.continue"
        }
        
        continueTitle.accept(value: localizationServices.stringForMainBundle(key: continueTitleKey))
    }
    
    func pageDidAppear(page: Int) {
                    
        let isFirstPage: Bool = page == 0
        let isLastPage: Bool = page == tutorialModel.tutorialItems.count - 1
                
        currentPage.accept(value: page)
        
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
        
        let nextPage: Int = currentPage.value + 1
        let reachedEnd: Bool = nextPage >= tutorialModel.tutorialItems.count
        
        if reachedEnd {
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
        }
    }
}
