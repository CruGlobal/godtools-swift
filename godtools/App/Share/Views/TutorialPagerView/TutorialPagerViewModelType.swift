//
//  TutorialPagerViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 9/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol TutorialPagerViewModelType: TutorialPagerAnalyticsType {
   
    var pageCount: Int { get }
    var page: ObservableValue<Int> { get }
    var skipButtonTitle: String { get }
    var skipButtonHidden: ObservableValue<Bool> { get }
    var continueButtonTitle: ObservableValue<String> { get }
    var continueButtonHidden: ObservableValue<Bool> { get }

    func tutorialItemWillAppear(index: Int) -> TutorialCellViewModelType
    func skipTapped()
    func pageDidChange(page: Int)
    func pageDidAppear(page: Int)
    func continueTapped()
    func tutorialVideoPlayTapped()
}

extension TutorialPagerViewModelType {
    
    func onPageDidChange(page: Int) {
        
        self.page.accept(value: page)
    }
    
    func onPageDidAppear(page: Int) {
        
        self.page.accept(value: page)
        
        trackPageDidAppear(page: page)
    }
    
    func onContinue() {
        
        trackContinueButtonTapped(page: page.value)
    }
}
