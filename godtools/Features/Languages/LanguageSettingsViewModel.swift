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
    private let languageSettingsCache: LanguageSettingsCacheType
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("language_settings", comment: ""))
    let primaryLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let parallelLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, resourcesService: ResourcesService, languageSettingsCache: LanguageSettingsCacheType, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resourcesService = resourcesService
        self.languageSettingsCache = languageSettingsCache
        self.analytics = analytics
        
        super.init()
        
        reloadPrimaryLanguageButtonTitle()
        reloadParallelLanguageButtonTitle()
        
        setupBinding()
    }
    
    deinit {
        languageSettingsCache.primaryLanguageId.removeObserver(self)
        languageSettingsCache.parallelLanguageId.removeObserver(self)
    }
    
    private func setupBinding() {
        
        languageSettingsCache.primaryLanguageId.addObserver(self) { [weak self] (primaryLanguageId: String?) in
            self?.reloadPrimaryLanguageButtonTitle()
        }
        
        languageSettingsCache.parallelLanguageId.addObserver(self) { [weak self] (parallelLanguageId: String?) in
            self?.reloadParallelLanguageButtonTitle()
        }
    }
    
    private func reloadPrimaryLanguageButtonTitle() {
        
        languageSettingsCache.getPrimaryLanguage { [weak self] (languageModel: LanguageModel?) in
            
            let title: String
            
            if let languageModel = languageModel {
                title = LanguageNameViewModel(language: languageModel).name
            }
            else {
                title = NSLocalizedString("select_primary_language", comment: "")
            }

            self?.primaryLanguageButtonTitle.accept(value: title)
        }
    }
    
    private func reloadParallelLanguageButtonTitle() {
                
        languageSettingsCache.getParallelLanguage { [weak self] (languageModel: LanguageModel?) in
            
            let title: String
            
            if let languageModel = languageModel {
                title = LanguageNameViewModel(language: languageModel).name
            }
            else {
                title = NSLocalizedString("select_parallel_language", comment: "")
            }

            self?.parallelLanguageButtonTitle.accept(value: title)
        }
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
