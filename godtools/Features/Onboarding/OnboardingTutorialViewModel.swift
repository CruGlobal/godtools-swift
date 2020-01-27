//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class OnboardingTutorialViewModel: OnboardingTutorialViewModelType {
    
    private let onboardingTutorialProvider: OnboardingTutorialProviderType
    
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let tutorialItems: ObservableValue<[OnboardingTutorialItem]> = ObservableValue(value: [])
    let currentTutorialItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    let continueTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("onboardingTutorial.continueButton.title", comment: ""))
        
    required init(flowDelegate: FlowDelegate, onboardingTutorialProvider: OnboardingTutorialProviderType) {
        
        self.flowDelegate = flowDelegate
        self.onboardingTutorialProvider = onboardingTutorialProvider
        
        var tutorialItemsArray: [OnboardingTutorialItem] = Array()
        tutorialItemsArray.append(contentsOf: onboardingTutorialProvider.aboutTheAppItems)
        tutorialItemsArray.append(onboardingTutorialProvider.appUsageListItem)
        
        tutorialItems.accept(value: tutorialItemsArray)
                
        setPage(page: 0)
    }
    
    private func setPage(page: Int) {
        
        guard page >= 0 && page < tutorialItems.value.count else {
            return
        }
        
        self.page = page
        
        currentTutorialItemIndex.accept(value: page)
    }
    
    func skipTapped() {
        print("skip tapped")
    }
    
    func pageTapped(page: Int) {
        setPage(page: page)
    }
    
    func continueTapped() {
        
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= tutorialItems.value.count
        
        if !reachedEnd {
            setPage(page: nextPage)
        }
        else {
            print("reached end")
        }
    }
}
