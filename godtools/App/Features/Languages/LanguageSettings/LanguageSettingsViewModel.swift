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
    private let localizationServices: LocalizationServices
    private let getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let primaryLanguageTitle: String
    let primaryLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let parallelLanguageTitle: String
    let parallelLanguageButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let shareGodToolsInNativeLanguage: String
    let languageAvailability: String
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.getTranslatedLanguageUseCase = getTranslatedLanguageUseCase
        self.analytics = analytics
        
        primaryLanguageTitle = localizationServices.stringForMainBundle(key: "primary_language")
        parallelLanguageTitle = localizationServices.stringForMainBundle(key: "parallel_language")
        shareGodToolsInNativeLanguage = localizationServices.stringForMainBundle(key: "share_god_tools_native_language")
        languageAvailability = localizationServices.stringForMainBundle(key: "not_every_tool_is_available")
        
        super.init()
        
        navTitle.accept(value: localizationServices.stringForMainBundle(key: "language_settings"))
                      
        reloadData()
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
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
            title = getTranslatedLanguageUseCase.getTranslatedLanguage(language: primaryLanguage).name
        }
        else {
            title = localizationServices.stringForMainBundle(key: "select_primary_language")
        }

        primaryLanguageButtonTitle.accept(value: title)
    }
    
    private func reloadParallelLanguageButtonTitle() {
            
        let title: String
        
        if let parallelLanguage = languageSettingsService.parallelLanguage.value {
            title = getTranslatedLanguageUseCase.getTranslatedLanguage(language: parallelLanguage).name
        }
        else {
            title = localizationServices.stringForMainBundle(key: "select_parallel_language")
        }

        parallelLanguageButtonTitle.accept(value: title)
    }
    
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
