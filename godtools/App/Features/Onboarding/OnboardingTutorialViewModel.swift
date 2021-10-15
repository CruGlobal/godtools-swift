//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 10/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewModel {
    
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
    
    required init(flowDelegate: FlowDelegate, analyticsContainer: AnalyticsContainer, onboardingTutorialItemsRepository: OnboardingTutorialItemsRepositoryType, onboardingTutorialAvailability: OnboardingTutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, customViewBuilder: CustomViewBuilderType, localizationServices: LocalizationServices, analyticsScreenName: String, skipButtonTitle: String) {
        
        self.flowDelegate = flowDelegate
        self.analyticsContainer = analyticsContainer
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.customViewBuilder = customViewBuilder
        self.localizationServices = localizationServices
        self.analyticsScreenName = analyticsScreenName
        self.pageCount = onboardingTutorialItemsRepository.tutorialItems.count
        self.page = ObservableValue(value: 0)
        self.skipButtonTitle = skipButtonTitle
        self.skipButtonHidden = ObservableValue(value: false)
        self.continueButtonTitle = ObservableValue(value: "")
        self.continueButtonHidden = ObservableValue(value: false)
        self.tutorialItems = onboardingTutorialItemsRepository.tutorialItems
        
        onboardingTutorialAvailability.markOnboardingTutorialViewed()
    }
}


// MARK: - TutorialPagerViewModelType

extension OnboardingTutorialViewModel: TutorialPagerViewModelType {
    
    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
         return TutorialCellViewModel(item: tutorialItems[index], customViewBuilder: customViewBuilder)
    }

    func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    func pageDidChange(page: Int) {
        
        onPageDidChange(page: page)
    }
    
    func pageDidAppear(page: Int) {
                
        switch page {
        case 0:
            skipButtonHidden.accept(value: true)
            continueButtonTitle.accept(value: localizationServices.stringForMainBundle(key: "onboardingTutorial.beginButton.title"))
       
        default:
            skipButtonHidden.accept(value: false)
            continueButtonTitle.accept(value: localizationServices.stringForMainBundle(key: "onboardingTutorial.nextButton.title"))
        }
        
        onPageDidAppear(page: page)
    }
    
    func continueTapped() {
        
        let nextPage = page.value + 1
        let reachedEnd = nextPage >= pageCount
        
        if reachedEnd {
            flowDelegate?.navigate(step: .endTutorialFromOnboardingTutorial)
        }
        
        onContinue()
    }
    
    func tutorialVideoPlayTapped() {
        
        guard let youTubeVideoId = tutorialItems[page.value].youTubeVideoId else {
            return
        }
        
        trackVideoWatched(videoId: youTubeVideoId)
    }
}
