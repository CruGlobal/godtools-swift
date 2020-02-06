//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewModel: OnboardingTutorialViewModelType {
        
    private let analytics: GodToolsAnaltyics
    private let onboardingTutorialServices: OnboardingTutorialServicesType
    private let tutorialServices: TutorialServicesType
    
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let tutorialItems: ObservableValue<[OnboardingTutorialItem]> = ObservableValue(value: [])
    let currentTutorialItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    let skipButtonTitle: String = NSLocalizedString("navigationBar.navigationItem.skip", comment: "")
    let continueButtonTitle: String = NSLocalizedString("onboardingTutorial.continueButton.title", comment: "")
    let showMoreButtonTitle: String = NSLocalizedString("onboardingTutorial.showMoreButton.title", comment: "")
    let getStartedButtonTitle: String = NSLocalizedString("onboardingTutorial.getStartedButton.title", comment: "")
    let hidesSkipButton: ObservableValue<Bool> = ObservableValue(value: false)
    let tutorialButtonLayout: ObservableValue<OnboardingTutorialButtonLayout> = ObservableValue(value: OnboardingTutorialButtonLayout(state: .continueButton, animated: false))
        
    required init(flowDelegate: FlowDelegate, analytics: GodToolsAnaltyics, onboardingTutorialProvider: OnboardingTutorialProviderType, onboardingTutorialServices: OnboardingTutorialServicesType, tutorialServices: TutorialServicesType) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        self.onboardingTutorialServices = onboardingTutorialServices
        self.tutorialServices = tutorialServices
        
        var tutorialItemsArray: [OnboardingTutorialItem] = Array()
        tutorialItemsArray.append(contentsOf: onboardingTutorialProvider.aboutTheAppItems)
        tutorialItemsArray.append(onboardingTutorialProvider.appUsageListItem)
        
        tutorialItems.accept(value: tutorialItemsArray)
                
        setPage(page: 0, animated: false)
        
        onboardingTutorialServices.disableOnboardingTutorial()
    }
    
    private func setPage(page: Int, animated: Bool) {
        
        guard page >= 0 && page < tutorialItems.value.count else {
            return
        }
        
        self.page = page
        
        let isLastPage: Bool = page == tutorialItems.value.count - 1
                
        if isLastPage {
            hidesSkipButton.accept(value: true)
            tutorialButtonLayout.accept(value: OnboardingTutorialButtonLayout(state: .showMoreAndGetStarted, animated: animated))
        }
        else {
            hidesSkipButton.accept(value: false)
            tutorialButtonLayout.accept(value: OnboardingTutorialButtonLayout(state: .continueButton, animated: animated))
        }
        
        currentTutorialItemIndex.accept(value: page)
        
        analytics.recordScreenView(
            screenName: "onboarding-\(page + 2)",
            siteSection: "onboarding",
            siteSubSection: ""
        )
    }
    
    func skipTapped() {
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    func pageTapped(page: Int) {
        setPage(page: page, animated: true)
    }
    
    func continueTapped() {
                
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= tutorialItems.value.count
        
        if !reachedEnd {
            setPage(page: nextPage, animated: true)
        }
        else {
            flowDelegate?.navigate(step: .getStartedTappedFromOnboardingTutorial)
        }
    }
    
    func showMoreTapped() {
        tutorialServices.disableOpenTutorialCallout()
        flowDelegate?.navigate(step: .showMoreTappedFromOnboardingTutorial)
        
        analytics.recordActionForADBMobile(actionName: "Show Me More", data: ["cru.onboarding_more": 1])
    }
    
    func getStartedTapped() {
        flowDelegate?.navigate(step: .getStartedTappedFromOnboardingTutorial)
        
        analytics.recordActionForADBMobile(actionName: "Get Started", data: ["cru.onboarding_start": 1])
    }
}
