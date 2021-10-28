//
//  TutorialPagerViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 10/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TutorialPagerViewModel: TutorialPagerViewModelType {
    
    private let analyticsContainer: AnalyticsContainer
    private let tutorialPagerAnalyticsModel: TutorialPagerAnalytics
    
    let tutorialItems: [TutorialItemType]
    let pageCount: ObservableValue<Int>
    let page: ObservableValue<Int>
    let skipButtonTitle: String
    let skipButtonHidden: ObservableValue<Bool>
    let continueButtonTitle: ObservableValue<String>
    let continueButtonHidden: ObservableValue<Bool>
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, analyticsContainer: AnalyticsContainer,  tutorialItems: [TutorialItemType], tutorialPagerAnalyticsModel: TutorialPagerAnalytics, skipButtonTitle: String) {
        
        self.flowDelegate = flowDelegate
        self.analyticsContainer = analyticsContainer
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
        
        return TutorialCellViewModel(item: tutorialItems[index], customViewBuilder: customViewBuilder, analyticsContainer: analyticsContainer, analyticsScreenName: buildAnalyticsScreenName(page: index))
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
    
    private func buildAnalyticsScreenName(page: Int) -> String {
        return "\(tutorialPagerAnalyticsModel.screenName)-\(page + tutorialPagerAnalyticsModel.screenTrackIndexOffset)"
    }
    
    private func trackPageDidAppear (page: Int) {
        
        if !tutorialPagerAnalyticsModel.screenName.isEmpty {
            analyticsContainer.pageViewedAnalytics.trackPageView(
                trackScreen: TrackScreenModel(
                    screenName: buildAnalyticsScreenName(page: page),
                    siteSection: tutorialPagerAnalyticsModel.siteSection,
                    siteSubSection: tutorialPagerAnalyticsModel.siteSubsection
                )
            )
        }
    }
    
    private func trackContinueButtonTapped (page: Int) {
        
        if !tutorialPagerAnalyticsModel.screenName.isEmpty, !tutorialPagerAnalyticsModel.continueButtonTappedActionName.isEmpty {
            analyticsContainer.trackActionAnalytics.trackAction(
                trackAction: TrackActionModel(
                    screenName: buildAnalyticsScreenName(page: page),
                    actionName: tutorialPagerAnalyticsModel.continueButtonTappedActionName,
                    siteSection: tutorialPagerAnalyticsModel.siteSection,
                    siteSubSection: tutorialPagerAnalyticsModel.siteSubsection,
                    url: nil,
                    data: tutorialPagerAnalyticsModel.continueButtonTappedData
                )
            )
        }
    }
}
