//
//  LanguageSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageSettingsViewModel: NSObject, LanguageSettingsViewModelType {

    private let resourcesService: ResourcesService
    private let languageSettingsService: LanguageSettingsService
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("language_settings", comment: ""))
    let primaryLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let parallelLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, resourcesService: ResourcesService, languageSettingsService: LanguageSettingsService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resourcesService = resourcesService
        self.languageSettingsService = languageSettingsService
        self.analytics = analytics
        
        super.init()
                
        setupBinding()
    }
    
    deinit {
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    private func setupBinding() {
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            self?.reloadPrimaryLanguageButtonTitle(primaryLanguage: primaryLanguage)
        }
        
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            self?.reloadParallelLanguageButtonTitle(parallelLanguage: parallelLanguage)
        }
    }
    
    private func reloadPrimaryLanguageButtonTitle(primaryLanguage: LanguageModel?) {
        
        let title: String
        
        if let primaryLanguage = primaryLanguage {
            title = LanguageNameTranslationViewModel(language: primaryLanguage, languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: false).name
        }
        else {
            title = NSLocalizedString("select_primary_language", comment: "")
        }

        primaryLanguageButtonTitle.accept(value: title)
    }
    
    private func reloadParallelLanguageButtonTitle(parallelLanguage: LanguageModel?) {
            
        let title: String
        
        if let parallelLanguage = parallelLanguage {
            title = LanguageNameTranslationViewModel(language: parallelLanguage, languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: false).name
        }
        else {
            title = NSLocalizedString("select_parallel_language", comment: "")
        }

        parallelLanguageButtonTitle.accept(value: title)
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Language Settings", siteSection: "menu", siteSubSection: "")
    }
    
    func choosePrimaryLanguageTapped() {
        flowDelegate?.navigate(step: .choosePrimaryLanguageTappedFromLanguageSettings)
    }
    
    func chooseParallelLanguageTapped() {
        flowDelegate?.navigate(step: .chooseParallelLanguageTappedFromLanguageSettings)
    }
}
