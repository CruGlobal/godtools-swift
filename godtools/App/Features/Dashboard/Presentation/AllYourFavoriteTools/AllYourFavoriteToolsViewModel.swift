//
//  AllYourFavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class AllYourFavoriteToolsViewModel: ObservableObject {
        
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let localizationServices: LocalizationServices
    private let attachmentsRepository: AttachmentsRepository
    private let analytics: AnalyticsContainer
    private let didConfirmToolRemovalSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var sectionTitle: String = ""
    @Published var favoritedTools: [ToolDomainModel] = Array()
        
    init(flowDelegate: FlowDelegate?, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, localizationServices: LocalizationServices, attachmentsRepository: AttachmentsRepository, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.localizationServices = localizationServices
        self.attachmentsRepository = attachmentsRepository
        self.analytics = analytics
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (primaryLanguage: LanguageDomainModel?) in
                
                self?.sectionTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: primaryLanguage?.localeIdentifier, key: "favorites.favoriteTools.title")
            }
            .store(in: &cancellables)
        
        getAllFavoritedToolsUseCase.getAllFavoritedToolsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (favoritedTools: [ToolDomainModel]) in
                
                withAnimation {
                    self?.favoritedTools = favoritedTools
                }
                
            }
            .store(in: &cancellables)
        
        didConfirmToolRemovalSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (void: Void) in
                
                let toolCount: Int = self?.favoritedTools.count ?? 0
                
                if toolCount <= 1 {
                    self?.closePage()
                }
            }
            .store(in: &cancellables)
    }
    
    private var analyticsScreenName: String {
        return "All Favorites"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
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
    }
    
    private func trackOpenFavoritedToolButtonAnalytics(for tool: ResourceModel) {
       
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
    
    private func trackFavoritedToolDetailsButtonAnalytics(for tool: ResourceModel) {
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
    
    private func closePage() {
        flowDelegate?.navigate(step: .backTappedFromAllYourFavoriteTools)
    }
}

// MARK: - Inputs

extension AllYourFavoriteToolsViewModel {
    
    @objc func backTappedFromAllFavoriteTools() {
        closePage()
    }
    
    func pageViewed() {
        
        trackPageView()
    }
    
    func getToolViewModel(tool: ToolDomainModel) -> ToolCardViewModel {
                
        return ToolCardViewModel(
            tool: tool,
            localizationServices: localizationServices,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func toolDetailsTapped(tool: ToolDomainModel) {
        
        trackFavoritedToolDetailsButtonAnalytics(for: tool.resource)
        
        flowDelegate?.navigate(step: .toolDetailsTappedFromAllYourFavoriteTools(tool: tool))
    }
    
    func openToolTapped(tool: ToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(for: tool.resource)
        
        flowDelegate?.navigate(step: .openToolTappedFromAllYourFavoriteTools(tool: tool))
    }
    
    func toolFavoriteTapped(tool: ToolDomainModel) {
        
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromAllYourFavoritedTools(tool: tool, didConfirmToolRemovalSubject: didConfirmToolRemovalSubject))
    }
    
    func toolTapped(tool: ToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(for: tool.resource)
        
        flowDelegate?.navigate(step: .toolTappedFromAllYourFavoritedTools(tool: tool))
    }
}
