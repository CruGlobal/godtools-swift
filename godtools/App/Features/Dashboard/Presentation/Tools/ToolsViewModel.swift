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
    
    typealias ToolId = String
    
    private static var favoriteToolCancellables: Dictionary<ToolId, AnyCancellable?> = Dictionary()
    
    private let resourcesRepository: ResourcesRepository
    private let viewToolsUseCase: ViewToolsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getUserFiltersUseCase: GetUserFiltersUseCase
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
    @Published var spotlightTools: [SpotlightToolListItemDomainModel] = Array()
    @Published var filterTitle: String = ""
    @Published var categoryFilterButtonTitle: String = ""
    @Published var languageFilterButtonTitle: String = ""
    @Published var allTools: [ToolListItemDomainModel] = Array()
    @Published var isLoadingAllTools: Bool = true
        
    init(flowDelegate: FlowDelegate, resourcesRepository: ResourcesRepository, viewToolsUseCase: ViewToolsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, favoritingToolMessageCache: FavoritingToolMessageCache, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getUserFiltersUseCase: GetUserFiltersUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.flowDelegate = flowDelegate
        self.resourcesRepository = resourcesRepository
        self.viewToolsUseCase = viewToolsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getUserFiltersUseCase = getUserFiltersUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.attachmentsRepository = attachmentsRepository
        
        showsFavoritingToolBanner = !favoritingToolMessageCache.favoritingToolMessageDisabled
        
        let temporaryLanguageFilterValue = LanguageFilterDomainModel.anyLanguage(text: "Any language", toolsAvailableText: "")
        let temporaryCategoryFilterValue = CategoryFilterDomainModel.anyCategory(text: "Any category", toolsAvailableText: "")
        toolFilterLanguageSelectionPublisher = CurrentValueSubject(temporaryLanguageFilterValue)
        toolFilterCategorySelectionPublisher = CurrentValueSubject(temporaryCategoryFilterValue)
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<(ViewToolsDomainModel, [SpotlightToolListItemDomainModel]), Never> in
                
                return Publishers.CombineLatest(
                    viewToolsUseCase.viewPublisher(appLanguage: appLanguage),
                    getSpotlightToolsUseCase.getSpotlightToolsPublisher(appLanguage: appLanguage)
                )
                .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewToolsDomainModel, spotlightTools: [SpotlightToolListItemDomainModel]) in
                    
                self?.favoritingToolBannerMessage = domainModel.interfaceStrings.favoritingToolBannerMessage
                self?.toolSpotlightTitle = domainModel.interfaceStrings.toolSpotlightTitle
                self?.toolSpotlightSubtitle = domainModel.interfaceStrings.toolSpotlightSubtitle
                self?.filterTitle = domainModel.interfaceStrings.filterTitle
                
                self?.spotlightTools = spotlightTools
                
                self?.allTools = domainModel.tools
                self?.isLoadingAllTools = false
            }
            .store(in: &cancellables)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap { appLanguage in
                
                return getUserFiltersUseCase.getUserFiltersPublisher(translatedInAppLanguage: appLanguage)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userFilters in
              
                self?.toolFilterCategorySelectionPublisher.send(userFilters.categoryFilter)
                self?.toolFilterLanguageSelectionPublisher.send(userFilters.languageFilter)
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
        
        categoryFilterButtonTitle = toolFilterCategorySelectionPublisher.value.categoryButtonText
    }
    
    private func updateLanguageButtonText() {
        
        languageFilterButtonTitle = toolFilterLanguageSelectionPublisher.value.languageButtonText
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
    
    private func toggleToolIsFavorited(toolId: String) {
        
        ToolsViewModel.favoriteToolCancellables[toolId] = toggleToolFavoritedUseCase
            .toggleFavoritedPublisher(toolId: toolId)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (domainModel: ToolIsFavoritedDomainModel) in
                
            })
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
    
    func getSpotlightToolViewModel(spotlightTool: SpotlightToolListItemDomainModel) -> ToolCardViewModel {
        return getToolViewModel(tool: spotlightTool)
    }
    
    func getToolItemViewModel(tool: ToolListItemDomainModel) -> ToolCardViewModel {
        return getToolViewModel(tool: tool)
    }
    
    private func getToolViewModel(tool: ToolListItemDomainModelInterface) -> ToolCardViewModel {
        
        return ToolCardViewModel(
            tool: tool,
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
    
    func spotlightToolFavoriteTapped(spotlightTool: SpotlightToolListItemDomainModel) {
     
        toggleToolIsFavorited(toolId: spotlightTool.dataModelId)
    }
    
    func spotlightToolTapped(spotlightTool: SpotlightToolListItemDomainModel) {
        
        trackToolTappedAnalytics(tool: spotlightTool)
        
        flowDelegate?.navigate(step: .spotlightToolTappedFromTools(spotlightTool: spotlightTool, toolFilterLanguage: toolFilterLanguageSelectionPublisher.value))
    }
    
    func toolFavoriteTapped(tool: ToolListItemDomainModel) {

        toggleToolIsFavorited(toolId: tool.dataModelId)
    }
    
    func toolTapped(tool: ToolListItemDomainModel) {
        
        trackToolTappedAnalytics(tool: tool)
        
        flowDelegate?.navigate(step: .toolTappedFromTools(tool: tool, toolFilterLanguage: toolFilterLanguageSelectionPublisher.value))
    }
}
