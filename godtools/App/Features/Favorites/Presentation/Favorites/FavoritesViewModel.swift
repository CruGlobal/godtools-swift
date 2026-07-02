//
//  FavoritesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {
            
    private let stepEmitter: FlowStepEmitter
    private let resourcesRepository: ResourcesRepository
    private let getFavoritesStringsUseCase: GetFavoritesStringsUseCase
    private let getYourFavoritedToolsUseCase: GetYourFavoritedToolsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
    private let inMemoryDataCache: InMemoryDataCache
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var pullToRefreshTask: Task<Void, Error>?
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings = FavoritesStringsDomainModel.emptyValue
    @Published private(set) var showsOpenTutorialBanner: Bool = false
    @Published private(set) var featuredLessons: [FeaturedLessonDomainModel] = Array()
    @Published private(set) var yourFavoritedTools: [YourFavoritedToolDomainModel] = Array()
    
    init(
        stepEmitter: FlowStepEmitter,
        resourcesRepository: ResourcesRepository,
        getFavoritesStringsUseCase: GetFavoritesStringsUseCase,
        getYourFavoritedToolsUseCase: GetYourFavoritedToolsUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase,
        getToolBannerUseCase: GetToolBannerUseCase,
        inMemoryDataCache: InMemoryDataCache,
        disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase,
        getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase,
        getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getFavoritesStringsUseCase = getFavoritesStringsUseCase
        self.getYourFavoritedToolsUseCase = getYourFavoritedToolsUseCase
        self.resourcesRepository = resourcesRepository
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        self.inMemoryDataCache = inMemoryDataCache
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getFeaturedLessonsUseCase = getFeaturedLessonsUseCase
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
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

                getFeaturedLessonsUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (featuredLessons: [FeaturedLessonDomainModel]) in
                
                self?.featuredLessons = featuredLessons
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getYourFavoritedToolsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        maxCount: 5
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (yourFavoritedTools: [YourFavoritedToolDomainModel]) in
                
                self?.yourFavoritedTools = yourFavoritedTools
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getOptInOnboardingBannerEnabledUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isEnabled: Bool) in
                self?.showsOpenTutorialBanner = isEnabled
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        pullToRefreshTask?.cancel()
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getFavoritesStringsUseCase
            .execute(appLanguage: appLanguage)
    }

    private var analyticsScreenName: String {
        return "Favorites"
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
            
        trackActionAnalyticsUseCase.trackAction(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.viewedMyToolsAction,
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
    }
    
    private func trackFeaturedLessonTappedAnalytics(featuredLesson: FeaturedLessonDomainModel) {
       
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.featured,
                AnalyticsConstants.Keys.tool: featuredLesson.analyticsToolName
            ]
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
    
    private func disableOpenTutorialBanner() {
        
        withAnimation {
            showsOpenTutorialBanner = false
        }
        
        disableOptInOnboardingBannerUseCase.execute()
    }
}

// MARK: - Inputs

extension FavoritesViewModel {
    
    func pageViewed() {
        
        trackPageView()
    }
    
    func pullToRefresh() {
        
        pullToRefreshTask?.cancel()
        
        pullToRefreshTask = Task {
            
            _ = try await resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments(
                requestPriority: .high,
                forceFetchFromRemote: true
            )
            
            return Void()
        }
    }
    
    func closeOpenTutorialBannerTapped() {
        
        disableOpenTutorialBanner()
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: "home",
            actionName: AnalyticsConstants.ActionNames.tutorialHomeDismiss,
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [AnalyticsConstants.Keys.tutorialDismissed: 1]
        )
    }
    
    func openTutorialBannerTapped() {
        
        disableOpenTutorialBanner()
        
        stepEmitter.emit(step: AppFlowStep.openTutorialTappedFromTools)
    }
    
    func goToToolsTapped() {
        
        stepEmitter.emit(step: AppFlowStep.goToToolsTappedFromFavorites)
    }
    
    func getFeaturedLessonViewModel(featuredLesson: FeaturedLessonDomainModel) -> LessonCardViewModel  {
                
        return LessonCardViewModel(
            lessonListItem: featuredLesson,
            getToolBannerUseCase: getToolBannerUseCase,
            inMemoryDataCache: inMemoryDataCache
        )
    }
    
    func featuredLessonTapped(featuredLesson: FeaturedLessonDomainModel) {
                
        stepEmitter.emit(step: AppFlowStep.featuredLessonTappedFromFavorites(featuredLesson: featuredLesson))
        trackFeaturedLessonTappedAnalytics(featuredLesson: featuredLesson)
    }
    
    func getYourFavoriteToolViewModel(tool: YourFavoritedToolDomainModel) -> ToolCardViewModel {
                
        return ToolCardViewModel(
            tool: tool,
            accessibility: .favoriteTool,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            getToolBannerUseCase: getToolBannerUseCase,
            inMemoryDataCache: inMemoryDataCache
        )
    }
    
    func viewAllFavoriteToolsTapped() {
        
        stepEmitter.emit(step: AppFlowStep.viewAllFavoriteToolsTappedFromFavorites)
    }
    
    func toolDetailsTapped(tool: YourFavoritedToolDomainModel) {
        
        trackFavoritedToolDetailsButtonAnalytics(tool: tool)
        
        stepEmitter.emit(step: AppFlowStep.toolDetailsTappedFromFavorites(tool: tool))
    }
    
    func openToolTapped(tool: YourFavoritedToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(tool: tool)
        
        stepEmitter.emit(step: AppFlowStep.openToolTappedFromFavorites(tool: tool))
    }
    
    func unfavoriteToolTapped(tool: YourFavoritedToolDomainModel) {
        
        stepEmitter.emit(step: AppFlowStep.unfavoriteToolTappedFromFavorites(tool: tool))
    }
    
    func toolTapped(tool: YourFavoritedToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(tool: tool)
        
        stepEmitter.emit(step: AppFlowStep.toolTappedFromFavorites(tool: tool))
    }
}
