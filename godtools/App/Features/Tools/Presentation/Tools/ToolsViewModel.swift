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

@MainActor class ToolsViewModel: ObservableObject {
    
    typealias ToolId = String
    
    private static var favoriteToolCancellables: [ToolId: AnyCancellable?] = Dictionary()
    
    private let resourcesRepository: ResourcesRepository
    private let getToolsStringsUseCase: GetToolsStringsUseCase
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getUserToolFiltersUseCase: GetUserToolFiltersUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var toolFilterCategorySelection: ToolFilterCategoryDomainModel = ToolFilterAnyCategoryDomainModel.emptyValue
    @Published private var toolFilterLanguageSelection: ToolFilterLanguageDomainModel = ToolFilterAnyLanguageDomainModel.emptyValue
    @Published private var localizationSettings: UserLocalizationSettingsDomainModel?
    
    @Published private(set) var toggleOptions: [PersonalizationToggleOption] = []
    @Published private(set) var strings: ToolsStringsDomainModel = .emptyValue
    
    @Published var selectedToggle: PersonalizationToggleOptionValue = .personalized
    @Published var favoritingToolBannerMessage: String = ""
    @Published var showsFavoritingToolBanner: Bool = false
    @Published var toolSpotlightTitle: String = ""
    @Published var toolSpotlightSubtitle: String = ""
    @Published var spotlightTools: [SpotlightToolListItemDomainModel] = Array()
    @Published var filterTitle: String = ""
    @Published var categoryFilterButtonTitle: String = ""
    @Published var languageFilterButtonTitle: String = ""
    @Published var allTools: [ToolListItemDomainModel] = Array()
    @Published var isLoadingAllTools: Bool = true
        
    init(flowDelegate: FlowDelegate, resourcesRepository: ResourcesRepository, getToolsStringsUseCase: GetToolsStringsUseCase, getAllToolsUseCase: GetAllToolsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase, favoritingToolMessageCache: FavoritingToolMessageCache, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getUserToolFiltersUseCase: GetUserToolFiltersUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, getToolBannerUseCase: GetToolBannerUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resourcesRepository = resourcesRepository
        self.getToolsStringsUseCase = getToolsStringsUseCase
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLocalizationSettingsUseCase = getLocalizationSettingsUseCase
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getUserToolFiltersUseCase = getUserToolFiltersUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        
        showsFavoritingToolBanner = !favoritingToolMessageCache.favoritingToolMessageDisabled
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        getLocalizationSettingsUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$localizationSettings)
        
