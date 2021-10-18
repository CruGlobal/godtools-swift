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
    
    let tutorialItems: [TutorialItemType]
    let pageCount: Int
    let page: ObservableValue<Int>
    let skipButtonTitle: String
    let skipButtonHidden: ObservableValue<Bool>
    let continueButtonTitle: ObservableValue<String>
    let continueButtonHidden: ObservableValue<Bool>
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, analyticsContainer: AnalyticsContainer,  tutorialItems: [TutorialItemType], skipButtonTitle: String) {
        
        self.flowDelegate = flowDelegate
        self.analyticsContainer = analyticsContainer
        
        self.tutorialItems = tutorialItems
        self.pageCount = tutorialItems.count
        self.page = ObservableValue(value: 0)
        self.skipButtonTitle = skipButtonTitle
        self.skipButtonHidden = ObservableValue(value: false)
        self.continueButtonTitle = ObservableValue(value: "")
        self.continueButtonHidden = ObservableValue(value: false)
    }
    
    var customViewBuilder: CustomViewBuilderType? {
        return nil
    }
    
    var analyticsScreenName: String {
        return ""
    }
    
    var analyticsSiteSection: String {
        return ""
    }
    
    var analyticsSiteSubsection: String {
        return ""
    }
    
    var analyticsActionName: String {
        return ""
    }
    
    var analyticsVideoActionName: String {
        return ""
    }
    
    var navigationStepForSkipTapped: FlowStep? {
        return nil
    }
    
    var navigationStepForContinueTapped: FlowStep? {
        return nil
    }
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
        
        return TutorialCellViewModel(item: tutorialItems[index], customViewBuilder: customViewBuilder, analyticsContainer: analyticsContainer, analyticsScreenName: analyticsScreenName, analyticsSiteSection: analyticsSiteSection, analyticsSiteSubsection: analyticsSiteSubsection, analyticsVideoActionName: analyticsVideoActionName)
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
        
        let reachedEnd = page.value >= pageCount - 1
        
        if reachedEnd, let step = navigationStepForContinueTapped {
            flowDelegate?.navigate(step: step)
            
            trackContinueButtonTapped(page: page.value)
        }
    }
    
    private func trackPageDidAppear (page: Int) {
        
        if !analyticsScreenName.isEmpty {
            analyticsContainer.pageViewedAnalytics.trackPageView(
                trackScreen: TrackScreenModel(
                    screenName: "\(analyticsScreenName)-\(page)",
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubsection
                )
            )
        }
    }
    
    private func trackContinueButtonTapped (page: Int) {
        
        if !analyticsScreenName.isEmpty, !analyticsActionName.isEmpty {
            analyticsContainer.trackActionAnalytics.trackAction(
                trackAction: TrackActionModel(
                    screenName: "\(analyticsScreenName)-\(page)",
                    actionName: analyticsActionName,
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubsection,
                    url: nil,
                    data: ["cru.onboarding_start": 1]
                )
            )
        }
    }
}
