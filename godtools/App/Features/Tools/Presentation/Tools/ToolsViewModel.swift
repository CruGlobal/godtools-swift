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
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var toolFilterCategorySelection: ToolFilterCategoryDomainModel = ToolFilterAnyCategoryDomainModel.emptyValue
    @Published private var toolFilterLanguageSelection: ToolFilterLanguageDomainModel = ToolFilterAnyLanguageDomainModel.emptyValue
    @Published private var localizationSettings: UserLocalizationSettingsDomainModel?
    
    @Published private(set) var toggleOptions: [PersonalizationToggleOption] = ToolsViewModel.getToggleOptions(strings: ToolsStringsDomainModel.emptyValue)
    @Published private(set) var strings: ToolsStringsDomainModel = .emptyValue
    @Published private(set) var showsFavoritingToolBanner: Bool = false
    @Published private(set) var spotlightTools: [SpotlightToolListItemDomainModel] = Array()
    @Published private(set) var categoryFilterButtonTitle: String = ""
    @Published private(set) var languageFilterButtonTitle: String = ""
    @Published private(set) var allTools: [ToolListItemDomainModel] = Array()
    @Published private(set) var isLoadingAllTools: Bool = true
    @Published private(set) var personalizationUnavailableState: PersonalizedToolsUnavailableDomainModel?

    @Published var selectedToggle: PersonalizationToggleOptionValue = .personalized

    var isPersonalizationUnavailable: Bool {
        return selectedToggle == .personalized &&
                personalizationUnavailableState != nil &&
                !isLoadingAllTools
    }
        
    init(flowDelegate: FlowDelegate, pullToRefreshToolsUseCase: PullToRefreshToolsUseCase, getToolsStringsUseCase: GetToolsStringsUseCase, getAllToolsUseCase: GetAllToolsUseCase, getPersonalizedToolsUseCase: GetPersonalizedToolsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase, favoritingToolMessageCache: FavoritingToolMessageCache, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getUserToolFilterCategoryUseCase: GetUserToolFilterCategoryUseCase, getUserToolFilterLanguageUseCase: GetUserToolFilterLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, getToolBannerUseCase: GetToolBannerUseCase) {

        self.flowDelegate = flowDelegate
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
        
        showsFavoritingToolBanner = !favoritingToolMessageCache.favoritingToolMessageDisabled
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        getLocalizationSettingsUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$localizationSettings)
        
        Publishers.CombineLatest4(
            $appLanguage,
            Publishers.CombineLatest(
                $toolFilterCategorySelection,
                $toolFilterLanguageSelection,
            ),
            $localizationSettings,
            $selectedToggle
        )
        .dropFirst()
        .map { [weak self] (appLanguage, toolFilters, localizationSettings, toggle) -> AnyPublisher<ToolsResultDomainModel, Error> in

            let (toolFilterCategory, toolFilterLanguage) = toolFilters

            guard let self = self else {
                return Just(ToolsResultDomainModel.empty)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            switch toggle {

            case .personalized:
                return self.getPersonalizedToolsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        country: localizationSettings?.selectedCountry,
                        filterToolsByLanguage: toolFilterLanguage
                    )

            case .all:
                return getAllToolsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        languageIdForAvailabilityText: toolFilterLanguage.languageDataModelId,
                        filterToolsByCategory: toolFilterCategory,
                        filterToolsByLanguage: toolFilterLanguage
                    )
                    .map { tools in
                        ToolsResultDomainModel(
                            tools: tools,
                            unavailableStrings: nil
                        )
                    }
                    .eraseToAnyPublisher()
            }
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in

        }, receiveValue: { [weak self] (result: ToolsResultDomainModel) in

            self?.allTools = result.tools
            self?.personalizationUnavailableState = result.unavailableStrings
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
            .sink { [weak self] (strings: ToolsStringsDomainModel) in
                
                self?.strings = strings
                
                self?.toggleOptions = Self.getToggleOptions(strings: strings)
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
                
                getUserToolFilterCategoryUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (categoryFilter: ToolFilterCategoryDomainModel) in
            
                self?.toolFilterCategorySelection = categoryFilter
                self?.categoryFilterButtonTitle = categoryFilter.categoryButtonText
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
                self?.languageFilterButtonTitle = languageFilter.languageButtonText
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
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { (domainModel: ToolIsFavoritedDomainModel) in
                
            })
    }
    
    private static func getToggleOptions(strings: ToolsStringsDomainModel) -> [PersonalizationToggleOption] {
        
        return [
            PersonalizationToggleOption(title: strings.personalizedToolToggleTitle, selection: .personalized, buttonAccessibility: .personalizedTools),
            PersonalizationToggleOption(title: strings.allToolsToggleTitle, selection: .all, buttonAccessibility: .allTools)
        ]
    }
}

// MARK: - Inputs

extension ToolsViewModel {
    
    func pullToRefresh() {

        pullToRefreshToolsUseCase
            .execute(
                appLanguage: appLanguage,
                country: localizationSettings?.selectedCountry,
                filterToolsByLanguage: toolFilterLanguageSelection
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in

            }, receiveValue: { _ in

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

    func goToAllToolsTapped() {
        selectedToggle = .all
    }
}