        Publishers.CombineLatest4(
            $appLanguage,
            $toolFilterCategorySelection,
            $toolFilterLanguageSelection,
            $selectedToggle
        )
        .dropFirst()
        .map { (appLanguage, toolFilterCategory, toolFilterLanguage, toggle) -> AnyPublisher<[ToolListItemDomainModel], Error> in

            switch toggle {
            
            case .personalized:
                return Just([])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            
            case .all:
                return getAllToolsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        languageIdForAvailabilityText: toolFilterLanguage.languageDataModelId,
                        filterToolsByCategory: toolFilterCategory,
                        filterToolsByLanguage: toolFilterLanguage
                    )
            }
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in

        }, receiveValue: { [weak self] (tools: [ToolListItemDomainModel]) in

            self?.allTools = tools
            self?.isLoadingAllTools = false
        })
        .store(in: &cancellables)
        
        $appLanguage.dropFirst()
            .map { appLanguage in
                return getToolsStringsUseCase
                    .execute(translateInLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceStrings: ToolsStringsDomainModel) in
                
                self?.strings = interfaceStrings
                self?.favoritingToolBannerMessage = interfaceStrings.favoritingToolBannerMessage
                self?.toolSpotlightTitle = interfaceStrings.toolSpotlightTitle
                self?.toolSpotlightSubtitle = interfaceStrings.toolSpotlightSubtitle
                self?.filterTitle = interfaceStrings.filterTitle
                self?.toggleOptions = [
                    PersonalizationToggleOption(title: interfaceStrings.personalizedToolToggleTitle, selection: .personalized),
                    PersonalizationToggleOption(title: interfaceStrings.allToolsToggleTitle, selection: .all)
                ]
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $appLanguage.dropFirst(),
            $toolFilterCategorySelection.dropFirst(),
            $toolFilterLanguageSelection.dropFirst()
        )
        .map { (appLanguage, toolFilterCategory, toolFilterLanguage) in
            
            getSpotlightToolsUseCase
                .execute(
                    translatedInAppLanguage: appLanguage,
                    languageIdForAvailabilityText: toolFilterLanguage.languageDataModelId
                )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak self] (spotlightTools: [SpotlightToolListItemDomainModel]) in
            
            self?.spotlightTools = spotlightTools
        })
        .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getUserToolFiltersUseCase
                    .getUserToolFiltersPublisher(translatedInAppLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userFilters in
            
                self?.toolFilterCategorySelection = userFilters.categoryFilter
                self?.toolFilterLanguageSelection = userFilters.languageFilter
                self?.categoryFilterButtonTitle = userFilters.categoryFilter.categoryButtonText
                self?.languageFilterButtonTitle = userFilters.languageFilter.languageButtonText
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
    
    private func trackToolTappedAnalytics(tool: ToolListItemDomainModelInterface) {
        
        let source: String
        
        if tool is SpotlightToolListItemDomainModel {
            source = AnalyticsConstants.Sources.spotlight
        }
        else {
            source = AnalyticsConstants.Sources.allTools
        }
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: source,
                AnalyticsConstants.Keys.tool: tool.analyticsToolAbbreviation
            ]
        )
    }
    
    private func trackPageView() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.viewedToolsAction,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
    }
    
    private func toggleToolIsFavorited(toolId: String) {
        
        ToolsViewModel.favoriteToolCancellables[toolId] = toggleToolFavoritedUseCase
            .execute(
                toolId: toolId
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (domainModel: ToolIsFavoritedDomainModel) in
                
            })
    }
}

// MARK: - Inputs

extension ToolsViewModel {
    
    func pullToRefresh() {
        
        resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(requestPriority: .high, forceFetchFromRemote: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in

            }, receiveValue: { (result: ResourcesCacheSyncResult) in

            })
            .store(in: &cancellables)
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
    
    func getSpotlightToolViewModel(spotlightTool: SpotlightToolListItemDomainModel) -> ToolCardViewModel {
        return getToolViewModel(tool: spotlightTool, accessibility: .spotlightTool)
    }
    
    func getToolItemViewModel(tool: ToolListItemDomainModel) -> ToolCardViewModel {
        return getToolViewModel(tool: tool, accessibility: .tool)
    }
    
    private func getToolViewModel(tool: ToolListItemDomainModelInterface, accessibility: AccessibilityStrings.Button) -> ToolCardViewModel {
        
        return ToolCardViewModel(
            tool: tool,
            accessibility: accessibility,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            getToolBannerUseCase: getToolBannerUseCase
        )
    }
    
    func toolCategoryFilterTapped() {
        
        flowDelegate?.navigate(step: .toolCategoryFilterTappedFromTools)
    }
    
    func toolLanguageFilterTapped() {
        
        flowDelegate?.navigate(step: .toolLanguageFilterTappedFromTools)
    }
    
    func spotlightToolFavoriteTapped(spotlightTool: SpotlightToolListItemDomainModel) {
     
        toggleToolIsFavorited(toolId: spotlightTool.dataModelId)
    }
    
    func spotlightToolTapped(spotlightTool: SpotlightToolListItemDomainModel) {
        
        trackToolTappedAnalytics(tool: spotlightTool)
        
        flowDelegate?.navigate(step: .spotlightToolTappedFromTools(spotlightTool: spotlightTool, toolFilterLanguage: toolFilterLanguageSelection))
    }
    
    func toolFavoriteTapped(tool: ToolListItemDomainModel) {

        toggleToolIsFavorited(toolId: tool.dataModelId)
    }
    
    func toolTapped(tool: ToolListItemDomainModel) {

        trackToolTappedAnalytics(tool: tool)

        flowDelegate?.navigate(step: .toolTappedFromTools(tool: tool, toolFilterLanguage: toolFilterLanguageSelection))
    }

    func localizationSettingsTapped() {

        flowDelegate?.navigate(step: .localizationSettingsTappedFromTools)
    }
}
