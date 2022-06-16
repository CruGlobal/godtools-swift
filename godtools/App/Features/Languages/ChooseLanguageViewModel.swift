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
    private let languagesRepository: LanguagesRepository
    private let languageSettingsService: LanguageSettingsService
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let chooseLanguageType: ChooseLanguageType
    private let shouldDisplaySelectedLanguageAtTop: Bool = false
            
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let deleteLanguageButtonTitle: String
    let closeKeyboardTitle: String
    let hidesDeleteLanguageButton: ObservableValue<Bool> = ObservableValue(value: true)
    let numberOfLanguages: ObservableValue<Int> = ObservableValue(value: 0)
    let selectedLanguageIndex: ObservableValue<Int?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languagesRepository: LanguagesRepository, languageSettingsService: LanguageSettingsService, downloadedLanguagesCache: DownloadedLanguagesCache, localizationServices: LocalizationServices, analytics: AnalyticsContainer, chooseLanguageType: ChooseLanguageType) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languagesRepository = languagesRepository
        self.languageSettingsService = languageSettingsService
        self.downloadedLanguagesCache = downloadedLanguagesCache
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.chooseLanguageType = chooseLanguageType
        
        deleteLanguageButtonTitle = localizationServices.stringForMainBundle(key: "clear")
        closeKeyboardTitle = localizationServices.stringForMainBundle(key: "dismiss")
        
        super.init()
                
        switch chooseLanguageType {
        case .primary:
            navTitle.accept(value: localizationServices.stringForMainBundle(key: "primary_language"))
        case .parallel:
            navTitle.accept(value: localizationServices.stringForMainBundle(key: "parallel_language"))
        }
        
        reloadData()
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
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
    
    private var allLanguages: [LanguageViewModel] {
        
        let userPrimaryLanguage: LanguageModel? = languageSettingsService.primaryLanguage.value
        let userParallelLanguage: LanguageModel? = languageSettingsService.parallelLanguage.value
        
        var storedLanguageModels: [LanguageModel] = languagesRepository.getAllLanguages()
        
        switch chooseLanguageType {
        
        case .primary:
            // move primary to top of list
            if shouldDisplaySelectedLanguageAtTop, let primaryLanguage = userPrimaryLanguage, let index = storedLanguageModels.firstIndex(of: primaryLanguage) {
                storedLanguageModels.remove(at: index)
                storedLanguageModels.insert(primaryLanguage, at: 0)
            }
        case .parallel:
            // remove primary language from list of parallel languages
            if let userPrimaryLanguage = userPrimaryLanguage {
                storedLanguageModels = storedLanguageModels.filter {
                    $0.id != userPrimaryLanguage.id
                }
            }
            
            // move parallel to top of list
            if shouldDisplaySelectedLanguageAtTop, let parallelLanguage = userParallelLanguage, let index = storedLanguageModels.firstIndex(of: parallelLanguage) {
                storedLanguageModels.remove(at: index)
                storedLanguageModels.insert(parallelLanguage, at: 0)
            }
        }
        
        let languageViewModels: [LanguageViewModel] = storedLanguageModels.map({LanguageViewModel(language: $0, localizationServices: localizationServices)})
        let sortedLanguages: [LanguageViewModel] = languageViewModels.sorted(by: {$0.translatedLanguageName < $1.translatedLanguageName})
        
        return sortedLanguages
    }
    
    private var languagesList: [LanguageViewModel] = Array() {
        
        didSet {
            numberOfLanguages.accept(value: languagesList.count)
        }
    }
    
    private var selectedLanguageModel: LanguageModel? {
        
        if let index = selectedLanguageIndex.value, index >= 0 && index < languagesList.count {
            return languagesList[index].language
        }
        
        return nil
    }
    
    private func reloadData() {
        
        reloadLanguages()
        reloadSelectedLanguage()
        reloadHidesDeleteLanguageButton()
    }
    
    private func reloadLanguages() {
                
        languagesList = allLanguages
    }
    
    private func reloadSelectedLanguage() {
                
        let language: LanguageModel?
        
        switch chooseLanguageType {
        case .primary:
            language = languageSettingsService.primaryLanguage.value
        case .parallel:
            language = languageSettingsService.parallelLanguage.value
        }
        
        var selectedIndex: Int? = nil
        
        for index in 0 ..< languagesList.count {
            let languageViewModel: LanguageViewModel = languagesList[index]
            if languageViewModel.language.id == language?.id {
                selectedIndex = index
                break
            }
        }
        
        selectedLanguageIndex.accept(value: selectedIndex)
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
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
    
    func deleteLanguageTapped() {
                
        switch chooseLanguageType {
        case .primary:
            break
        case .parallel:
            languageSettingsService.languageSettingsCache.deleteParallelLanguageId()
            selectedLanguageIndex.accept(value: nil)
            reloadLanguages()
            reloadHidesDeleteLanguageButton()
            flowDelegate?.navigate(step: .deleteLanguageTappedFromChooseLanguage)
        }
    }
    
    func languageTapped(index: Int) {
        
        selectedLanguageIndex.accept(value: index)
        
        let selectedLanguage: LanguageModel = languagesList[index].language
        
        switch chooseLanguageType {
        case .primary:
            languageSettingsService.languageSettingsCache.cachePrimaryLanguageId(languageId: selectedLanguage.id)
            if selectedLanguage.id == languageSettingsService.languageSettingsCache.parallelLanguageId.value {
                languageSettingsService.languageSettingsCache.deleteParallelLanguageId()
            }
        case .parallel:
            languageSettingsService.languageSettingsCache.cacheParallelLanguageId(languageId: selectedLanguage.id)
        }
                
        flowDelegate?.navigate(step: .languageTappedFromChooseLanguage)
    }
    
    func searchLanguageTextInputChanged(text: String) {
                        
        if !text.isEmpty {
                        
            let filteredLanguages = allLanguages.filter {
                $0.translatedLanguageName.lowercased().contains(text.lowercased())
            }
            
            languagesList = filteredLanguages
        }
        else {
            languagesList = allLanguages
        }
    }
    
    func willDisplayLanguage(index: Int) -> ChooseLanguageCellViewModel {
        
        let languageViewModel: LanguageViewModel = languagesList[index]
        
        return ChooseLanguageCellViewModel(
            languageViewModel: languageViewModel,
            languageIsDownloaded: downloadedLanguagesCache.isDownloaded(languageId: languageViewModel.language.id),
            hidesSelected: languageViewModel.language.id != selectedLanguageModel?.id,
            selectorColor: nil,
            separatorColor: nil,
            separatorLeftInset: nil,
            separatorRightInset: nil,
            languageLabelFontSize: nil
        )
    }
}
