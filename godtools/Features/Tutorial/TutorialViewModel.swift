//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialViewModel: TutorialViewModelType {
    
    private let analytics: AnalyticsContainer
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let deviceLanguage: DeviceLanguageType
    let hidesBackButton: ObservableValue<Bool> = ObservableValue(value: true)
    let tutorialItems: ObservableValue<[TutorialItem]> = ObservableValue(value: [])
    let changePage: SignalValue<Int> = SignalValue()
    let continueButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, analytics: AnalyticsContainer, tutorialItemsProvider: TutorialItemProviderType, deviceLanguage: DeviceLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        self.deviceLanguage = deviceLanguage
        
        tutorialItems.accept(value: tutorialItemsProvider.tutorialItems)
        
        pageDidAppear(page: 0)
    }
    
    private var analyticsScreenName: String {
        return "tutorial-\(page + 1)"
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromTutorial)
    }
    
    func pageDidAppear(page: Int) {
                    
        let isFirstPage: Bool = page == 0
        let isLastPage: Bool = page == tutorialItems.value.count - 1
        
        self.page = page
        
        hidesBackButton.accept(value: page == 0)
        
        if isLastPage {
            continueButtonTitle.accept(value: NSLocalizedString("tutorial.continueButton.title.startUsingGodTools", comment: ""))
        }
        else {
            continueButtonTitle.accept(value: NSLocalizedString("tutorial.continueButton.title.continue", comment: ""))
        }
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: analyticsScreenName,
            siteSection: "tutorial",
            siteSubSection: ""
        )
        
        if isFirstPage {
            analytics.appsFlyer.trackEvent(eventName: analyticsScreenName, data: nil)
        }
        else if isLastPage {
            analytics.appsFlyer.trackEvent(eventName: analyticsScreenName, data: nil)
        }
    }
    
    func continueTapped() {
        
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= tutorialItems.value.count
        
        if reachedEnd {
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
        }
    }
    
    func tutorialVideoPlayTapped() {
        
        let tutorialItem: TutorialItem = tutorialItems.value[page]
        
        guard let youTubeVideoId = tutorialItem.youTubeVideoId else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(youTubeVideoId)
        
        if !youTubeVideoTracked {
            trackedAnalyticsForYouTubeVideoIds.append(youTubeVideoId)
            analytics.trackActionAnalytics.trackAction(screenName: analyticsScreenName, actionName: "Tutorial Video", data: ["cru.tutorial_video": 1, "video_id": youTubeVideoId])
        }
    }
}
