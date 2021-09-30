//
//  TutorialPagerViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 9/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TutorialPagerViewModel {
    
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let tutorialItems: [TutorialPagerItem]
    private let customViewBuilder: CustomViewBuilderType
    
    private var page: Int = 0

    private weak var flowDelegate: FlowDelegate?

    let analyticsContainer: AnalyticsContainer
    let analyticsScreenName: String
    let pageCount: Int
    let skipButtonTitle: String
    let continueButtonTitle: ObservableValue<String>
    
    required init(flowDelegate: FlowDelegate, analyticsContainer: AnalyticsContainer, tutorialPagerProvider: TutorialPagerProviderType, onboardingTutorialAvailability: OnboardingTutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, customViewBuilder: CustomViewBuilderType, analyticsScreenName: String, skipButtonTitle: String, continueButtonTitle: String) {
        
        self.flowDelegate = flowDelegate
        self.analyticsContainer = analyticsContainer
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.customViewBuilder = customViewBuilder
        self.analyticsScreenName = analyticsScreenName
        self.pageCount = tutorialPagerProvider.tutorialItems.count
        self.skipButtonTitle = skipButtonTitle
        self.continueButtonTitle = ObservableValue(value: continueButtonTitle)
        self.tutorialItems = tutorialPagerProvider.tutorialItems
        
        onboardingTutorialAvailability.markOnboardingTutorialViewed()
    }
}

// MARK: - TutorialPagerViewModelType

extension TutorialPagerViewModel: TutorialPagerViewModelType {
    
    func tutorialItemWillAppear(index: Int) -> TutorialPagerCellViewModelType {
        return TutorialPagerCellViewModel(item: tutorialItems[page], customViewBuilder: customViewBuilder)
    }

    func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    func pageDidChange(page: Int) {
        
        self.page = page
    }
    
    func pageDidAppear(page: Int) {
        
        self.page = page
        
        continueButtonTitle.accept(value: tutorialItems[page].continueButtonLabel)
        
        trackPageDidAppear(page: page)
    }
    
    func continueTapped() {
        
        let nextPage = page + 1
        let reachedEnd = nextPage >= pageCount
        
        if reachedEnd {
            flowDelegate?.navigate(step: .endTutorialFromOnboardingTutorial)
        }
        
        trackContinueButtonTapped(page: page)
    }
    
    func tutorialVideoPlayTapped() {
        
        guard let youTubeVideoId = tutorialItems[page].youTubeVideoId else {
            return
        }
        
        trackVideoWatched(videoId: youTubeVideoId)
    }

}
