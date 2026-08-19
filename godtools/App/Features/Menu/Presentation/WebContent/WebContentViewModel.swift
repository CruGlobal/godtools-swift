//
//  WebContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@MainActor
final class WebContentViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let webContent: WebContentType
    private let backTappedFromWebContentStep: AppFlowStep
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
        
    @Published private(set) var navTitle: String = ""
    @Published private(set) var url: URL?
    
    init(
        stepEmitter: FlowStepEmitter,
        webContent: WebContentType,
        backTappedFromWebContentStep: AppFlowStep,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.webContent = webContent
        self.backTappedFromWebContentStep = backTappedFromWebContentStep
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        navTitle = webContent.navTitle
        url = webContent.url
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
        
        Task {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: AnalyticsProperties(
                    screenName: analyticsScreenName,
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubSection,
                    appLanguage: nil,
                    contentLanguage: nil,
                    secondaryContentLanguage: nil
                )
            )
        }
    }
}
