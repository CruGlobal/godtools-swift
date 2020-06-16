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
        reloadSelectedLanguage()
        reloadHidesDeleteLanguageButton()
    }
    
    private func reloadLanguages() {
        
        resourcesService.resourcesCache.realmResources.getLanguages { [weak self] (allLanguages: [LanguageModel]) in
            
            guard let viewModel = self else {
                return
            }
            
            let availableLanguages: [ChooseLanguageModel] = allLanguages.map({ChooseLanguageModel(language: $0)})
            
            viewModel.allLanguages = availableLanguages
            
            switch viewModel.chooseLanguageType {
            
            case .primary:
                
                self?.languages.accept(value: availableLanguages)
                
            case .parallel:
                
                // remove primary language from available languages
                self?.languageSettingsCache.getPrimaryLanguage(complete: { [weak self] (language: LanguageModel?) in
                    if let language = language {
                        viewModel.allLanguages = availableLanguages.filter {
                            $0.languageId != language.id
                        }
                    }
                    self?.languages.accept(value: availableLanguages)
                })
            }
        }
    }
    
    private func reloadSelectedLanguage() {
        
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
        
        resourcesService.resourcesCache.realmResources.getLanguage(id: id) { [weak self] (language: LanguageModel?) in
            if let language = language {
                self?.selectedLanguage.accept(value: ChooseLanguageModel(language: language))
            }
            else {
                self?.selectedLanguage.accept(value: nil)
            }
        }
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
