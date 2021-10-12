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
    private let tutorialItems: [TutorialItemType]
    private let customViewBuilder: CustomViewBuilderType
    private let localizationServices: LocalizationServices
    
    private weak var flowDelegate: FlowDelegate?

    let analyticsContainer: AnalyticsContainer
    let analyticsScreenName: String
    let pageCount: Int
    let page: ObservableValue<Int>
    var skipButtonTitle: String
    var skipButtonHidden: ObservableValue<Bool>
    var continueButtonTitle: ObservableValue<String>
    var continueButtonHidden: ObservableValue<Bool>
    var pageControlHidden: ObservableValue<Bool>
    
    required init(flowDelegate: FlowDelegate, analyticsContainer: AnalyticsContainer, tutorialPagerProvider: TutorialPagerProviderType, onboardingTutorialAvailability: OnboardingTutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, customViewBuilder: CustomViewBuilderType, localizationServices: LocalizationServices, analyticsScreenName: String, skipButtonTitle: String) {
        
        self.flowDelegate = flowDelegate
        self.analyticsContainer = analyticsContainer
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.customViewBuilder = customViewBuilder
        self.localizationServices = localizationServices
        self.analyticsScreenName = analyticsScreenName
        self.pageCount = tutorialPagerProvider.tutorialItems.count
        self.page = ObservableValue(value: 0)
        self.skipButtonTitle = skipButtonTitle
        self.skipButtonHidden = ObservableValue(value: false)
        self.continueButtonTitle = ObservableValue(value: "")
        self.continueButtonHidden = ObservableValue(value: false)
        self.pageControlHidden = ObservableValue(value: false)
        self.tutorialItems = tutorialPagerProvider.tutorialItems
        
        onboardingTutorialAvailability.markOnboardingTutorialViewed()
    }
}

// MARK: - TutorialPagerViewModelType

extension TutorialPagerViewModel: TutorialPagerViewModelType {
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
         return TutorialCellViewModel(item: tutorialItems[index], customViewBuilder: customViewBuilder)
    }

    func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    func pageDidChange(page: Int) {
        
        self.page.accept(value: page)
    }
    
    func pageDidAppear(page: Int) {
        
        self.page.accept(value: page)
        
        switch page {
        case 0:
            continueButtonTitle.accept(value: localizationServices.stringForMainBundle(key: "onboardingTutorial.beginButton.title"))
       
        default:
            continueButtonTitle.accept(value: localizationServices.stringForMainBundle(key: "onboardingTutorial.nextButton.title"))
        }
        
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
