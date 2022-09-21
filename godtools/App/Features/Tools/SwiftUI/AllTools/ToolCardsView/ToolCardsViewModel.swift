//
//  ToolCardsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine
import SwiftUI

protocol ToolCardsViewModelDelegate: ToolCardViewModelDelegate {
    func toolsAreLoading(_ isLoading: Bool)
}

class ToolCardsViewModel: ToolCardProvider {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private weak var delegate: ToolCardsViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    private let categoryFilterValuePublisher = CurrentValueSubject<String?, Never>(nil)
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getAllToolsUseCase: GetAllToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase,  getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: ToolCardsViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
        self.delegate = delegate
        
        super.init()
        
        setupBinding()
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ToolDomainModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            tool: tool,
            dataDownloader: dataDownloader,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: delegate
        )
    }
    
    override func toolTapped(_ tool: ToolDomainModel) {
        delegate?.toolCardTapped(tool)
    }
}

// MARK: - Private

extension ToolCardsViewModel {
    
    private func setupBinding() {
        
        getAllToolsUseCase.getToolsForCategoryPublisher(category: categoryFilterValuePublisher)
            .receiveOnMain()
            .sink { tools in
                
                self.delegate?.toolsAreLoading(tools.isEmpty)
                
                withAnimation {
                    self.tools = tools
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Public

extension ToolCardsViewModel {
    
    func filterTools(with categoryId: String?) {
        categoryFilterValuePublisher.value = categoryId
    }
}
