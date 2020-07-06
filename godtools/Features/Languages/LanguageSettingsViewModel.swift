//
//  LanguageSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguageSettingsViewModel: NSObject, LanguageSettingsViewModelType {

    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("language_settings", comment: ""))
    let primaryLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let parallelLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.translateLanguageNameViewModel = TranslateLanguageNameViewModel(languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: false)
        self.analytics = analytics
        
        super.init()
                                
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                if cachedResourcesAvailable {
                    self?.reloadData()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    self?.reloadData()
                }
            }
        }
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadPrimaryLanguageButtonTitle()
            }
        }
        
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadParallelLanguageButtonTitle()
            }
        }
    }
    
    private func reloadData() {
        reloadPrimaryLanguageButtonTitle()
        reloadParallelLanguageButtonTitle()
    }
    
    private func reloadPrimaryLanguageButtonTitle() {
        
        let title: String
        
        if let primaryLanguage = languageSettingsService.primaryLanguage.value {
            title = primaryLanguage.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)
        }
        else {
            title = NSLocalizedString("select_primary_language", comment: "")
        }

        primaryLanguageButtonTitle.accept(value: title)
    }
    
    private func reloadParallelLanguageButtonTitle() {
            
        let title: String
        
        if let parallelLanguage = languageSettingsService.parallelLanguage.value {
            title = parallelLanguage.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel)
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
