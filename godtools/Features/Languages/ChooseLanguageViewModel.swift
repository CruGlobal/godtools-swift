//
//  ChooseLanguageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ChooseLanguageViewModel: ChooseLanguageViewModelType {
        
    enum ChooseLanguageType {
        case primary
        case parallel
    }
    
    private let languagesManager: LanguagesManager
    private let translationZipImporter: TranslationZipImporter
    private let analytics: AnalyticsContainer
    private let chooseLanguageType: ChooseLanguageType
    private let allLanguages: [Language]
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let deleteLanguageButtonTitle: String = NSLocalizedString("clear", comment: "")
    let hidesDeleteLanguageButton: ObservableValue<Bool> = ObservableValue(value: true)
    let languages: ObservableValue<[Language]> = ObservableValue(value: [])
    let selectedLanguage: ObservableValue<Language?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, languagesManager: LanguagesManager, translationZipImporter: TranslationZipImporter, analytics: AnalyticsContainer, chooseLanguageType: ChooseLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.languagesManager = languagesManager
        self.translationZipImporter = translationZipImporter
        self.analytics = analytics
        self.chooseLanguageType = chooseLanguageType
        
        let allLanguagesOnDisk: [Language] = Array(languagesManager.loadFromDisk())
        
        switch chooseLanguageType {
        case .primary:
            navTitle.accept(value: NSLocalizedString("primary_language", comment: ""))
            selectedLanguage.accept(value: languagesManager.loadPrimaryLanguageFromDisk())
            allLanguages = allLanguagesOnDisk
        case .parallel:
            navTitle.accept(value: NSLocalizedString("parallel_language", comment: ""))
            selectedLanguage.accept(value: languagesManager.loadParallelLanguageFromDisk())
            if let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
                allLanguages = allLanguagesOnDisk.filter {
                    !$0.localizedName().lowercased().contains(primaryLanguage.localizedName().lowercased())
                }
            }
            else {
                allLanguages = allLanguagesOnDisk
            }
        }
        
        reloadHidesDeleteLanguageButton()
        
        languages.accept(value: allLanguages)
    }
    
    private func reloadHidesDeleteLanguageButton() {
        
        switch chooseLanguageType {
        case .primary:
            hidesDeleteLanguageButton.accept(value: true)
        case .parallel:
            hidesDeleteLanguageButton.accept(value: languagesManager.loadParallelLanguageFromDisk() == nil)
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
            languagesManager.deleteParallelLanguage()
            selectedLanguage.accept(value: nil)
        }
    }
    
    func languageTapped(language: Language) {
        
        selectedLanguage.accept(value: language)
        
        switch chooseLanguageType {
        case .primary:
            languagesManager.updatePrimaryLanguage(language: language)
            // User chose a primary language that is the set parallel language.
            if let parallelLanguage = languagesManager.loadParallelLanguageFromDisk(), language.remoteId == parallelLanguage.remoteId {
                languagesManager.deleteParallelLanguage()
            }
        case .parallel:
            languagesManager.updateParallelLanguage(language: language)
        }
        
        // TODO: Investigate these two calls more. ~Levi
        languagesManager.recordLanguageShouldDownload(language: language)
        translationZipImporter.download(language: language)
        
        flowDelegate?.navigate(step: .languageTappedFromChooseLanguage)
    }
    
    func searchLanguageTextInputChanged(text: String) {
                        
        if !text.isEmpty {
                        
            let filteredLanguages = allLanguages.filter {
                $0.localizedName().lowercased().contains(text.lowercased())
            }
            languages.accept(value: filteredLanguages)
        }
        else {
            languages.accept(value: allLanguages)
        }
    }
}
