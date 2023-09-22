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
    private let attachmentsRepository: AttachmentsRepository
    private let getInterfaceStringUseCase: GetInterfaceStringUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let didConfirmToolRemovalSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var sectionTitle: String = ""
    @Published var favoritedTools: [ToolDomainModel] = Array()
        
    init(flowDelegate: FlowDelegate?, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, attachmentsRepository: AttachmentsRepository, getInterfaceStringUseCase: GetInterfaceStringUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.attachmentsRepository = attachmentsRepository
        self.getInterfaceStringUseCase = getInterfaceStringUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        getInterfaceStringUseCase.getStringPublisher(id: "favorites.favoriteTools.title")
            .receive(on: DispatchQueue.main)
            .assign(to: \.sectionTitle, on: self)
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
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    private func trackOpenFavoritedToolButtonAnalytics(for tool: ResourceModel) {
       
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
    }
    
    private func trackFavoritedToolDetailsButtonAnalytics(for tool: ResourceModel) {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
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
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            getInterfaceStringUseCase: getInterfaceStringUseCase,
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
