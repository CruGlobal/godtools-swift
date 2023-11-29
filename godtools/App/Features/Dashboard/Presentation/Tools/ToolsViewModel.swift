//
//  ToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ToolsViewModel: ObservableObject {
    
    private static var toggleToolFavoriteCancellable: AnyCancellable?
    
    private let dataDownloader: InitialDataDownloader
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let toolFilterLanguageSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>
    private let toolFilterCategorySelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?

    @Published var favoritingToolBannerMessage: String = ""
    @Published var showsFavoritingToolBanner: Bool = false
    @Published var toolSpotlightTitle: String = ""
    @Published var toolSpotlightSubtitle: String = ""
    @Published var spotlightTools: [ToolDomainModel] = Array()
    @Published var filterTitle: String = ""
    @Published var categoryFilterButtonTitle: String = ""
    @Published var languageFilterButtonTitle: String = ""
    @Published var allTools: [ToolDomainModel] = Array()
    @Published var isLoadingAllTools: Bool = true
        
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, favoritingToolMessageCache: FavoritingToolMessageCache, getAllToolsUseCase: GetAllToolsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase, getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, getUserFiltersUseCase: GetUserFiltersUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.attachmentsRepository = attachmentsRepository
        
        showsFavoritingToolBanner = !favoritingToolMessageCache.favoritingToolMessageDisabled
        
        let anyLanguageSelection = getToolFilterLanguagesUseCase.getAnyLanguageFilterDomainModel()
        let anyCategorySelection = getToolFilterCategoriesUseCase.getAnyCategoryDomainModel()
        toolFilterLanguageSelectionPublisher = CurrentValueSubject(anyLanguageSelection)
        toolFilterCategorySelectionPublisher = CurrentValueSubject(anyCategorySelection)
        
        getUserFiltersUseCase.getUserFiltersPublisher()
            .flatMap { userFilters in
                
                return Publishers.CombineLatest(
                    getToolFilterCategoriesUseCase.getCategoryFilterPublisher(with: userFilters.categoryFilterId),
                    getToolFilterLanguagesUseCase.getLanguageFilterPublisher(from: userFilters.languageFilterId)
                )
                .eraseToAnyPublisher()
            }
            .sink { categoryFilter, languageFilter in
                
                if let categoryFilter = categoryFilter {
                    self.toolFilterCategorySelectionPublisher.send(categoryFilter)
                }
                
                if let languageFilter = languageFilter {
                    self.toolFilterLanguageSelectionPublisher.send(languageFilter)
                }
            }
            .store(in: &cancellables)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "tool_offline_favorite_message")
            .receive(on: DispatchQueue.main)
            .assign(to: &$favoritingToolBannerMessage)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: ToolStringKeys.Spotlight.title.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$toolSpotlightTitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: ToolStringKeys.Spotlight.subtitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$toolSpotlightSubtitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: ToolStringKeys.ToolFilter.filterSectionTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$filterTitle)
        
        getSpotlightToolsUseCase.getSpotlightToolsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (spotlightTools: [ToolDomainModel]) in
                
                self?.spotlightTools = spotlightTools
            }
            .store(in: &cancellables)
        
        getAllToolsUseCase.getToolsForFilterSelectionPublisher(
            languagefilterSelection: toolFilterLanguageSelectionPublisher,
            categoryFilterSelection: toolFilterCategorySelectionPublisher
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (allTools: [ToolDomainModel]) in
                
                self?.allTools = allTools
                self?.isLoadingAllTools = false
            }
            .store(in: &cancellables)
        
        toolFilterCategorySelectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedCategory in
                
                self?.updateCategoryButtonText()
            }
            .store(in: &cancellables)
        
        toolFilterLanguageSelectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filterSelection in
                
                self?.updateLanguageButtonText()
            }
            .store(in: &cancellables)
    }
    
    private func updateCategoryButtonText() {
        
        categoryFilterButtonTitle = toolFilterCategorySelectionPublisher.value.translatedName
    }
    
    private func updateLanguageButtonText() {
        
        languageFilterButtonTitle = toolFilterLanguageSelectionPublisher.value.searchableText
    }
    
    private var analyticsScreenName: String {
        return "All Tools"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func trackToolTappedAnalytics(tool: ToolDomainModel, isSpotlight: Bool) {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: isSpotlight ? AnalyticsConstants.Sources.spotlight : AnalyticsConstants.Sources.allTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
    }
    
    private func trackPageView() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.viewedToolsAction,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
    }
    
    private func toggleToolIsFavorited(tool: ToolDomainModel) {
        
        ToolsViewModel.toggleToolFavoriteCancellable = toggleToolFavoritedUseCase.toggleToolFavoritedPublisher(id: tool.dataModelId)
            .sink { _ in
                
            }
    }
}

// MARK: - Inputs

extension ToolsViewModel {
    
    func pullToRefresh() {
        
        dataDownloader.downloadInitialData()
    }
    
    func pageViewed() {
        
        trackPageView()
    }
    
    func closeFavoritingToolBannerTapped() {
        
        withAnimation {
            showsFavoritingToolBanner = false
        }
        
        favoritingToolMessageCache.disableFavoritingToolMessage()
    }
    
    func getToolViewModel(tool: ToolDomainModel) -> ToolCardViewModel {
        
        return ToolCardViewModel(
            tool: tool,
            alternateLanguage: toolFilterLanguageSelectionPublisher.value.language,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase,
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func toolCategoryFilterTapped() {
        
        flowDelegate?.navigate(step: .toolCategoryFilterTappedFromTools(
            categoryFilterSelectionPublisher: toolFilterCategorySelectionPublisher,
            selectedLanguage: toolFilterLanguageSelectionPublisher.value
        ))
    }
    
    func toolLanguageFilterTapped() {
        
        flowDelegate?.navigate(step: .toolLanguageFilterTappedFromTools(
            languageFilterSelectionPublisher: toolFilterLanguageSelectionPublisher,
            selectedCategory: toolFilterCategorySelectionPublisher.value
        ))
    }
    
    func spotlightToolFavorited(spotlightTool: ToolDomainModel) {
     
        toggleToolIsFavorited(tool: spotlightTool)
    }
    
    func spotlightToolTapped(spotlightTool: ToolDomainModel) {
        
        trackToolTappedAnalytics(tool: spotlightTool, isSpotlight: true)
        
        flowDelegate?.navigate(step: .spotlightToolTappedFromTools(spotlightTool: spotlightTool))
    }
    
    func toolFavoriteTapped(tool: ToolDomainModel) {

        toggleToolIsFavorited(tool: tool)
    }
    
    func toolTapped(tool: ToolDomainModel) {
        
        trackToolTappedAnalytics(tool: tool, isSpotlight: false)
        
        flowDelegate?.navigate(step: .toolTappedFromTools(tool: tool, toolFilterLanguage: toolFilterLanguageSelectionPublisher.value))
    }
}
