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
    private let analytics: GodToolsAnaltyics
    private let chooseLanguageType: ChooseLanguageType
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let deleteLanguageButtonTitle: String = NSLocalizedString("clear", comment: "")
    let hidesDeleteLanguageButton: ObservableValue<Bool> = ObservableValue(value: true)
    let languages: ObservableValue<[Language]> = ObservableValue(value: [])
    let selectedLanguage: ObservableValue<Language?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, languagesManager: LanguagesManager, translationZipImporter: TranslationZipImporter, analytics: GodToolsAnaltyics, chooseLanguageType: ChooseLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.languagesManager = languagesManager
        self.translationZipImporter = translationZipImporter
        self.analytics = analytics
        self.chooseLanguageType = chooseLanguageType
        
        switch chooseLanguageType {
        case .primary:
            navTitle.accept(value: NSLocalizedString("primary_language", comment: ""))
            selectedLanguage.accept(value: languagesManager.loadPrimaryLanguageFromDisk())
        case .parallel:
            navTitle.accept(value: NSLocalizedString("parallel_language", comment: ""))
            selectedLanguage.accept(value: languagesManager.loadParallelLanguageFromDisk())
        }
        
        reloadHidesDeleteLanguageButton()
        reloadLanguages()
    }
    
    private func reloadHidesDeleteLanguageButton() {
        
        switch chooseLanguageType {
        case .primary:
            hidesDeleteLanguageButton.accept(value: true)
        case .parallel:
            hidesDeleteLanguageButton.accept(value: languagesManager.loadParallelLanguageFromDisk() == nil)
        }
    }
    
    private func reloadLanguages() {
        
        let allLanguages: [Language] = Array(languagesManager.loadFromDisk())
        
        languages.accept(value: allLanguages)
    }
    
    func pageViewed() {
        
        analytics.recordScreenView(screenName: "Select Language", siteSection: "menu", siteSubSection: "language settings")
    }
    
    func deleteLanguageTapped() {
        
        //GTSettings.shared.parallelLanguageId = nil
        //languagesTableView.reloadData()
        
        switch chooseLanguageType {
        case .primary:
            break
        case .parallel:
            break
        }
    }
    
    func languageTapped(language: Language) {
        
        selectedLanguage.accept(value: language)
        
        switch chooseLanguageType {
        case .primary:
            languagesManager.setPrimaryLanguage(language: language)
        case .parallel:
            languagesManager.setParallelLanguage(language: language)
        }
        
        // TODO: Clean up. ~Levi
        languagesManager.recordLanguageShouldDownload(language: language)
        translationZipImporter.download(language: language)
        
        flowDelegate?.navigate(step: .languageTappedFromChooseLanguage)
    }
}
