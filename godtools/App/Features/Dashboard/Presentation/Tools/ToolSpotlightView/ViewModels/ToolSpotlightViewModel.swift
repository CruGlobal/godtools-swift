//
//  ToolSpotlightViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

protocol ToolSpotlightViewModelDelegate: AnyObject {
    func spotlightToolCardTapped(resource: ResourceModel)
    func spotlightToolFavoriteButtonTapped(resource: ResourceModel)
}

class ToolSpotlightViewModel: ToolCardProvider {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let localizationServices: LocalizationServices
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private weak var delegate: ToolSpotlightViewModelDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    
    @Published var spotlightTitle: String = ""
    @Published var spotlightSubtitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: ToolSpotlightViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
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
            delegate: self
        )
    }
}

// MARK: - Private

extension ToolSpotlightViewModel {
    
    private func setupBinding() {
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receiveOnMain()
            .sink { language in
                self.setTitleText(with: language)
            }
            .store(in: &cancellables)
        
        getSpotlightToolsUseCase.getSpotlightToolsPublisher()
            .receiveOnMain()
            .assign(to: \.tools, on: self)
            .store(in: &cancellables)
    }
    
    private func setTitleText(with language: LanguageDomainModel?) {
        spotlightTitle = localizationServices.stringForLocaleElseSystem(localeIdentifier: language?.localeIdentifier, key: "allTools.spotlight.title")
        spotlightSubtitle = localizationServices.stringForLocaleElseSystem(localeIdentifier: language?.localeIdentifier, key: "allTools.spotlight.description")
    }
}

// MARK: - ToolCardViewModelDelegate

extension ToolSpotlightViewModel: ToolCardViewModelDelegate {
    
    func toolCardTapped(_ tool: ToolDomainModel) {
        delegate?.spotlightToolCardTapped(resource: tool.resource)
    }
    
    func toolFavoriteButtonTapped(_ tool: ToolDomainModel) {
        delegate?.spotlightToolFavoriteButtonTapped(resource: tool.resource)
    }
    
    func toolDetailsButtonTapped(_ tool: ToolDomainModel) {}
    func openToolButtonTapped(_ tool: ToolDomainModel) {}
}
