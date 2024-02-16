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
    
    private let resourcesRepository: ResourcesRepository
    private let viewToolsUseCase: ViewToolsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let toolFilterLanguageSelectionPublisher: CurrentValueSubject<LanguageFilterDomainModel, Never>
    private let toolFilterCategorySelectionPublisher: CurrentValueSubject<CategoryFilterDomainModel, Never>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
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
        
    init(flowDelegate: FlowDelegate, resourcesRepository: ResourcesRepository, viewToolsUseCase: ViewToolsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, favoritingToolMessageCache: FavoritingToolMessageCache, getAllToolsUseCase: GetAllToolsUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolFilterCategoriesUseCase: GetToolFilterCategoriesUseCase, getToolFilterLanguagesUseCase: GetToolFilterLanguagesUseCase, getUserFiltersUseCase: GetUserFiltersUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.flowDelegate = flowDelegate
        self.resourcesRepository = resourcesRepository
        self.viewToolsUseCase = viewToolsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.attachmentsRepository = attachmentsRepository
        
        showsFavoritingToolBanner = !favoritingToolMessageCache.favoritingToolMessageDisabled
        
        let anyLanguageSelection = getToolFilterLanguagesUseCase.getAnyLanguageFilterDomainModel()
        let anyCategorySelection = getToolFilterCategoriesUseCase.getAnyCategoryDomainModel()
        toolFilterLanguageSelectionPublisher = CurrentValueSubject(anyLanguageSelection)
        toolFilterCategorySelectionPublisher = CurrentValueSubject(anyCategorySelection)
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<(ViewToolsDomainModel), Never> in
                
                return viewToolsUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewToolsDomainModel) in
                    
                self?.favoritingToolBannerMessage = domainModel.interfaceStrings.favoritingToolBannerMessage
                self?.toolSpotlightTitle = domainModel.interfaceStrings.toolSpotlightTitle
                self?.toolSpotlightSubtitle = domainModel.interfaceStrings.toolSpotlightSubtitle
                self?.filterTitle = domainModel.interfaceStrings.filterTitle
            }
            .store(in: &cancellables)
        
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
    
    deinit {
        print("x deinit: \(type(of: self))")
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
        
        resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .sink(receiveCompletion: { completed in

            }, receiveValue: { (result: RealmResourcesCacheSyncResult) in
                
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
    
    func getToolViewModel(tool: ToolDomainModel) -> ToolCardViewModel {
        
        return ToolCardViewModel(
            tool: tool,
            alternateLanguage: toolFilterLanguageSelectionPublisher.value.language,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
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
        
        flowDelegate?.navigate(step: .spotlightToolTappedFromTools(spotlightTool: spotlightTool, toolFilterLanguage: toolFilterLanguageSelectionPublisher.value))
    }
    
    func toolFavoriteTapped(tool: ToolDomainModel) {

        toggleToolIsFavorited(tool: tool)
    }
    
    func toolTapped(tool: ToolDomainModel) {
        
        trackToolTappedAnalytics(tool: tool, isSpotlight: false)
        
        flowDelegate?.navigate(step: .toolTappedFromTools(tool: tool, toolFilterLanguage: toolFilterLanguageSelectionPublisher.value))
    }
}
