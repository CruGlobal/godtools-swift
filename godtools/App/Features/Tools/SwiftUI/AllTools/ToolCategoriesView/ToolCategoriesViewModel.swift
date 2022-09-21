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

class ToolCategoriesViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let localizationServices: LocalizationServices
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    
    private weak var delegate: ToolCategoriesViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
        
    // MARK: - Published
    
    @Published var categoryTitleText: String = ""
    @Published var buttonViewModels = [ToolCategoryButtonViewModel]()
    @Published var selectedCategoryId: String? = nil
    
    // MARK: - Init
    
    init(localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, delegate: ToolCategoriesViewModelDelegate?) {
        self.localizationServices = localizationServices
        
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        
        self.delegate = delegate
        
        setupBinding()
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
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receiveOnMain()
            .sink { language in
                
                self.reloadForLanguageChange(to: language)
            }
            .store(in: &cancellables)
        
        getToolCategoriesUseCase.getToolCategoriesPublisher()
            .receiveOnMain()
            .sink { categories in
                
                self.refreshCategoryButtons(with: categories)
            }
            .store(in: &cancellables)
    }
        
    private func refreshCategoryButtons(with categories: [ToolCategoryDomainModel]) {
        
        buttonViewModels = categories.map { category in
            
            return ToolCategoryButtonViewModel(
                category: category,
                selectedCategoryId: selectedCategoryId
            )
        }
    }
    
    private func setTitleText(with language: LanguageDomainModel) {
        guard let languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: language.localeIdentifier) else { return }
        categoryTitleText = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.categories.title")
    }
    
    private func reloadForLanguageChange(to language: LanguageDomainModel?) {
        guard let language = language else { return }

        setTitleText(with: language)
    }
}
