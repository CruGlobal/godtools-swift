//
//  LanguageSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class LanguageSettingsViewModel: LanguageSettingsViewModelType {

    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    
    private var cancellables = Set<AnyCancellable>()
        
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let primaryLanguageTitle: String
    let primaryLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let parallelLanguageTitle: String
    let parallelLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let shareGodToolsInNativeLanguage: String
    let languageAvailability: String
    
    required init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        primaryLanguageTitle = localizationServices.stringForMainBundle(key: "primary_language")
        parallelLanguageTitle = localizationServices.stringForMainBundle(key: "parallel_language")
        shareGodToolsInNativeLanguage = localizationServices.stringForMainBundle(key: "share_god_tools_native_language")
        languageAvailability = localizationServices.stringForMainBundle(key: "not_every_tool_is_available")
                
        navTitle.accept(value: localizationServices.stringForMainBundle(key: "language_settings"))
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receiveOnMain()
            .sink { [weak self] (language: LanguageDomainModel?) in
                
                let title: String = language?.translatedName ?? self?.localizationServices.stringForMainBundle(key: "select_primary_language") ?? ""

                self?.primaryLanguageButtonTitle.accept(value: title)
            }
            .store(in: &cancellables)
        
        getSettingsParallelLanguageUseCase.getParallelLanguagePublisher()
            .receiveOnMain()
            .sink(receiveValue: { [weak self] (language: LanguageDomainModel?) in
                
                let title: String = language?.translatedName ?? self?.localizationServices.stringForMainBundle(key: "select_parallel_language") ?? ""
                
                self?.parallelLanguageButtonTitle.accept(value: title)
            })
            .store(in: &cancellables)
    }
    
    private var analyticsScreenName: String {
        return "Language Settings"
    }
    
    private var analyticsSiteSection: String {
        return "menu"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
}

// MARK: - Inputs

extension LanguageSettingsViewModel {
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
    
    func choosePrimaryLanguageTapped() {
        flowDelegate?.navigate(step: .choosePrimaryLanguageTappedFromLanguageSettings)
    }
    
    func chooseParallelLanguageTapped() {
        flowDelegate?.navigate(step: .chooseParallelLanguageTappedFromLanguageSettings)
    }
}
