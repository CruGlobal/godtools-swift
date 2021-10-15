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
    
    required init(analyticsContainer: AnalyticsContainer,  tutorialItems: [TutorialItemType], skipButtonTitle: String) {
        
        self.analyticsContainer = analyticsContainer
        
        self.tutorialItems = tutorialItems
        
        self.pageCount = tutorialItems.count
        self.page = ObservableValue(value: 0)
        self.skipButtonTitle = skipButtonTitle
        self.skipButtonHidden = ObservableValue(value: false)
        self.continueButtonTitle = ObservableValue(value: "")
        self.continueButtonHidden = ObservableValue(value: false)
    }
    
    private var analyticsScreenName: String {
        return "tutorial"
    }
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
        return TutorialCellViewModel(item: tutorialItems[index], customViewBuilder: nil)
    }
    
    func skipTapped() {
        //Implement this
    }
    
    func pageDidChange(page: Int) {
        
        self.page.accept(value: page)
    }
    
    func pageDidAppear(page: Int) {
        
        self.page.accept(value: page)
        
        trackPageDidAppear(page: page)
    }
    
    func continueTapped() {
        
        trackContinueButtonTapped(page: page.value)
    }
    
    private func trackPageDidAppear (page: Int) {
        analyticsContainer.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: "\(analyticsScreenName)-\(page)", siteSection: "onboarding", siteSubSection: ""))
    }
    
    private func trackContinueButtonTapped (page: Int) {
        
        let nextPage = page + 1
        let reachedEnd = nextPage >= pageCount
        
        if reachedEnd {
            analyticsContainer.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: "\(analyticsScreenName)-\(page)", actionName: "On-Boarding Start", siteSection: "", siteSubSection: "", url: nil, data: ["cru.onboarding_start": 1]))
        }
    }
}
