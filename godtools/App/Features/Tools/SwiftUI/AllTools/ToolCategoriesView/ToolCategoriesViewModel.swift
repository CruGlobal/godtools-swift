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
    func filterToolsWithCategory(_ categoryId: String?)
}

class ToolCategoriesViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    
    private weak var delegate: ToolCategoriesViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
        
    // MARK: - Published
    
    @Published var categoryTitleText: String = ""
    @Published var buttonViewModels = [BaseToolCategoryButtonViewModel]()
    @Published var selectedCategoryId: String?
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, delegate: ToolCategoriesViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        
        self.delegate = delegate
                
        super.init()
        
        setupBinding()
        setTitleText()
    }
    
    deinit {
        languageSettingsService.primaryLanguage.removeObserver(self)
    }
}

// MARK: - Public

extension ToolCategoriesViewModel {
    
    func categoryTapped(with buttonViewModel: BaseToolCategoryButtonViewModel) {
        
        switch buttonViewModel {
            
        case is AllToolsCategoryButtonViewModel:
            
            selectedCategoryId = nil
            
        case let categoryButtonViewModel as ToolCategoryButtonViewModel:
            
            let categoryId = categoryButtonViewModel.category.id
            if categoryId == selectedCategoryId {
                selectedCategoryId = nil
            } else {
                selectedCategoryId = categoryId
            }
            
        default:
            
            assertionFailure("Unhandled category button view model type")
            return
        }
        
        
        buttonViewModels.forEach { $0.updateStateWithSelectedCategory(selectedCategoryId) }
        
        delegate?.filterToolsWithCategory(selectedCategoryId)
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
        
        let allToolsButtonVM = AllToolsCategoryButtonViewModel(selectedCategoryId: selectedCategoryId, localizationServices: localizationServices, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase)

        let categoryButtonVMs = categories.map { category in
            
            return ToolCategoryButtonViewModel(
                category: category,
                selectedCategoryId: selectedCategoryId,
                localizationServices: localizationServices,
                getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase
            )
        }
        
        buttonViewModels = [allToolsButtonVM] + categoryButtonVMs
    }
    
    private func setTitleText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        categoryTitleText = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.categories.title")
    }
    
    private func reloadForLanguageChange() {
        setTitleText()
    }
}
