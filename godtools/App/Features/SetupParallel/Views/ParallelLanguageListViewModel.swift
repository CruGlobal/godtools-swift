//
//  ParallelLanguageListViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 12/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import UIKit

class ParallelLanguageListViewModel: NSObject, ParallelLanguageListViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    private let dataDownloader: InitialDataDownloader
    private let languagesRepository: LanguagesRepository
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase
    
    let selectButtonText: String
    let numberOfLanguages: ObservableValue<Int>
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languagesRepository: LanguagesRepository, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getTranslatedLanguageUseCase: GetTranslatedLanguageUseCase) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languagesRepository = languagesRepository
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.getTranslatedLanguageUseCase = getTranslatedLanguageUseCase
        
        selectButtonText = localizationServices.stringForMainBundle(key: "parallelLanguage.selectButton.title")
        numberOfLanguages = ObservableValue(value: 0)
        
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
    
    private var allLanguages: [TranslatedLanguage] {
        
        let primaryLanguage: LanguageModel? = languageSettingsService.primaryLanguage.value
        
        var storedLanguageModels: [LanguageModel] = languagesRepository.getLanguages()
        
        // remove primary language from list of parallel languages
        if let primaryLanguage = primaryLanguage {
            storedLanguageModels = storedLanguageModels.filter {
                $0.id != primaryLanguage.id
            }
        }
        
        let translatedLanguages: [TranslatedLanguage] = storedLanguageModels.map({getTranslatedLanguageUseCase.getTranslatedLanguage(language: $0)})
        let sortedLanguages: [TranslatedLanguage] = translatedLanguages.sorted(by: {$0.name < $1.name})
        
        return sortedLanguages
    }
    
    private var languagesList: [TranslatedLanguage] = Array() {
        
        didSet {
            
            numberOfLanguages.accept(value: languagesList.count)
        }
    }
    
    private func reloadData() {
        
        reloadLanguages()
    }
    
    private func reloadLanguages() {
                
        languagesList = allLanguages
    }
    
    func languageWillAppear(index: Int) -> ChooseLanguageCellViewModel {
        
        let translatedLanguage: TranslatedLanguage = languagesList[index]
        
        return ChooseLanguageCellViewModel(
            translatedLanguage: translatedLanguage,
            languageIsDownloaded: true, //hides downloadImageView for all cells in this list
            hidesSelected: true,
            selectorColor: UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0),
            separatorColor: UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0),
            separatorLeftInset: 24,
            separatorRightInset: 24,
            languageLabelFontSize: 14
        )
    }
    
    func languageTapped(index: Int) {
                
        let selectedLanguage: TranslatedLanguage = languagesList[index]
        
        languageSettingsService.languageSettingsCache.cacheParallelLanguageId(languageId: selectedLanguage.id)
        
        flowDelegate?.navigate(step: .languageSelectedFromParallelLanguageList)
    }
}
