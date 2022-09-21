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
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private weak var delegate: ToolSpotlightViewModelDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    
    @Published var spotlightTitle: String = ""
    @Published var spotlightSubtitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: ToolSpotlightViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
        self.delegate = delegate
        
        super.init()
        
        setTitleText()
        setupBinding()
    }
    
    deinit {
        languageSettingsService.primaryLanguage.removeObserver(self)
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
        
        getSpotlightToolsUseCase.getSpotlightToolsPublisher()
            .receiveOnMain()
            .assign(to: \.tools, on: self)
            .store(in: &cancellables)
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.setTitleText()
            }
        }
    }
    
    private func setTitleText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        spotlightTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.spotlight.title")
        spotlightSubtitle = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.spotlight.description")
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
