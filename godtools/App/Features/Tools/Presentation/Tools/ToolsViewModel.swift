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

@MainActor
final class ToolsViewModel: ObservableObject {
    
    typealias ToolId = String
    
    private static var favoriteToolTasks: [ToolId: Task<Void, Error>] = Dictionary()
    
    private let stepEmitter: FlowStepEmitter
    private let pullToRefreshToolsUseCase: PullToRefreshToolsUseCase
    private let getToolsStringsUseCase: GetToolsStringsUseCase
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getPersonalizedToolsUseCase: GetPersonalizedToolsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase
    private let getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
    private let dataCache: DataCacheInterface
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var pullToRefreshToolsTask: Task<Void, Error>?
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var toolFilterCategorySelection = ToolFilterCategoryDomainModel.emptyValue
    @Published private var toolFilterLanguageSelection = ToolFilterLanguageDomainModel.emptyValue
    @Published private var localizationSettings: UserLocalizationSettingsDomainModel?
    @Published private var allToolsList: [ToolListItemDomainModel] = Array()
    
    @Published private(set) var toggleOptions: [PersonalizationToggleOption] = ToolsViewModel.getPersonalizedToggleOptions(strings: ToolsStringsDomainModel.emptyValue)
    @Published private(set) var strings: ToolsStringsDomainModel = .emptyValue
    @Published private(set) var showsFavoritingToolBanner: Bool = false
    @Published private(set) var spotlightTools: [SpotlightToolListItemDomainModel] = Array()
    @Published private(set) var categoryFilterActionTitle: String = ""
    @Published private(set) var languageFilterActionTitle: String = ""
    @Published private(set) var personalizedTools = PersonalizedToolsDomainModel.emptyValue
    @Published private(set) var toolsList: [ToolListItemDomainModel] = Array()

    @Published var selectedToggle: PersonalizationToggleOptionValue = .personalized

    init(
        stepEmitter: FlowStepEmitter,
        pullToRefreshToolsUseCase: PullToRefreshToolsUseCase,
        getToolsStringsUseCase: GetToolsStringsUseCase,
        getAllToolsUseCase: GetAllToolsUseCase,
        getPersonalizedToolsUseCase: GetPersonalizedToolsUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase,
        favoritingToolMessageCache: FavoritingToolMessageCache,
        getSpotlightToolsUseCase: GetSpotlightToolsUseCase,
        getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase,
        getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase,
        getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase,
        toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase,
        getToolBannerUseCase: GetToolBannerUseCase,
        dataCache: DataCacheInterface
    ) {
        
        self.stepEmitter = stepEmitter
        self.pullToRefreshToolsUseCase = pullToRefreshToolsUseCase
        self.getToolsStringsUseCase = getToolsStringsUseCase
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getPersonalizedToolsUseCase = getPersonalizedToolsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLocalizationSettingsUseCase = getLocalizationSettingsUseCase
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getUserToolFilterCategoryUseCase = getUserToolFilterCategoryUseCase
        self.getUserToolFilterLanguageUseCase = getUserToolFilterLanguageUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        self.dataCache = dataCache
        
        pullToRefreshTools()
        
        Task {
            
            let favoritingToolMessageDisabled: Bool = await favoritingToolMessageCache.favoritingToolMessageDisabled
            
            showsFavoritingToolBanner = !favoritingToolMessageDisabled
        }
        
        if !GodToolsApp.showsPersonalization {
            selectedToggle = .all
        }
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)

        getLocalizationSettingsUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$localizationSettings)
        
        Publishers.CombineLatest3(
            $appLanguage.dropFirst(),
            $toolFilterLanguageSelection.dropFirst(),
            $localizationSettings
        )
        .map { (appLanguage: AppLanguageDomainModel, toolFilterLanguage: ToolFilterLanguageDomainModel, localizationSettings: UserLocalizationSettingsDomainModel?) in
            
            getPersonalizedToolsUseCase
                .execute(
                    appLanguage: appLanguage,
                    country: localizationSettings?.selectedCountry,
                    filterToolsByLanguage: toolFilterLanguage
                )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        } receiveValue: { [weak self] (personalizedTools: PersonalizedToolsDomainModel) in
            
            self?.personalizedTools = personalizedTools
        }
        .store(in: &cancellables)

        Publishers.CombineLatest3(
            $appLanguage.dropFirst(),
            $toolFilterLanguageSelection.dropFirst(),
            $toolFilterCategorySelection.dropFirst()
        )
        .map { (appLanguage: AppLanguageDomainModel, toolFilterLanguage: ToolFilterLanguageDomainModel, toolFilterCategory: ToolFilterCategoryDomainModel) in
            
            getAllToolsUseCase
                .execute(
                    appLanguage: appLanguage,
                    languageIdForAvailabilityText: toolFilterLanguage.id,
                    filterToolsByCategory: toolFilterCategory,
                    filterToolsByLanguage: toolFilterLanguage
                )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        } receiveValue: { [weak self] (allTools: [ToolListItemDomainModel]) in
            
            self?.allToolsList = allTools
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $personalizedTools,
            $allToolsList,
            $selectedToggle
        )
        .map { (personalizedTools: PersonalizedToolsDomainModel, allTools: [ToolListItemDomainModel], toggle: PersonalizationToggleOptionValue) in
            
            let toolsList: [ToolListItemDomainModel]
            
            switch toggle {
            case .personalized:
                toolsList = personalizedTools.tools
            case .all:
                toolsList = allTools
            }
            
            return Just(toolsList)
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (toolsList: [ToolListItemDomainModel]) in
            
            self?.toolsList = toolsList
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
                    appLanguage: appLanguage,
                    languageIdForAvailabilityText: toolFilterLanguage.id
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
                
                getUserToolFilterCategoryUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (categoryFilter: ToolFilterCategoryDomainModel) in
            
                self?.toolFilterCategorySelection = categoryFilter
                self?.categoryFilterActionTitle = categoryFilter.title
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getUserToolFilterLanguageUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languageFilter: ToolFilterLanguageDomainModel) in
            
                self?.toolFilterLanguageSelection = languageFilter
                self?.languageFilterActionTitle = languageFilter.languageNameTranslatedInAppLanguage
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        pullToRefreshToolsTask?.cancel()
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        let strings = getToolsStringsUseCase
            .execute(translateInLanguage: appLanguage)

        self.strings = strings

        toggleOptions = Self.getPersonalizedToggleOptions(strings: strings)
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
        
        Task {
            await trackActionAnalyticsUseCase.execute(
                properties: AnalyticsProperties(
                    screenName: analyticsScreenName,
                    siteSection: "",
                    siteSubSection: "",
                    appLanguage: nil,
                    contentLanguage: nil,
                    secondaryContentLanguage: nil
                ),
                actionName: AnalyticsConstants.ActionNames.openDetails,
                data: [
                    AnalyticsConstants.Keys.source: source,
                    AnalyticsConstants.Keys.tool: tool.analyticsToolAbbreviation
                ]
            )
        }
    }
    
    private func trackPageView() {
        
        Task {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: AnalyticsProperties(
                    screenName: analyticsScreenName,
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubSection,
                    appLanguage: nil,
                    contentLanguage: nil,
                    secondaryContentLanguage: nil
                )
            )
        }
        
        Task {
            await trackActionAnalyticsUseCase.execute(
                properties: AnalyticsProperties(
                    screenName: analyticsScreenName,
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubSection,
                    appLanguage: nil,
                    contentLanguage: nil,
                    secondaryContentLanguage: nil
                ),
                actionName: AnalyticsConstants.ActionNames.viewedToolsAction,
                data: nil
            )
        }
    }
    
    private static func cancelFavoriteToolTask(toolId: String) {
        Self.favoriteToolTasks[toolId]?.cancel()
        Self.favoriteToolTasks[toolId] = nil
    }
    
    private func toggleToolIsFavorited(toolId: String) {
        
        Self.cancelFavoriteToolTask(toolId: toolId)
        
        Self.favoriteToolTasks[toolId] = Task { [weak self] in
                
            _ = try await self?.toggleToolFavoritedUseCase
                .execute(toolId: toolId)
            
            Self.favoriteToolTasks[toolId] = nil
        }
    }
    
    private static func getPersonalizedToggleOptions(strings: ToolsStringsDomainModel) -> [PersonalizationToggleOption] {
        
        if !GodToolsApp.showsPersonalization {
            
            return [PersonalizationToggleOption(title: strings.allToolsToggleTitle, selection: .all, buttonAccessibility: .allTools)]
        }
        
        return [
            PersonalizationToggleOption(title: strings.personalizedToolToggleTitle, selection: .personalized, buttonAccessibility: .personalizedTools),
            PersonalizationToggleOption(title: strings.allToolsToggleTitle, selection: .all, buttonAccessibility: .allTools)
        ]
    }
    
    private func pullToRefreshTools() {
        
        pullToRefreshToolsTask?.cancel()
        
        pullToRefreshToolsTask = Task {
            
            try await pullToRefreshToolsUseCase
                .execute(
                    appLanguage: appLanguage,
                    country: localizationSettings?.selectedCountry,
                    filterToolsByLanguage: toolFilterLanguageSelection
                )
        }
    }
}

// MARK: - Inputs

extension ToolsViewModel {
    
    func pullToRefresh() {
        
        pullToRefreshTools()
    }
    
    func pageViewed() {
        
        trackPageView()
    }
    
    func closeFavoritingToolBannerTapped() {
        
        withAnimation {
            showsFavoritingToolBanner = false
        }
        
        Task {
            await favoritingToolMessageCache.disableFavoritingToolMessage()
        }
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
            getToolBannerUseCase: getToolBannerUseCase,
            dataCache: dataCache
        )
    }
    
    func toolCategoryFilterTapped() {
        
        stepEmitter.emit(step: AppFlowStep.toolCategoryFilterTappedFromTools)
    }
    
    func toolLanguageFilterTapped() {
        
        stepEmitter.emit(step: AppFlowStep.toolLanguageFilterTappedFromTools)
    }
    
    func spotlightToolFavoriteTapped(spotlightTool: SpotlightToolListItemDomainModel) {
     
        toggleToolIsFavorited(toolId: spotlightTool.dataModelId)
    }
    
    func spotlightToolTapped(spotlightTool: SpotlightToolListItemDomainModel) {
        
        trackToolTappedAnalytics(tool: spotlightTool)
        
        stepEmitter.emit(step: AppFlowStep.spotlightToolTappedFromTools(spotlightTool: spotlightTool, toolFilterLanguage: toolFilterLanguageSelection))
    }
    
    func toolFavoriteTapped(tool: ToolListItemDomainModel) {

        toggleToolIsFavorited(toolId: tool.dataModelId)
    }
    
    func toolTapped(tool: ToolListItemDomainModel) {

        trackToolTappedAnalytics(tool: tool)

        stepEmitter.emit(step: AppFlowStep.toolTappedFromTools(tool: tool, toolFilterLanguage: toolFilterLanguageSelection))
    }

    func changeLocalizationSettingsTapped() {

        stepEmitter.emit(step: AppFlowStep.changeLocalizationSettingsTappedFromTools)
    }

    func goToAllToolsTapped() {
        selectedToggle = .all
    }
}
