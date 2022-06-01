//
//  ToolCategoriesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class ToolCategoriesViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
        
    // MARK: - Published
    
    @Published var buttonViewModels = [ToolCategoryButtonViewModel]()
    @Published var selectedCategory: String?
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
    }
}

// MARK: - Public

extension ToolCategoriesViewModel {
    
    func categoryTapped(_ category: String) {
        selectedCategory = category
        
        for buttonViewModel in buttonViewModels {
            buttonViewModel.updateStateWithSelectedCategory(selectedCategory)
        }
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
    }
        
    private func reloadAvailableCategoriesFromCache() {
        let sortedTools = dataDownloader.resourcesCache
            .getAllVisibleToolsSorted()
            .sortedByPrimaryLanguageAvailable(languageSettingsService: languageSettingsService, dataDownloader: dataDownloader)
        
        var uniqueCategories = [String]()
        let toolsWithDuplicateCategoriesRemoved = sortedTools
            .filter({ tool in
                let category = tool.attrCategory
                
                if uniqueCategories.contains(category) {
                    return false
                    
                } else {
                    uniqueCategories.append(category)
                    return true
                }
            })
        
        
        let categoryButtonViewModels: [ToolCategoryButtonViewModel] = toolsWithDuplicateCategoriesRemoved
            .map { resource in
                
                return ToolCategoryButtonViewModel(attrCategory: resource.attrCategory, selectedAttrCategory: selectedCategory, localizationServices: localizationServices, languageSettingsService: languageSettingsService)
            }
        
        buttonViewModels = categoryButtonViewModels
    }
}
