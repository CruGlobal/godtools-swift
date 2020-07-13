//
//  ChooseLanguageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ChooseLanguageViewModel: NSObject, ChooseLanguageViewModelType {
        
    enum ChooseLanguageType {
        case primary
        case parallel
    }
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let analytics: AnalyticsContainer
    private let chooseLanguageType: ChooseLanguageType
    private let shouldDisplaySelectedLanguageAtTop: Bool = false
    
    private var allLanguages: [LanguageModel] = Array()
    
    private weak var flowDelegate: FlowDelegate?
    
    let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    let downloadedLanguagesCache: DownloadedLanguagesCache
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let deleteLanguageButtonTitle: String = NSLocalizedString("clear", comment: "")
    let hidesDeleteLanguageButton: ObservableValue<Bool> = ObservableValue(value: true)
    let languages: ObservableValue<[LanguageModel]> = ObservableValue(value: [])
    let selectedLanguage: ObservableValue<LanguageModel?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, downloadedLanguagesCache: DownloadedLanguagesCache, analytics: AnalyticsContainer, chooseLanguageType: ChooseLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.translateLanguageNameViewModel = TranslateLanguageNameViewModel(languageSettingsService: languageSettingsService, shouldFallbackToPrimaryLanguageLocale: false)
        self.downloadedLanguagesCache = downloadedLanguagesCache
        self.analytics = analytics
        self.chooseLanguageType = chooseLanguageType
        
        super.init()
                
        switch chooseLanguageType {
        case .primary:
            navTitle.accept(value: NSLocalizedString("primary_language", comment: ""))
        case .parallel:
            navTitle.accept(value: NSLocalizedString("parallel_language", comment: ""))
        }
        
        reloadData()
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
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
    }
    
    private func reloadData() {
        
        reloadLanguages()
        reloadSelectedLanguage()
        reloadHidesDeleteLanguageButton()
    }
    
    private func reloadLanguages() {
                
        let userPrimaryLanguage: LanguageModel? = languageSettingsService.primaryLanguage.value
        let userParallelLanguage: LanguageModel? = languageSettingsService.parallelLanguage.value
        
        var availableLanguages: [LanguageModel] = dataDownloader.languagesCache.getLanguages()

        switch chooseLanguageType {
        
        case .primary:
            // move primary to top of list
            if shouldDisplaySelectedLanguageAtTop, let primaryLanguage = userPrimaryLanguage, let index = availableLanguages.firstIndex(of: primaryLanguage) {
                availableLanguages.remove(at: index)
                availableLanguages.insert(primaryLanguage, at: 0)
            }
        case .parallel:
            // remove primary language from list of parallel languages
            if let userPrimaryLanguage = userPrimaryLanguage {
                let newAvailableLanguages: [LanguageModel] = availableLanguages.filter {
                    $0.id != userPrimaryLanguage.id
                }
                availableLanguages = newAvailableLanguages
            }
            
            // move parallel to top of list
            if shouldDisplaySelectedLanguageAtTop, let parallelLanguage = userParallelLanguage, let index = availableLanguages.firstIndex(of: parallelLanguage) {
                availableLanguages.remove(at: index)
                availableLanguages.insert(parallelLanguage, at: 0)
            }
        }
        
        allLanguages = availableLanguages
        languages.accept(value: availableLanguages)
    }
    
    private func reloadSelectedLanguage() {
                
        let language: LanguageModel?
        
        switch chooseLanguageType {
        case .primary:
            language = languageSettingsService.primaryLanguage.value
        case .parallel:
            language = languageSettingsService.parallelLanguage.value
        }
        
        if let language = language {
            selectedLanguage.accept(value: language)
        }
        else {
            selectedLanguage.accept(value: nil)
        }
    }
    
    private func reloadHidesDeleteLanguageButton() {
        
        switch chooseLanguageType {
        case .primary:
            hidesDeleteLanguageButton.accept(value: true)
        case .parallel:
            hidesDeleteLanguageButton.accept(value: languageSettingsService.parallelLanguage.value == nil)
        }
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Select Language", siteSection: "menu", siteSubSection: "language settings")
    }
    
    func deleteLanguageTapped() {
                
        switch chooseLanguageType {
        case .primary:
            break
        case .parallel:
            languageSettingsService.languageSettingsCache.deleteParallelLanguageId()
            selectedLanguage.accept(value: nil)
            reloadLanguages()
            reloadHidesDeleteLanguageButton()
            flowDelegate?.navigate(step: .deleteLanguageTappedFromChooseLanguage)
        }
    }
    
    func languageTapped(language: LanguageModel) {
        
        selectedLanguage.accept(value: language)
        
        switch chooseLanguageType {
        case .primary:
            languageSettingsService.languageSettingsCache.cachePrimaryLanguageId(languageId: language.id)
            if language.id == languageSettingsService.languageSettingsCache.parallelLanguageId.value {
                languageSettingsService.languageSettingsCache.deleteParallelLanguageId()
            }
        case .parallel:
            languageSettingsService.languageSettingsCache.cacheParallelLanguageId(languageId: language.id)
        }
                
        flowDelegate?.navigate(step: .languageTappedFromChooseLanguage)
    }
    
    func searchLanguageTextInputChanged(text: String) {
                        
        if !text.isEmpty {
                        
            let filteredLanguages = allLanguages.filter {
                $0.translatedName(translateLanguageNameViewModel: translateLanguageNameViewModel).lowercased().contains(text.lowercased())
            }
            languages.accept(value: filteredLanguages)
        }
        else {
            languages.accept(value: allLanguages)
        }
    }
}
