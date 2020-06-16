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
    
    private let resourcesService: ResourcesService
    private let languageSettingsCache: LanguageSettingsCacheType
    private let translationZipImporter: TranslationZipImporter
    private let analytics: AnalyticsContainer
    private let chooseLanguageType: ChooseLanguageType
    
    private var allLanguages: [ChooseLanguageModel] = Array()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let deleteLanguageButtonTitle: String = NSLocalizedString("clear", comment: "")
    let hidesDeleteLanguageButton: ObservableValue<Bool> = ObservableValue(value: true)
    let languages: ObservableValue<[ChooseLanguageModel]> = ObservableValue(value: [])
    let selectedLanguage: ObservableValue<ChooseLanguageModel?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, resourcesService: ResourcesService, languageSettingsCache: LanguageSettingsCacheType, translationZipImporter: TranslationZipImporter, analytics: AnalyticsContainer, chooseLanguageType: ChooseLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.resourcesService = resourcesService
        self.languageSettingsCache = languageSettingsCache
        self.translationZipImporter = translationZipImporter
        self.analytics = analytics
        self.chooseLanguageType = chooseLanguageType
        
        super.init()
                
        switch chooseLanguageType {
        case .primary:
            navTitle.accept(value: NSLocalizedString("primary_language", comment: ""))
        case .parallel:
            navTitle.accept(value: NSLocalizedString("parallel_language", comment: ""))
        }
        
        reloadLanguages()
        
        reloadHidesDeleteLanguageButton()
    }
    
    private var userPrimaryLanguage: RealmLanguage? {
        if let primaryLanguageId = languageSettingsCache.primaryLanguageId.value {
            return resourcesService.resourcesCache.realmCache.getLanguage(id: primaryLanguageId)
        }
        else {
            return nil
        }
    }
    
    private var userParallelLanguage: RealmLanguage? {
        if let parallelLanguageId = languageSettingsCache.parallelLanguageId.value {
            return resourcesService.resourcesCache.realmCache.getLanguage(id: parallelLanguageId)
        }
        else {
            return nil
        }
    }
    
    private func reloadLanguages() {
        
        let availableLanguages: [ChooseLanguageModel] = resourcesService.resourcesCache.realmCache.getLanguages().map({ChooseLanguageModel(language: $0)})
        
        switch chooseLanguageType {
        case .primary:
            allLanguages = availableLanguages
            if let primaryLanguage = userPrimaryLanguage {
                selectedLanguage.accept(value: ChooseLanguageModel(language: primaryLanguage))
            }
        case .parallel:
            // remove primary language from list
            if let primaryLanguage = userPrimaryLanguage {
                allLanguages = availableLanguages.filter {
                    $0.languageId != primaryLanguage.id
                }
            }
            else {
                allLanguages = availableLanguages
            }
            
            if let parallelLanguage = userParallelLanguage {
                selectedLanguage.accept(value: ChooseLanguageModel(language: parallelLanguage))
            }
        }
        
        languages.accept(value: allLanguages)
    }
    
    private func reloadHidesDeleteLanguageButton() {
        
        switch chooseLanguageType {
        case .primary:
            hidesDeleteLanguageButton.accept(value: true)
        case .parallel:
            hidesDeleteLanguageButton.accept(value: languageSettingsCache.parallelLanguageId.value == nil)
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
            languageSettingsCache.deleteParallelLanguageId()
            selectedLanguage.accept(value: nil)
        }
    }
    
    func languageTapped(language: ChooseLanguageModel) {
        
        selectedLanguage.accept(value: language)
        
        switch chooseLanguageType {
        case .primary:
            if let realmLanguage = resourcesService.resourcesCache.realmCache.getLanguage(id: language.languageId) {
                languageSettingsCache.cachePrimaryLanguageId(language: realmLanguage)
            }
            
            if language.languageId == languageSettingsCache.parallelLanguageId.value {
                languageSettingsCache.deleteParallelLanguageId()
            }
        case .parallel:
            if let realmLanguage = resourcesService.resourcesCache.realmCache.getLanguage(id: language.languageId) {
                languageSettingsCache.cacheParallelLanguageId(language: realmLanguage)
            }
        }
        
        // TODO: Investigate these two calls more. ~Levi
        //languagesManager.recordLanguageShouldDownload(language: language)
        //translationZipImporter.download(language: language)
        
        flowDelegate?.navigate(step: .languageTappedFromChooseLanguage)
    }
    
    func searchLanguageTextInputChanged(text: String) {
                        
        if !text.isEmpty {
                        
            let filteredLanguages = allLanguages.filter {
                $0.languageName.lowercased().contains(text.lowercased())
            }
            languages.accept(value: filteredLanguages)
        }
        else {
            languages.accept(value: allLanguages)
        }
    }
}
