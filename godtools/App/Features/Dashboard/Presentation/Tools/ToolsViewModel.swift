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
    private let localizationServices: LocalizationServices
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let analytics: AnalyticsContainer
    private let categoryFilterValuePublisher: CurrentValueSubject<String?, Never> = CurrentValueSubject(nil)
    private let toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?

    @Published var favoritingToolBannerMessage: String
    @Published var showsFavoritingToolBanner: Bool = false
    @Published var toolSpotlightTitle: String = ""
    @Published var toolSpotlightSubtitle: String = ""
    @Published var spotlightTools: [ToolDomainModel] = Array()
    @Published var filterTitle: String = ""
    @Published var categoryFilterButtonTitle: String = ""
    @Published var languageFilterButtonTitle: String = ""
    @Published var categories: [ToolCategoryDomainModel] = Array()
    @Published var allTools: [ToolDomainModel] = Array()
    @Published var isLoadingAllTools: Bool = true
        
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, favoritingToolMessageCache: FavoritingToolMessageCache, getAllToolsUseCase: GetAllToolsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, attachmentsRepository: AttachmentsRepository, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.attachmentsRepository = attachmentsRepository
        self.analytics = analytics
        
        favoritingToolBannerMessage = localizationServices.stringForSystemElseEnglish(key: "tool_offline_favorite_message")
        showsFavoritingToolBanner = !favoritingToolMessageCache.favoritingToolMessageDisabled
        
        
        let anyCategorySelection = getToolCategoriesUseCase.getAnyCategoryDomainModel()
        let anyLanguageSelection = getToolFilterLanguagesUseCase.getAnyLanguageFilterDomainModel()
        toolFilterSelectionPublisher = CurrentValueSubject(ToolFilterSelection(selectedCategory: anyCategorySelection, selectedLanguage: anyLanguageSelection))
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                let primaryLocaleId: String? = primaryLanguage?.localeIdentifier
                
                self?.toolSpotlightTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.Spotlight.title.rawValue)
                self?.toolSpotlightSubtitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.Spotlight.subtitle.rawValue)
                self?.filterTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLocaleId, key: ToolStringKeys.ToolFilter.filterSectionTitle.rawValue)
                
            }
            .store(in: &cancellables)
        
        getSpotlightToolsUseCase.getSpotlightToolsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (spotlightTools: [ToolDomainModel]) in
                
                self?.spotlightTools = spotlightTools
            }
            .store(in: &cancellables)
        
        getAllToolsUseCase.getToolsForFilterSelectionPublisher(filterSelection: toolFilterSelectionPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (allTools: [ToolDomainModel]) in
                
                self?.allTools = allTools
                self?.isLoadingAllTools = false
            }
            .store(in: &cancellables)
        
        toolFilterSelectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filterSelection in
                
                self?.updateFilterButtonText()
            }
            .store(in: &cancellables)
    }
    
    private func updateFilterButtonText() {
        
        let filterSelection = toolFilterSelectionPublisher.value
        
        categoryFilterButtonTitle = filterSelection.selectedCategory.translatedName
        languageFilterButtonTitle = filterSelection.selectedLanguage.searchableText
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
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: isSpotlight ? AnalyticsConstants.Sources.spotlight : AnalyticsConstants.Sources.allTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
    
    private func trackPageView() {
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.viewedToolsAction,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: nil
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
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
            alternateLanguage: toolFilterSelectionPublisher.value.selectedLanguage.language,
            localizationServices: localizationServices,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func toolFilterTapped(filterType: ToolFilterType) {
        
        flowDelegate?.navigate(step: .toolFilterTappedFromTools(toolFilterType: filterType, toolFilterSelectionPublisher: toolFilterSelectionPublisher))
    }
    
    func spotlightToolFavorited(spotlightTool: ToolDomainModel) {
     
        toggleToolIsFavorited(tool: spotlightTool)
    }
    
    func spotlightToolTapped(spotlightTool: ToolDomainModel) {
        
        trackToolTappedAnalytics(tool: spotlightTool, isSpotlight: true)
        
        flowDelegate?.navigate(step: .toolTappedFromTools(resource: spotlightTool.resource))
    }
    
    func toolFavoriteTapped(tool: ToolDomainModel) {

        toggleToolIsFavorited(tool: tool)
    }
    
    func toolTapped(tool: ToolDomainModel) {
        
        trackToolTappedAnalytics(tool: tool, isSpotlight: false)
        
        flowDelegate?.navigate(step: .toolTappedFromTools(resource: tool.resource))
    }
}
