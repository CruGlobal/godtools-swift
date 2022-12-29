//
//  WebContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class WebContentViewModel {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    private let webContent: WebContentType
    private let backTappedFromWebContentStep: FlowStep
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let url: ObservableValue<URL?> = ObservableValue(value: nil)
    
    init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer, webContent: WebContentType, backTappedFromWebContentStep: FlowStep) {
        
        self.flowDelegate = flowDelegate
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        self.webContent = webContent
        self.backTappedFromWebContentStep = backTappedFromWebContentStep
        
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
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
}
