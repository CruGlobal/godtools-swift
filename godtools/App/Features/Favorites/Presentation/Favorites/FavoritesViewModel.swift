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

@MainActor class FavoritesViewModel: ObservableObject {
            
    private let resourcesRepository: ResourcesRepository
    private let getFavoritesStringsUseCase: GetFavoritesStringsUseCase
    private let getYourFavoritedToolsUseCase: GetYourFavoritedToolsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var strings = FavoritesStringsDomainModel.emptyValue
    @Published private(set) var showsOpenTutorialBanner: Bool = false
    @Published private(set) var featuredLessons: [FeaturedLessonDomainModel] = Array()
    @Published private(set) var yourFavoritedTools: [YourFavoritedToolDomainModel] = Array()
    @Published private(set) var isLoadingYourFavoritedTools: Bool = true
    
    init(flowDelegate: FlowDelegate, resourcesRepository: ResourcesRepository, getFavoritesStringsUseCase: GetFavoritesStringsUseCase, getYourFavoritedToolsUseCase: GetYourFavoritedToolsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, getToolBannerUseCase: GetToolBannerUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getFavoritesStringsUseCase = getFavoritesStringsUseCase
        self.getYourFavoritedToolsUseCase = getYourFavoritedToolsUseCase
        self.resourcesRepository = resourcesRepository
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getFeaturedLessonsUseCase = getFeaturedLessonsUseCase
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
                 
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getFavoritesStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (strings: FavoritesStringsDomainModel) in
                
                self?.strings = strings
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                Publishers.CombineLatest(
                    getYourFavoritedToolsUseCase
                        .execute(
                            appLanguage: appLanguage,
                            maxCount: 5
                        ),
                    getFeaturedLessonsUseCase
                        .getFeaturedLessonsPublisher(
                            appLanguage: appLanguage
                        )
                )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (yourFavoritedTools: [YourFavoritedToolDomainModel], featuredLessons: [FeaturedLessonDomainModel]) in
                
                self?.featuredLessons = featuredLessons
                self?.yourFavoritedTools = yourFavoritedTools
                
                self?.isLoadingYourFavoritedTools = false
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
        
        resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(requestPriority: .high, forceFetchFromRemote: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in

            }, receiveValue: { (result: ResourcesCacheSyncResult) in
                
            })
            .store(in: &cancellables)
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
        
        flowDelegate?.navigate(step: .openTutorialTappedFromTools)
    }
    
    func goToToolsTapped() {
        
        flowDelegate?.navigate(step: .goToToolsTappedFromFavorites)
    }
    
    func getFeaturedLessonViewModel(featuredLesson: FeaturedLessonDomainModel) -> LessonCardViewModel  {
                
        return LessonCardViewModel(
            lessonListItem: featuredLesson,
            getToolBannerUseCase: getToolBannerUseCase
        )
    }
    
    func featuredLessonTapped(featuredLesson: FeaturedLessonDomainModel) {
                
        flowDelegate?.navigate(step: .featuredLessonTappedFromFavorites(featuredLesson: featuredLesson))
        trackFeaturedLessonTappedAnalytics(featuredLesson: featuredLesson)
    }
    
    func getYourFavoriteToolViewModel(tool: YourFavoritedToolDomainModel) -> ToolCardViewModel {
                
        return ToolCardViewModel(
            tool: tool,
            accessibility: .favoriteTool,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            getToolBannerUseCase: getToolBannerUseCase
        )
    }
    
    func viewAllFavoriteToolsTapped() {
        
        flowDelegate?.navigate(step: .viewAllFavoriteToolsTappedFromFavorites)
    }
    
    func toolDetailsTapped(tool: YourFavoritedToolDomainModel) {
        
        trackFavoritedToolDetailsButtonAnalytics(tool: tool)
        
        flowDelegate?.navigate(step: .toolDetailsTappedFromFavorites(tool: tool))
    }
    
    func openToolTapped(tool: YourFavoritedToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(tool: tool)
        
        flowDelegate?.navigate(step: .openToolTappedFromFavorites(tool: tool))
    }
    
    func unfavoriteToolTapped(tool: YourFavoritedToolDomainModel) {
        
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavorites(tool: tool))
    }
    
    func toolTapped(tool: YourFavoritedToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(tool: tool)
        
        flowDelegate?.navigate(step: .toolTappedFromFavorites(tool: tool))
    }
}
