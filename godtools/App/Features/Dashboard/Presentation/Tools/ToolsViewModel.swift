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
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let categoryFilterValuePublisher: CurrentValueSubject<String?, Never> = CurrentValueSubject(nil)
    private let toolFilterSelectionPublisher: CurrentValueSubject<ToolFilterSelection, Never> = CurrentValueSubject(ToolFilterSelection(selectedCategory: nil, selectedLanguage: nil))
    
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
    @Published var categories: [ToolCategoryDomainModel] = Array()
    @Published var allTools: [ToolDomainModel] = Array()
    @Published var isLoadingAllTools: Bool = true
        
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, favoritingToolMessageCache: FavoritingToolMessageCache, getAllToolsUseCase: GetAllToolsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
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
        
        getInterfaceStringInAppLanguageUseCase.observeStringChangedPublisher(id: "tool_offline_favorite_message")
            .receive(on: DispatchQueue.main)
            .assign(to: &$favoritingToolBannerMessage)
        
        getInterfaceStringInAppLanguageUseCase.observeStringChangedPublisher(id: ToolStringKeys.Spotlight.title.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$toolSpotlightTitle)
        
        getInterfaceStringInAppLanguageUseCase.observeStringChangedPublisher(id: ToolStringKeys.Spotlight.subtitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$toolSpotlightSubtitle)
        
        getInterfaceStringInAppLanguageUseCase.observeStringChangedPublisher(id: ToolStringKeys.ToolFilter.filterSectionTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$filterTitle)
        
        showsFavoritingToolBanner = !favoritingToolMessageCache.favoritingToolMessageDisabled
        
        getSpotlightToolsUseCase.getSpotlightToolsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (spotlightTools: [ToolDomainModel]) in
                
                self?.spotlightTools = spotlightTools
            }
            .store(in: &cancellables)
        
        // TODO: - update to use the filterSelection publisher instead of just category
        getAllToolsUseCase.getToolsForCategoryPublisher(category: categoryFilterValuePublisher)
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
    
    private func didUpdateFilterSelection(filterSelection: ToolFilterSelection) {
        
        toolFilterSelectionPublisher.send(filterSelection)
    }
    
    private func updateFilterButtonText(with primaryLanguage: LanguageDomainModel? = nil) {
                
        let filterSelection = toolFilterSelectionPublisher.value
        
        if let selectedCategory = filterSelection.selectedCategory {
            
            categoryFilterButtonTitle = selectedCategory.translatedName
            
        } else {
            
            // TODO: Set using getInterfaceStringInAppLanguageUseCase. ~Levi
            categoryFilterButtonTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: LanguageCodeDomainModel.english.value, key: ToolStringKeys.ToolFilter.anyCategoryFilterText.rawValue)
        }
        
        if let selectedLanguage = filterSelection.selectedLanguage {
            
            languageFilterButtonTitle = selectedLanguage.translatedName
            
        } else {
            
            // TODO: Set using getInterfaceStringInAppLanguageUseCase. ~Levi
            languageFilterButtonTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: LanguageCodeDomainModel.english.value, key: ToolStringKeys.ToolFilter.anyLanguageFilterText.rawValue)
        }
        
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
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase,
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func toolFilterTapped(filterType: ToolFilterType) {
        
        flowDelegate?.navigate(step: .toolFilterTappedFromTools(toolFilterType: filterType, currentToolFilterSelection: toolFilterSelectionPublisher.value))
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
