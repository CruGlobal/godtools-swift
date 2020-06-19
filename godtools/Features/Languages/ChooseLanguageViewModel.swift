//
//  ChooseLanguageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ChooseLanguageViewModel: NSObject, ChooseLanguageViewModelType {
        
    enum ChooseLanguageType {
        case primary
        case parallel
    }
    
    private let resourcesService: ResourcesService
    private let languageSettingsService: LanguageSettingsService
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
    
    required init(flowDelegate: FlowDelegate, resourcesService: ResourcesService, languageSettingsService: LanguageSettingsService, translationZipImporter: TranslationZipImporter, analytics: AnalyticsContainer, chooseLanguageType: ChooseLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.resourcesService = resourcesService
        self.languageSettingsService = languageSettingsService
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
        reloadSelectedLanguage()
        reloadHidesDeleteLanguageButton()
    }
    
    private func reloadLanguages() {
                
        let resourcesCache: RealmResourcesCache = resourcesService.realmResourcesCache
        let languageSettingsService: LanguageSettingsService = self.languageSettingsService
        let chooseLanguageType: ChooseLanguageType = self.chooseLanguageType
        let userPrimaryLanguage: LanguageModel? = languageSettingsService.primaryLanguage.value
        let userParallelLanguage: LanguageModel? = languageSettingsService.parallelLanguage.value
        
        resourcesCache.realmDatabase.background { [weak self] (realm: Realm) in
            
            let allLanguages: [LanguageModel] = resourcesCache.getLanguages(realm: realm).map({LanguageModel(realmLanguage: $0)})
            
            DispatchQueue.main.async { [weak self] in
                
                var availableLanguages: [LanguageModel] = allLanguages

                switch chooseLanguageType {
                
                case .primary:
                    // move primary to top of list
                    if let primaryLanguage = userPrimaryLanguage, let index = availableLanguages.firstIndex(of: primaryLanguage) {
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
                    if let parallelLanguage = userParallelLanguage, let index = availableLanguages.firstIndex(of: parallelLanguage) {
                        availableLanguages.remove(at: index)
                        availableLanguages.insert(parallelLanguage, at: 0)
                    }
                }
                
                let languages: [ChooseLanguageModel] = availableLanguages.map({ChooseLanguageModel(language: $0, languageSettingsService: languageSettingsService)})
                self?.allLanguages = languages
                self?.languages.accept(value: languages)
            }
        }
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
            selectedLanguage.accept(value: ChooseLanguageModel(language: language, languageSettingsService: languageSettingsService))
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
    
    func languageTapped(language: ChooseLanguageModel) {
        
        selectedLanguage.accept(value: language)
        
        switch chooseLanguageType {
        case .primary:
            languageSettingsService.languageSettingsCache.cachePrimaryLanguageId(languageId: language.languageId)
            if language.languageId == languageSettingsService.languageSettingsCache.parallelLanguageId.value {
                languageSettingsService.languageSettingsCache.deleteParallelLanguageId()
            }
        case .parallel:
            languageSettingsService.languageSettingsCache.cacheParallelLanguageId(languageId: language.languageId)
        }
                
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
