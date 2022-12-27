//
//  AboutViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AboutViewModel: ObservableObject {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var navTitle: String
    @Published var aboutText: String
        
    init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        navTitle = localizationServices.stringForMainBundle(key: "aboutApp.navTitle")
        
        aboutText = localizationServices.stringForMainBundle(key: "general_about_1") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_2") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_3") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_4") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_5") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_6") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_7") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_8") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_9") + "\n\n" +
        localizationServices.stringForMainBundle(key: "general_about_10")
    }
    
    private var analyticsScreenName: String {
        return "About"
    }
    
    private var analyticsSiteSection: String {
        return "menu"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
}

// MARK: - Inputs

extension AboutViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromAbout)
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
