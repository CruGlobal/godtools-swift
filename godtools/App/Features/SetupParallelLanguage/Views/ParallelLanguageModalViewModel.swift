//
//  ParallelLanguageModalViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 12/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ParallelLanguageModalViewModel: NSObject, ParallelLanguageModalViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    let selectButtonText: String
    let numberOfLanguages: ObservableValue<Int>
    let selectedLanguageIndex: ObservableValue<Int?>
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        selectButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectButton.title")
        numberOfLanguages = ObservableValue(value: 0)
        selectedLanguageIndex = ObservableValue(value: nil)
        
        super.init()
        
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
    
    private var allLanguages: [LanguageViewModel] {
        
        let primaryLanguage: LanguageModel? = languageSettingsService.primaryLanguage.value
        
        var storedLanguageModels: [LanguageModel] = dataDownloader.getStoredLanguages()
        
        // remove primary language from list of parallel languages
        if let primaryLanguage = primaryLanguage {
            storedLanguageModels = storedLanguageModels.filter {
                $0.id != primaryLanguage.id
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
    }
    
    private func reloadLanguages() {
                
        languagesList = allLanguages
    }
    
    private func reloadSelectedLanguage() {
                
        let language: LanguageModel?
        
        language = languageSettingsService.parallelLanguage.value
        
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
    
    func languageWillAppear(index: Int) -> ChooseLanguageCellViewModel {
        
        let languageViewModel: LanguageViewModel = languagesList[index]
        
        return ChooseLanguageCellViewModel(
            languageViewModel: languageViewModel,
            languageIsDownloaded: true, //hides downloadImageView for all cells in this list
            hidesSelected: languageViewModel.language.id != selectedLanguageModel?.id
        )
    }
    
    func languageTapped(index: Int) {
        
        selectedLanguageIndex.accept(value: index)
    }
    
    func backgroundTapped() {
        
        flowDelegate?.navigate(step: .backgroundTappedFromParallelLanguageModal)
    }
    
    func selectTapped() {
        
        guard let index = selectedLanguageIndex.value else { return }
        
        let selectedLanguage: LanguageModel = languagesList[index].language
        
        languageSettingsService.languageSettingsCache.cacheParallelLanguageId(languageId: selectedLanguage.id)
        
        flowDelegate?.navigate(step: .selectTappedFromParallelLanguageModal)
    }
}
