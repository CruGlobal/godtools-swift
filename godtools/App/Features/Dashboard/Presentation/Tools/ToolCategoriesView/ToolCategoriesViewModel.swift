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
            .receive(on: DispatchQueue.main)
            .sink { language in
                
                self.setTitleText(with: language)
            }
            .store(in: &cancellables)
        
        getToolCategoriesUseCase.getToolCategoriesPublisher()
            .receive(on: DispatchQueue.main)
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
    
    private func setTitleText(with language: LanguageDomainModel?) {
        
        categoryTitleText = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: language?.localeIdentifier, key: "allTools.categories.title")
    }
}
