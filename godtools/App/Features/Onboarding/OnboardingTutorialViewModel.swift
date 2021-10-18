//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 10/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewModel: TutorialPagerViewModel {
    
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    private let customViewBuilder: CustomViewBuilderType
    private let localizationServices: LocalizationServices
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, analyticsContainer: AnalyticsContainer, onboardingTutorialItemsRepository: OnboardingTutorialItemsRepositoryType, onboardingTutorialAvailability: OnboardingTutorialAvailabilityType, openTutorialCalloutCache: OpenTutorialCalloutCacheType, customViewBuilder: CustomViewBuilderType, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.openTutorialCalloutCache = openTutorialCalloutCache
        self.customViewBuilder = customViewBuilder
        self.localizationServices = localizationServices
        
        super.init(analyticsContainer: analyticsContainer,  tutorialItems: onboardingTutorialItemsRepository.tutorialItems, skipButtonTitle: localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip"))
        
        onboardingTutorialAvailability.markOnboardingTutorialViewed()
    }
    
    required init(analyticsContainer: AnalyticsContainer, tutorialItems: [TutorialItemType], skipButtonTitle: String) {
        fatalError("init(analyticsContainer:localizationServices:tutorialItems:) has not been implemented")
    }
    
    override var analyticsScreenName: String {
        return "onboarding"
    }
    
    override var analyticsSiteSection: String {
        return "onboarding"
    }
    
    override var analyticsSiteSubsection: String {
        return ""
    }
    
    override var analyticsActionName: String {
        return "On-Boarding Start"
    }
    
    override func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType {
         return TutorialCellViewModel(item: tutorialItems[index], customViewBuilder: customViewBuilder)
    }
    
    override func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    override func pageDidChange(page: Int) {
                
        switch page {
        case 0:
            skipButtonHidden.accept(value: true)
            continueButtonTitle.accept(value: localizationServices.stringForMainBundle(key: "onboardingTutorial.beginButton.title"))
       
        default:
            skipButtonHidden.accept(value: false)
            continueButtonTitle.accept(value: localizationServices.stringForMainBundle(key: "onboardingTutorial.nextButton.title"))
        }
        
        super.pageDidChange(page: page)
    }
    
    override func continueTapped() {
        
        let nextPage = page.value + 1
        let reachedEnd = nextPage >= pageCount
        
        if reachedEnd {
            flowDelegate?.navigate(step: .endTutorialFromOnboardingTutorial)
        }
        
        super.continueTapped()
    }
}
