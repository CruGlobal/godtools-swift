//
//  ChooseLanguageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class ChooseLanguageViewModel: ChooseLanguageViewModelType {
        
    enum ChooseLanguageType {
        case primary
        case parallel
    }
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let userDidSetSettingsPrimaryLanguageUseCase: UserDidSetSettingsPrimaryLanguageUseCase
    private let userDidSetSettingsParallelLanguageUseCase: UserDidSetSettingsParallelLanguageUseCase
    private let userDidDeleteParallelLanguageUseCase: UserDidDeleteParallelLanguageUseCase
    private let getLanguagesListUseCase: GetLanguagesListUseCase
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let chooseLanguageType: ChooseLanguageType
    
    private var allLanguages: [LanguageDomainModel] = Array()
    private var settingsPrimaryLanguage: LanguageDomainModel?
    private var settingsParallelLanguage: LanguageDomainModel?
    
    private var languagesList: [LanguageDomainModel] = Array()
    
    private var cancellables = Set<AnyCancellable>()
                
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let deleteLanguageButtonTitle: String
    let closeKeyboardTitle: String
    let hidesDeleteLanguageButton: ObservableValue<Bool> = ObservableValue(value: true)
    let numberOfLanguages: ObservableValue<Int> = ObservableValue(value: 0)
    let selectedLanguageIndex: ObservableValue<Int?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase,  userDidSetSettingsPrimaryLanguageUseCase: UserDidSetSettingsPrimaryLanguageUseCase, userDidSetSettingsParallelLanguageUseCase: UserDidSetSettingsParallelLanguageUseCase, userDidDeleteParallelLanguageUseCase: UserDidDeleteParallelLanguageUseCase, getLanguagesListUseCase: GetLanguagesListUseCase, downloadedLanguagesCache: DownloadedLanguagesCache, localizationServices: LocalizationServices, analytics: AnalyticsContainer, chooseLanguageType: ChooseLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.userDidSetSettingsPrimaryLanguageUseCase = userDidSetSettingsPrimaryLanguageUseCase
        self.userDidSetSettingsParallelLanguageUseCase = userDidSetSettingsParallelLanguageUseCase
        self.userDidDeleteParallelLanguageUseCase = userDidDeleteParallelLanguageUseCase
        self.getLanguagesListUseCase = getLanguagesListUseCase
        self.downloadedLanguagesCache = downloadedLanguagesCache
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.chooseLanguageType = chooseLanguageType
        
        deleteLanguageButtonTitle = localizationServices.stringForMainBundle(key: "clear")
        closeKeyboardTitle = localizationServices.stringForMainBundle(key: "dismiss")
                        
        switch chooseLanguageType {
        case .primary:
            navTitle.accept(value: localizationServices.stringForMainBundle(key: "primary_language"))
        case .parallel:
            navTitle.accept(value: localizationServices.stringForMainBundle(key: "parallel_language"))
        }
        
        Publishers.Zip3(getLanguagesListUseCase.getLanguagesList(), getSettingsPrimaryLanguageUseCase.getPrimaryLanguage(), getSettingsParallelLanguageUseCase.getParallelLanguage())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] languages, settingsPrimaryLanguage, settingsParallelLanguage in
                self?.allLanguages = languages
                self?.settingsPrimaryLanguage = settingsPrimaryLanguage
                self?.settingsParallelLanguage = settingsParallelLanguage
                self?.setLanguagesList(languages: languages, settingsPrimaryLanguage: settingsPrimaryLanguage, settingsParallelLanguage: settingsParallelLanguage)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return "Select Language"
    }
    
    private var analyticsSiteSection: String {
        return "menu"
    }
    
    private var analyticsSiteSubSection: String {
        return "language settings"
    }
    
    private func setLanguagesList(languages: [LanguageDomainModel], settingsPrimaryLanguage: LanguageDomainModel?, settingsParallelLanguage: LanguageDomainModel?) {
             
        let selectedLanguage: LanguageDomainModel?
                
        switch chooseLanguageType {
        
        case .primary:
            selectedLanguage = settingsPrimaryLanguage
            self.languagesList = languages
            
        case .parallel:
            selectedLanguage = settingsParallelLanguage
            self.languagesList = languages.filter({$0.dataModelId != settingsPrimaryLanguage?.dataModelId})
        }
                
        numberOfLanguages.accept(value: languagesList.count)
        
        selectedLanguageIndex.accept(value: languagesList.firstIndex(where: {$0.dataModelId == selectedLanguage?.dataModelId}))
    }
    
    private var selectedLanguage: LanguageDomainModel? {
        
        guard let index = selectedLanguageIndex.value, index >= 0 && index < languagesList.count else {
            return nil
        }
        
        return languagesList[index]
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
    
    func deleteLanguageTapped() {
                
        switch chooseLanguageType {
        case .primary:
            break
        case .parallel:
            userDidDeleteParallelLanguageUseCase.deleteParallelLanguage()
            flowDelegate?.navigate(step: .deleteLanguageTappedFromChooseLanguage)
        }
    }
    
    func languageTapped(index: Int) {
                
        let selectedLanguage: LanguageDomainModel = languagesList[index]
        
        downloadedLanguagesCache.addDownloadedLanguage(languageId: selectedLanguage.dataModelId)
        
        switch chooseLanguageType {
        case .primary:
            userDidSetSettingsPrimaryLanguageUseCase.setPrimaryLanguage(language: selectedLanguage)

        case .parallel:
            userDidSetSettingsParallelLanguageUseCase.setParallelLanguage(language: selectedLanguage)
        }
                
        flowDelegate?.navigate(step: .languageTappedFromChooseLanguage)
    }
    
    func searchLanguageTextInputChanged(text: String) {
                        
        if !text.isEmpty {
                        
            let filteredLanguages = allLanguages.filter {
                $0.translatedName.lowercased().contains(text.lowercased())
            }
            
            setLanguagesList(languages: filteredLanguages, settingsPrimaryLanguage: settingsPrimaryLanguage, settingsParallelLanguage: settingsParallelLanguage)
        }
        else {
            setLanguagesList(languages: allLanguages, settingsPrimaryLanguage: settingsPrimaryLanguage, settingsParallelLanguage: settingsParallelLanguage)
        }
    }
    
    func willDisplayLanguage(index: Int) -> ChooseLanguageCellViewModel {
                
        let language: LanguageDomainModel = languagesList[index]
        
        return ChooseLanguageCellViewModel(
            language: language,
            languageIsDownloaded: downloadedLanguagesCache.isDownloaded(languageId: language.dataModelId),
            hidesSelected: language.dataModelId != selectedLanguage?.dataModelId,
            selectorColor: nil,
            separatorColor: nil,
            separatorLeftInset: nil,
            separatorRightInset: nil,
            languageLabelFontSize: nil
        )
    }
}
