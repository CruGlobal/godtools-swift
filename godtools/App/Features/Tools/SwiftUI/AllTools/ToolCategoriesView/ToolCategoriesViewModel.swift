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
    
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    
    private weak var delegate: ToolCategoriesViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
        
    // MARK: - Published
    
    @Published var categoryTitleText: String = ""
    @Published var buttonViewModels = [ToolCategoryButtonViewModel]()
    @Published var selectedCategoryId: String? = nil
    
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
        languageSettingsService.primaryLanguage.removeObserver(self)
    }
}

// MARK: - Public

extension ToolCategoriesViewModel {
    
    func categoryTapped(with buttonViewModel: ToolCategoryButtonViewModel) {
        
        selectedCategoryId = buttonViewModel.category.id
        
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
        
        buttonViewModels = categories.map { category in
            
            return ToolCategoryButtonViewModel(
                category: category,
                selectedCategoryId: selectedCategoryId
            )
        }
    }
    
    private func setTitleText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        categoryTitleText = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.categories.title")
    }
    
    private func reloadForLanguageChange() {
        setTitleText()
    }
}
