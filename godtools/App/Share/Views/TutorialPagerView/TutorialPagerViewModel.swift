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
    
    private weak var flowDelegate: FlowDelegate?

    let analyticsContainer: AnalyticsContainer
    let analyticsScreenName: String
    let pageCount: Int
    let page: ObservableValue<Int>
    var skipButtonTitle: String
    var skipButtonHidden: ObservableValue<Bool>
    var continueButtonTitle: ObservableValue<String>
    var footerHidden: ObservableValue<Bool>
    
    required init(flowDelegate: FlowDelegate, analyticsContainer: AnalyticsContainer, tutorialPagerProvider: TutorialPagerProviderType, onboardingTutorialAvailability: OnboardingTutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, customViewBuilder: CustomViewBuilderType, analyticsScreenName: String, skipButtonTitle: String) {
        
        self.flowDelegate = flowDelegate
        self.analyticsContainer = analyticsContainer
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.customViewBuilder = customViewBuilder
        self.analyticsScreenName = analyticsScreenName
        self.pageCount = tutorialPagerProvider.tutorialItems.count
        self.page = ObservableValue(value: 0)
        self.skipButtonTitle = skipButtonTitle
        self.skipButtonHidden = ObservableValue(value: false)
        self.continueButtonTitle = ObservableValue(value: "")
        self.footerHidden = ObservableValue(value: false)
        self.tutorialItems = tutorialPagerProvider.tutorialItems
        
        onboardingTutorialAvailability.markOnboardingTutorialViewed()
    }
}

// MARK: - TutorialPagerViewModelType

extension TutorialPagerViewModel: TutorialPagerViewModelType {
    
    func tutorialItemWillAppear(index: Int) -> TutorialPagerCellViewModelType {
        return TutorialPagerCellViewModel(item: tutorialItems[page.value], customViewBuilder: customViewBuilder)
    }

    func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    func pageDidChange(page: Int) {
        
        self.page.accept(value: page)
    }
    
    func pageDidAppear(page: Int) {
        
        self.page.accept(value: page)
        
        let item = tutorialItems[page]

        skipButtonHidden.accept(value: item.hideSkip)
        continueButtonTitle.accept(value: item.continueButtonLabel)
        footerHidden.accept(value: item.hideFooter)
        
        trackPageDidAppear(page: page)
    }
    
    func continueTapped() {
        
        let nextPage = page.value + 1
        let reachedEnd = nextPage >= pageCount
        
        if reachedEnd {
            flowDelegate?.navigate(step: .endTutorialFromOnboardingTutorial)
        }
        
        trackContinueButtonTapped(page: page.value)
    }
    
    func tutorialVideoPlayTapped() {
        
        guard let youTubeVideoId = tutorialItems[page.value].youTubeVideoId else {
            return
        }
        
        trackVideoWatched(videoId: youTubeVideoId)
    }

}
