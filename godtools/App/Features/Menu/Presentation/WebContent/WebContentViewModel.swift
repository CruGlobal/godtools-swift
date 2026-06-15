//
//  WebContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@MainActor
final class WebContentViewModel {
    
    private let stepEmitter: FlowStepEmitter
    private let webContent: WebContentType
    private let backTappedFromWebContentStep: AppFlowStep
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
        
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let url: ObservableValue<URL?> = ObservableValue(value: nil)
    
    init(stepEmitter: FlowStepEmitter, webContent: WebContentType, backTappedFromWebContentStep: AppFlowStep, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.stepEmitter = stepEmitter
        self.webContent = webContent
        self.backTappedFromWebContentStep = backTappedFromWebContentStep
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        navTitle.accept(value: webContent.navTitle)
        url.accept(value: webContent.url)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return webContent.analyticsScreenName
    }
    
    private var analyticsSiteSection: String {
        return webContent.analyticsSiteSection
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
}

// MARK: - Inputs

extension WebContentViewModel {
    
    @objc func backTapped() {
        
        stepEmitter.emit(step: backTappedFromWebContentStep)
    }
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
}
