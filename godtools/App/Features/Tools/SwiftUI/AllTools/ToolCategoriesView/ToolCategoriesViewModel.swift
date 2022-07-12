//
//  ToolCategoriesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

protocol ToolCategoriesViewModelDelegate: AnyObject {
    func filterToolsWithCategory(_ attrCategory: String?)
}

class ToolCategoriesViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private weak var delegate: ToolCategoriesViewModelDelegate?
        
    // MARK: - Published
    
    @Published var categoryTitleText: String = ""
    @Published var buttonViewModels = [BaseToolCategoryButtonViewModel]()
    @Published var selectedCategory: String?
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, delegate: ToolCategoriesViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.delegate = delegate
                
        super.init()
        
        setupBinding()
        setTitleText()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
    }
}

// MARK: - Public

extension ToolCategoriesViewModel {
    
    func categoryTapped(with buttonViewModel: BaseToolCategoryButtonViewModel) {
        
        switch buttonViewModel {
            
        case is AllToolsCategoryButtonViewModel:
            
            selectedCategory = nil
            
        case let categoryButtonViewModel as ToolCategoryButtonViewModel:
            
            let category = categoryButtonViewModel.attrCategory
            if category == selectedCategory {
                selectedCategory = nil
            } else {
                selectedCategory = category
            }
            
        default:
            
            assertionFailure("Unhandled category button view model type")
            return
        }
        
        
        buttonViewModels.forEach { $0.updateStateWithSelectedCategory(selectedCategory) }
        
        delegate?.filterToolsWithCategory(selectedCategory)
    }
}

// MARK: - Private

extension ToolCategoriesViewModel {
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if cachedResourcesAvailable {
                    self.reloadAvailableCategoriesFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    self?.reloadAvailableCategoriesFromCache()
                }
            }
        }
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadForLanguageChange()
            }
        }
    }
        
    private func reloadAvailableCategoriesFromCache() {
        let sortedTools = dataDownloader.resourcesCache
            .getAllVisibleTools()
            .sortedByPrimaryLanguageAvailable(languageSettingsService: languageSettingsService, dataDownloader: dataDownloader)
        
        var uniqueCategories = [String]()
        sortedTools.forEach { tool in
            let category = tool.attrCategory
            
            if uniqueCategories.contains(category) == false {
                uniqueCategories.append(category)
            }
        }
            
        let allToolsButtonVM = AllToolsCategoryButtonViewModel(selectedAttrCategory: selectedCategory)

        let categoryButtonVMs = uniqueCategories.map { category in
                
            return ToolCategoryButtonViewModel(attrCategory: category, selectedAttrCategory: selectedCategory, localizationServices: localizationServices, languageSettingsService: languageSettingsService)
        }
        
        buttonViewModels = [allToolsButtonVM] + categoryButtonVMs
    }
    
    private func setTitleText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        categoryTitleText = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.categories.title")
    }
    
    private func reloadForLanguageChange() {
        reloadAvailableCategoriesFromCache()
        setTitleText()
    }
}
