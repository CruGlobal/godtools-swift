//
//  ToolCategoriesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine
import SwiftUI

protocol ToolCategoriesViewModelDelegate: AnyObject {
    func filterToolsWithCategory(_ attrCategory: String?)
}

class ToolCategoriesViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    
    private weak var delegate: ToolCategoriesViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
        
    // MARK: - Published
    
    @Published var categoryTitleText: String = ""
    @Published var buttonViewModels = [BaseToolCategoryButtonViewModel]()
    @Published var selectedCategory: String?
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getToolCategoriesUseCase: GetToolCategoriesUseCase, delegate: ToolCategoriesViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        
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
            
            let category = categoryButtonViewModel.category.category
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
        
        getToolCategoriesUseCase.getToolCategoriesPublisher()
            .receiveOnMain()
            .sink { categories in
                
                self.refreshCategoryButtons(with: categories)
            }
            .store(in: &cancellables)
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadForLanguageChange()
            }
        }
    }
        
    private func refreshCategoryButtons(with categories: [ToolCategoryDomainModel]) {
        let allToolsButtonVM = AllToolsCategoryButtonViewModel(selectedAttrCategory: selectedCategory, localizationServices: localizationServices, languageSettingsService: languageSettingsService)

        let categoryButtonVMs = categories.map { category in
                
            return ToolCategoryButtonViewModel(category: category, selectedAttrCategory: selectedCategory, localizationServices: localizationServices, languageSettingsService: languageSettingsService)
        }
        
        buttonViewModels = [allToolsButtonVM] + categoryButtonVMs
    }
    
    private func setTitleText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        categoryTitleText = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.categories.title")
    }
    
    private func reloadForLanguageChange() {
        // TODO: - include this in the use case
//        reloadAvailableCategoriesFromCache()
        setTitleText()
    }
}
