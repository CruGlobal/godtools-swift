//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialViewModel: TutorialViewModelType {
    //TODO: re-implement this tutorial using TutorialPagerViewModel
    
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let tutorialPagerAnalyticsModel: TutorialPagerAnalytics
    
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let customViewBuilder: CustomViewBuilderType
    let tutorialItems: ObservableValue<[TutorialItemType]> = ObservableValue(value: [])
    let continueTitle: String
    let startUsingGodToolsTitle: String
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, analytics: AnalyticsContainer, tutorialItemsProvider: TutorialItemProviderType, deviceLanguage: DeviceLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.customViewBuilder = TutorialItemViewBuilder(deviceLanguage: deviceLanguage)
        self.continueTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        self.startUsingGodToolsTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.startUsingGodTools")
        
        tutorialItems.accept(value: tutorialItemsProvider.tutorialItems)
        
        tutorialPagerAnalyticsModel = TutorialPagerAnalytics(screenName: "tutorial", siteSection: "tutorial", siteSubsection: "", continueButtonTappedActionName: "", continueButtonTappedData: nil)
    }
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
        
        return TutorialCellViewModel(item: tutorialItems.value[index], customViewBuilder: customViewBuilder, analyticsContainer: analytics, analyticsScreenName: tutorialPagerAnalyticsModel.screenName)
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromTutorial)
    }
    
    func pageDidChange(page: Int) {
                
        self.page = page
    }
    
    func pageDidAppear(page: Int) {
                    
        let isFirstPage: Bool = page == 0
        let isLastPage: Bool = page == tutorialItems.value.count - 1
        
        self.page = page
        
        let trackedScreenName = "\(tutorialPagerAnalyticsModel.screenName)-\(page + 1)"
        
        let trackScreenData = TrackScreenModel(screenName: trackedScreenName, siteSection: tutorialPagerAnalyticsModel.siteSection, siteSubSection: tutorialPagerAnalyticsModel.siteSubsection)
        let trackActionData = TrackActionModel(screenName: trackedScreenName, actionName: trackedScreenName, siteSection: tutorialPagerAnalyticsModel.siteSection, siteSubSection: tutorialPagerAnalyticsModel.siteSubsection, url: nil, data: nil)
        
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
        let reachedEnd: Bool = nextPage >= tutorialItems.value.count
        
        if reachedEnd {
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
        }
    }
}
