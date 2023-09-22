//
//  WebContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class WebContentViewModel {
    
    private let webContent: WebContentType
    private let backTappedFromWebContentStep: FlowStep
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let url: ObservableValue<URL?> = ObservableValue(value: nil)
    
    init(flowDelegate: FlowDelegate, webContent: WebContentType, backTappedFromWebContentStep: FlowStep, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.webContent = webContent
        self.backTappedFromWebContentStep = backTappedFromWebContentStep
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        navTitle.accept(value: webContent.navTitle)
        url.accept(value: webContent.url)
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
        
        flowDelegate?.navigate(step: backTappedFromWebContentStep)
    }
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
}
