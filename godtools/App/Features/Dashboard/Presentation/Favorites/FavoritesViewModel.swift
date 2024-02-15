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

class FavoritesViewModel: ObservableObject {
            
    private let resourcesRepository: ResourcesRepository
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let attachmentsRepository: AttachmentsRepository
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let maxNumberOfYourFavoriteToolsToDisplay: Int = 5
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
        
    @Published var openTutorialBannerMessage: String = ""
    @Published var openTutorialBannerButtonTitle: String = ""
    @Published var showsOpenTutorialBanner: Bool = false
    @Published var welcomeTitle: String = ""
    @Published var featuredLessonsTitle: String = ""
    @Published var featuredLessons: [FeaturedLessonDomainModel] = Array()
    @Published var yourFavoriteToolsTitle: String = ""
    @Published var viewAllFavoriteToolsButtonTitle: String = ""
    @Published var yourFavoriteTools: [ToolDomainModel] = Array()
    @Published var isLoadingYourFavoritedTools: Bool = true
    @Published var noFavoriteToolsTitle: String = ""
    @Published var noFavoriteToolsDescription: String = ""
    @Published var noFavoriteToolsButtonText: String = ""
    
    init(flowDelegate: FlowDelegate, resourcesRepository: ResourcesRepository, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, attachmentsRepository: AttachmentsRepository, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resourcesRepository = resourcesRepository
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.attachmentsRepository = attachmentsRepository
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getFeaturedLessonsUseCase = getFeaturedLessonsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
                 
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "openTutorial.showTutorialLabel.text")
            .receive(on: DispatchQueue.main)
            .assign(to: &$openTutorialBannerMessage)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "openTutorial.openTutorialButton.title")
            .receive(on: DispatchQueue.main)
            .assign(to: &$openTutorialBannerButtonTitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "favorites.pageTitle")
            .receive(on: DispatchQueue.main)
            .assign(to: &$welcomeTitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "favorites.favoriteLessons.title")
            .receive(on: DispatchQueue.main)
            .assign(to: &$featuredLessonsTitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "favorites.favoriteTools.title")
            .receive(on: DispatchQueue.main)
            .assign(to: &$yourFavoriteToolsTitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "favorites.favoriteTools.viewAll")
            .receive(on: DispatchQueue.main)
            .assign(to: &$viewAllFavoriteToolsButtonTitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "favorites.noTools.title")
            .receive(on: DispatchQueue.main)
            .assign(to: &$noFavoriteToolsTitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "favorites.noTools.description")
            .receive(on: DispatchQueue.main)
            .assign(to: &$noFavoriteToolsDescription)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "favorites.noTools.button")
            .receive(on: DispatchQueue.main)
            .assign(to: &$noFavoriteToolsButtonText)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<Bool, Never> in
                return getOptInOnboardingBannerEnabledUseCase
                    .getBannerIsEnabled(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isEnabled: Bool) in
                self?.showsOpenTutorialBanner = isEnabled
            }
            .store(in: &cancellables)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<[FeaturedLessonDomainModel], Never> in
                
                return getFeaturedLessonsUseCase
                    .getFeaturedLessonsPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (featuredLessons: [FeaturedLessonDomainModel]) in
                
                self?.featuredLessons = featuredLessons
            }
            .store(in: &cancellables)
        
        getAllFavoritedToolsUseCase.getAllFavoritedToolsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (yourFavoriteTools: [ToolDomainModel]) in
                
                let maxNumberOfYourFavoriteToolsToDisplay: Int = self?.maxNumberOfYourFavoriteToolsToDisplay ?? 0
                var maxYourFavoritesToDisplay: [ToolDomainModel] = Array()
                
                for index in 0 ..< maxNumberOfYourFavoriteToolsToDisplay {
                    if index < yourFavoriteTools.count {
                        maxYourFavoritesToDisplay.append(yourFavoriteTools[index])
                    }
                }
                
                withAnimation {
                    self?.yourFavoriteTools = maxYourFavoritesToDisplay
                }
                
                self?.isLoadingYourFavoritedTools = false
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
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
            
        trackActionAnalyticsUseCase.trackAction(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.viewedMyToolsAction,
            siteSection: "",
            siteSubSection: "",
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
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.featured,
                AnalyticsConstants.Keys.tool: featuredLesson.analyticsToolName
              ]
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
    
    private func disableOpenTutorialBanner() {
        
        withAnimation {
            showsOpenTutorialBanner = false
        }
        
        disableOptInOnboardingBannerUseCase.disableOptInOnboardingBanner()
    }
}

// MARK: - Inputs

extension FavoritesViewModel {
    
    func pageViewed() {
        
        trackPageView()
    }
    
    func pullToRefresh() {
        
        resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .sink(receiveCompletion: { completed in

            }, receiveValue: { (result: RealmResourcesCacheSyncResult) in
                
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
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func featuredLessonTapped(featuredLesson: FeaturedLessonDomainModel) {
                
        flowDelegate?.navigate(step: .featuredLessonTappedFromFavorites(featuredLesson: featuredLesson))
        trackFeaturedLessonTappedAnalytics(featuredLesson: featuredLesson)
    }
    
    func getYourFavoriteToolViewModel(tool: ToolDomainModel) -> ToolCardViewModel {
                
        return ToolCardViewModel(
            tool: tool,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase,
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func viewAllFavoriteToolsTapped() {
        
        flowDelegate?.navigate(step: .viewAllFavoriteToolsTappedFromFavorites)
    }
    
    func toolDetailsTapped(tool: ToolDomainModel) {
        
        trackFavoritedToolDetailsButtonAnalytics(for: tool.resource)
        
        flowDelegate?.navigate(step: .toolDetailsTappedFromFavorites(tool: tool))
    }
    
    func openToolTapped(tool: ToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(for: tool.resource)
        
        flowDelegate?.navigate(step: .openToolTappedFromFavorites(tool: tool))
    }
    
    func toolFavoriteTapped(tool: ToolDomainModel) {
        
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavorites(tool: tool))
    }
    
    func toolTapped(tool: ToolDomainModel) {
        
        trackOpenFavoritedToolButtonAnalytics(for: tool.resource)
        
        flowDelegate?.navigate(step: .toolTappedFromFavorites(tool: tool))
    }
}
