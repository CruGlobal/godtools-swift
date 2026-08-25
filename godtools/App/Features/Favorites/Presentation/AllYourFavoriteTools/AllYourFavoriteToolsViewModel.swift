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
import Flow

@MainActor
final class AllYourFavoriteToolsViewModel: ObservableObject {
        
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let stepEmitter: FlowStepEmitter
    private let getAllYourFavoritedToolsStringsUseCase: GetAllYourFavoritedToolsStringsUseCase
    private let getYourFavoritedToolsUseCase: GetYourFavoritedToolsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let reorderFavoritedToolUseCase: ReorderFavoritedToolUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
    private let imageCache: ImageCacheInterface
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let didConfirmToolRemovalSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings = AllYourFavoritedToolsStringsDomainModel.emptyValue
    
    @Published var favoritedTools: [YourFavoritedToolDomainModel] = Array()
        
    init(
        stepEmitter: FlowStepEmitter,
        getAllYourFavoritedToolsStringsUseCase: GetAllYourFavoritedToolsStringsUseCase,
        getYourFavoritedToolsUseCase: GetYourFavoritedToolsUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase,
        reorderFavoritedToolUseCase: ReorderFavoritedToolUseCase,
        getToolBannerUseCase: GetToolBannerUseCase,
        imageCache: ImageCacheInterface,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getAllYourFavoritedToolsStringsUseCase = getAllYourFavoritedToolsStringsUseCase
        self.getYourFavoritedToolsUseCase = getYourFavoritedToolsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.reorderFavoritedToolUseCase = reorderFavoritedToolUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        self.imageCache = imageCache
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)

        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in

                getYourFavoritedToolsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        maxCount: nil
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (favoritedTools: [YourFavoritedToolDomainModel]) in
                
                self?.favoritedTools = favoritedTools
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

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getAllYourFavoritedToolsStringsUseCase
            .execute(appLanguage: appLanguage)
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
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase = self.trackScreenViewAnalyticsUseCase
        
        Task.detached {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: analyticsProperties
            )
        }
    }
    
    private func trackOpenFavoritedToolButtonAnalytics(tool: YourFavoritedToolDomainModel) {
       
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
                actionName: AnalyticsConstants.ActionNames.toolOpened,
                data: [
                    AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                    AnalyticsConstants.Keys.tool: analyticsToolAbbreviation
                ]
            )
        }
    }
    
    private func trackFavoritedToolDetailsButtonAnalytics(tool: YourFavoritedToolDomainModel) {
        
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
                    AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                    AnalyticsConstants.Keys.tool: analyticsToolAbbreviation
                ]
            )
        }
    }
    
    private func closePage() {
        stepEmitter.emit(step: AppFlowStep.backTappedFromAllYourFavoriteTools)
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
            getToolBannerUseCase: getToolBannerUseCase,
            imageCache: imageCache
        )
    }
    
    func toolDetailsTapped(tool: YourFavoritedToolDomainModel) {
        
        trackFavoritedToolDetailsButtonAnalytics(tool: tool)
        
        stepEmitter.emit(step: AppFlowStep.toolDetailsTappedFromAllYourFavoriteTools(tool: tool))
    }
    
    func openToolTapped(tool: YourFavoritedToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(tool: tool)
        
        stepEmitter.emit(step: AppFlowStep.openToolTappedFromAllYourFavoriteTools(tool: tool))
    }
    
    func unfavoriteToolTapped(tool: YourFavoritedToolDomainModel) {
        
        stepEmitter.emit(step: AppFlowStep.unfavoriteToolTappedFromAllYourFavoritedTools(tool: tool, didConfirmToolRemovalSubject: didConfirmToolRemovalSubject))
    }
    
    func toolTapped(tool: YourFavoritedToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(tool: tool)
        
        stepEmitter.emit(step: AppFlowStep.toolTappedFromAllYourFavoritedTools(tool: tool))
    }
    
    func toolMoved(fromOffsets source: IndexSet, toOffset destination: Int) {
        
        for index in source {
            
            guard index < favoritedTools.count && index >= 0 else {
                continue
            }
            
            let toolToMove: YourFavoritedToolDomainModel = favoritedTools[index]
            
            let newPosition: Int = index < destination ? destination - 1 : destination
            
            let reorderFavoritedToolUseCase: ReorderFavoritedToolUseCase = self.reorderFavoritedToolUseCase
            
            Task.detached {
                
                try await reorderFavoritedToolUseCase
                    .execute(
                        toolId: toolToMove.id,
                        originalPosition: index,
                        newPosition: newPosition
                    )
            }
        }
    }
}
