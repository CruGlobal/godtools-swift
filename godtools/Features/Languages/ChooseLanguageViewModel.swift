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
        reloadSelectedLanguage()
        reloadHidesDeleteLanguageButton()
    }
    
    private func reloadLanguages() {
                
        let resourcesCache: RealmResourcesCache = resourcesService.realmResourcesCache
        let languageSettingsCache: LanguageSettingsCacheType = self.languageSettingsCache
        let chooseLanguageType: ChooseLanguageType = self.chooseLanguageType
        let userPrimaryLanguageId: String = languageSettingsCache.primaryLanguageId.value ?? ""
        let userParallelLanguageId: String = languageSettingsCache.parallelLanguageId.value ?? ""
        
        resourcesCache.realmDatabase.background { [weak self] (realm: Realm) in
            
            let allLanguages: [LanguageModel] = resourcesCache.getLanguages(realm: realm).map({LanguageModel(realmLanguage: $0)})
            
            let userPrimaryLanguage: LanguageModel?
            let userParallelLanguage: LanguageModel?
            
            if let realmUserPrimaryLanguage = resourcesCache.getLanguage(realm: realm, id: userPrimaryLanguageId) {
                userPrimaryLanguage = LanguageModel(realmLanguage: realmUserPrimaryLanguage)
            }
            else {
                userPrimaryLanguage = nil
            }
            
            if let realmUserParallelLanguage = resourcesCache.getLanguage(realm: realm, id: userParallelLanguageId) {
                userParallelLanguage = LanguageModel(realmLanguage: realmUserParallelLanguage)
            }
            else {
                userParallelLanguage = nil
            }
            
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
                
                let languages: [ChooseLanguageModel] = availableLanguages.map({ChooseLanguageModel(language: $0)})
                self?.allLanguages = languages
                self?.languages.accept(value: languages)
            }
        }
    }
    
    private func reloadSelectedLanguage() {
        
        let resourcesCache: RealmResourcesCache = resourcesService.realmResourcesCache
        
        let languageId: String?
        
        switch chooseLanguageType {
        case .primary:
            languageId = languageSettingsCache.primaryLanguageId.value
        case .parallel:
            languageId = languageSettingsCache.parallelLanguageId.value
        }
        
        guard let id = languageId else {
            selectedLanguage.accept(value: nil)
            return
        }
        
        resourcesCache.getLanguage(id: id, completeOnMain: { [weak self] (language: LanguageModel?) in
            
            if let language = language {
                self?.selectedLanguage.accept(value: ChooseLanguageModel(language: language))
            }
            else {
                self?.selectedLanguage.accept(value: nil)
            }
        })
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
            reloadLanguages()
            reloadHidesDeleteLanguageButton()
        }
    }
    
    func languageTapped(language: ChooseLanguageModel) {
        
        selectedLanguage.accept(value: language)
        
        switch chooseLanguageType {
        case .primary:
            languageSettingsCache.cachePrimaryLanguageId(languageId: language.languageId)
            if language.languageId == languageSettingsCache.parallelLanguageId.value {
                languageSettingsCache.deleteParallelLanguageId()
            }
        case .parallel:
            languageSettingsCache.cacheParallelLanguageId(languageId: language.languageId)
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
