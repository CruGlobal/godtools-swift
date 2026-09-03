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
import Flow

@MainActor
final class ToolsViewModel: ObservableObject {
    
    typealias ToolId = String
    
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
    private let imageCache: ImageCacheInterface
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var pullToRefreshToolsTask: Task<Void, Error>?
    private var favoriteToolTasks: [ToolId: Task<Void, Error>] = Dictionary()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var toolFilterCategorySelection = ToolFilterCategoryDomainModel.emptyValue
    @Published private var selectedAllToolsFilterLanguage: ToolFilterLanguageDomainModel?
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
        imageCache: ImageCacheInterface
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
        self.imageCache = imageCache
                
        Task { [weak self] in
            
            let favoritingToolMessageDisabled: Bool = await favoritingToolMessageCache.favoritingToolMessageDisabled
            
            self?.showsFavoritingToolBanner = !favoritingToolMessageDisabled
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
            $selectedAllToolsFilterLanguage.dropFirst(),
            $localizationSettings
        )
        .map { (
            appLanguage: AppLanguageDomainModel,
            toolFilterLanguage: ToolFilterLanguageDomainModel?,
            localizationSettings: UserLocalizationSettingsDomainModel?
        ) in
            
            getPersonalizedToolsUseCase
                .execute(
                    appLanguage: appLanguage,
                    country: localizationSettings?.selectedCountry,
                    filterByLanguageId: toolFilterLanguage?.languageId
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
            $selectedAllToolsFilterLanguage.dropFirst(),
            $toolFilterCategorySelection.dropFirst()
        )
        .map { (
            appLanguage: AppLanguageDomainModel,
            toolFilterLanguage: ToolFilterLanguageDomainModel?,
            toolFilterCategory: ToolFilterCategoryDomainModel
        ) in
            
            getAllToolsUseCase
                .execute(
                    appLanguage: appLanguage,
                    languageIdForAvailabilityText: toolFilterLanguage?.languageId,
                    filterToolsByCategory: toolFilterCategory,
                    filterByLanguageId: toolFilterLanguage?.languageId
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
            $selectedAllToolsFilterLanguage.dropFirst()
        )
        .map { (
            appLanguage: AppLanguageDomainModel,
            toolFilterCategory: ToolFilterCategoryDomainModel,
            toolFilterLanguage: ToolFilterLanguageDomainModel?
        ) in
            
            getSpotlightToolsUseCase
                .execute(
                    appLanguage: appLanguage,
                    languageIdForAvailabilityText: toolFilterLanguage?.languageId
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
            
                self?.selectedAllToolsFilterLanguage = languageFilter
                self?.languageFilterActionTitle = languageFilter.languageNamePair.nameInAppLanguage
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
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let analyticsToolAbbreviation: String = tool.analyticsToolAbbreviation
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackActionAnalyticsUseCase.execute(
                properties: analyticsProperties,
                actionName: AnalyticsConstants.ActionNames.openDetails,
                data: [
                    AnalyticsConstants.Keys.source: source,
                    AnalyticsConstants.Keys.tool: analyticsToolAbbreviation
                ]
            )
        }
    }
    
    private func trackPageView() {
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase = self.trackScreenViewAnalyticsUseCase
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: analyticsProperties
            )
        }
        
        Task.detached {
            await trackActionAnalyticsUseCase.execute(
                properties: analyticsProperties,
                actionName: AnalyticsConstants.ActionNames.viewedToolsAction,
                data: nil
            )
        }
    }
    
    private func toggleToolIsFavorited(toolId: String) {
        
        let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase = self.toggleToolFavoritedUseCase
        
        favoriteToolTasks[toolId]?.cancel()
        
        favoriteToolTasks[toolId] = Task.detached {
                
            _ = try await toggleToolFavoritedUseCase
                .execute(toolId: toolId)
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
        
        pullToRefreshToolsTask = Task { [weak self] in

            guard let weakSelf = self else {
                return
            }
            
            try await weakSelf.pullToRefreshToolsUseCase
                .execute(
                    appLanguage: weakSelf.appLanguage,
                    country: weakSelf.localizationSettings?.selectedCountry,
                    filterToolsByLanguageId: weakSelf.selectedAllToolsFilterLanguage?.languageId
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
        
        let favoritingToolMessageCache: FavoritingToolMessageCache = self.favoritingToolMessageCache
        
        Task.detached {
            
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
            imageCache: imageCache
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
        
        stepEmitter.emit(step: AppFlowStep.spotlightToolTappedFromTools(spotlightTool: spotlightTool, toolFilterLanguageId: selectedAllToolsFilterLanguage?.languageId))
    }
    
    func toolFavoriteTapped(tool: ToolListItemDomainModel) {

        toggleToolIsFavorited(toolId: tool.dataModelId)
    }
    
    func toolTapped(tool: ToolListItemDomainModel) {

        trackToolTappedAnalytics(tool: tool)

        stepEmitter.emit(step: AppFlowStep.toolTappedFromTools(tool: tool, toolFilterLanguageId: selectedAllToolsFilterLanguage?.languageId))
    }

    func changeLocalizationSettingsTapped() {

        stepEmitter.emit(step: AppFlowStep.changeLocalizationSettingsTappedFromTools)
    }

    func goToAllToolsTapped() {
        selectedToggle = .all
    }
}
