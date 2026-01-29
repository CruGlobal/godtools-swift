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

@MainActor class AllYourFavoriteToolsViewModel: ObservableObject {
        
    private let viewAllYourFavoritedToolsUseCase: ViewAllYourFavoritedToolsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let reorderFavoritedToolUseCase: ReorderFavoritedToolUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let didConfirmToolRemovalSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var sectionTitle: String = ""
    @Published var favoritedTools: [YourFavoritedToolDomainModel] = Array()
        
    init(flowDelegate: FlowDelegate?, viewAllYourFavoritedToolsUseCase: ViewAllYourFavoritedToolsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, reorderFavoritedToolUseCase: ReorderFavoritedToolUseCase, getToolBannerUseCase: GetToolBannerUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.viewAllYourFavoritedToolsUseCase = viewAllYourFavoritedToolsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.reorderFavoritedToolUseCase = reorderFavoritedToolUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewAllYourFavoritedToolsUseCase
                    .viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (domainModel: ViewAllYourFavoritedToolsDomainModel) in
                
                self?.sectionTitle = domainModel.interfaceStrings.sectionTitle

                self?.favoritedTools = domainModel.yourFavoritedTools
            })
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
    
    deinit {
        print("x deinit: \(type(of: self))")
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
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    private func trackOpenFavoritedToolButtonAnalytics(tool: YourFavoritedToolDomainModel) {
       
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.analyticsToolAbbreviation
            ]
        )
    }
    
    private func trackFavoritedToolDetailsButtonAnalytics(tool: YourFavoritedToolDomainModel) {
        
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
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.analyticsToolAbbreviation
            ]
        )
    }
    
    private func closePage() {
        flowDelegate?.navigate(step: .backTappedFromAllYourFavoriteTools)
    }
}

// MARK: - Inputs

extension AllYourFavoriteToolsViewModel {
    
    @objc func backTapped() {
        closePage()
    }
    
    func pageViewed() {
        
        trackPageView()
    }
    
    func getToolViewModel(tool: YourFavoritedToolDomainModel) -> ToolCardViewModel {
                
        return ToolCardViewModel(
            tool: tool,
            accessibility: .favoriteTool,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            getToolBannerUseCase: getToolBannerUseCase
        )
    }
    
    func toolDetailsTapped(tool: YourFavoritedToolDomainModel) {
        
        trackFavoritedToolDetailsButtonAnalytics(tool: tool)
        
        flowDelegate?.navigate(step: .toolDetailsTappedFromAllYourFavoriteTools(tool: tool))
    }
    
    func openToolTapped(tool: YourFavoritedToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(tool: tool)
        
        flowDelegate?.navigate(step: .openToolTappedFromAllYourFavoriteTools(tool: tool))
    }
    
    func unfavoriteToolTapped(tool: YourFavoritedToolDomainModel) {
        
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromAllYourFavoritedTools(tool: tool, didConfirmToolRemovalSubject: didConfirmToolRemovalSubject))
    }
    
    func toolTapped(tool: YourFavoritedToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(tool: tool)
        
        flowDelegate?.navigate(step: .toolTappedFromAllYourFavoritedTools(tool: tool))
    }
    
    func toolMoved(fromOffsets source: IndexSet, toOffset destination: Int) {
        for index in source {
            guard index < favoritedTools.count else { continue }
            let toolToMove = favoritedTools[index]
            
            var newIndex: Int
            if index < destination {
                newIndex = destination - 1
            } else {
                newIndex = destination
            }
            
            reorderFavoritedToolUseCase
                .reorderFavoritedToolPublisher(toolId: toolToMove.id, originalPosition: index, newPosition: newIndex)
                .sink { _ in
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &AllYourFavoriteToolsViewModel.backgroundCancellables)

        }
    }
}
