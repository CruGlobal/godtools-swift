//
//  FavoritesContentViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Combine

protocol FavoritesContentViewModelDelegate: AnyObject {
    func favoriteToolsViewGoToToolsTapped()
}

class FavoritesContentViewModel: ObservableObject {
            
    private let dataDownloader: InitialDataDownloader
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let translationsRepository: TranslationsRepository
    private weak var delegate: FavoritesContentViewModelDelegate?
    
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
        
    private(set) lazy var featuredLessonCardsViewModel: FeaturedLessonCardsViewModel = {
        return FeaturedLessonCardsViewModel(
            dataDownloader: dataDownloader,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getFeaturedLessonsUseCase: getFeaturedLessonsUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            translationsRepository: translationsRepository
        )
    }()
    private(set) lazy var favoriteToolsViewModel: FavoriteToolsViewModel = {
        return FavoriteToolsViewModel(
            dataDownloader: dataDownloader,
            localizationServices: localizationServices,
            getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: self
        )
    }()
        
    @Published var pageTitle: String = ""
    @Published var hideTutorialBanner: Bool = true
    @Published var isLoading: Bool = true
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, analytics: AnalyticsContainer, translationsRepository: TranslationsRepository, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.translationsRepository = translationsRepository
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getFeaturedLessonsUseCase = getFeaturedLessonsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
                                
        getOptInOnboardingBannerEnabledUseCase.getBannerIsEnabled()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                
                self?.hideTutorialBanner = !isEnabled
            }
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] primaryLanguage in
                
                self?.setupTitle(with: primaryLanguage)
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension FavoritesContentViewModel {
    
    func lessonTapped(lesson: LessonDomainModel) {
        
        flowDelegate?.navigate(step: .lessonTappedFromFeaturedLessons(lesson: lesson))
        trackFeaturedLessonTappedAnalytics(for: lesson)
    }
}

// MARK: - Public

extension FavoritesContentViewModel {
    func setDelegate(delegate: FavoritesContentViewModelDelegate) {
        self.delegate = delegate
    }
    
    func refreshData() {
        dataDownloader.downloadInitialData()
    }
    
    func getTutorialBannerViewModel() -> OpenTutorialBannerViewModel {
        
        return OpenTutorialBannerViewModel(
            flowDelegate: flowDelegate,
            localizationServices: localizationServices,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            analytics: analytics,
            delegate: self
        )
    }
}

// MARK: - Private

extension FavoritesContentViewModel {
    
    private func setupTitle(with language: LanguageDomainModel?) {

        pageTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: language?.localeIdentifier, key: "favorites.pageTitle")
    }
}

// MARK: - OpenTutorialBannerViewModelDelegate

extension FavoritesContentViewModel: OpenTutorialBannerViewModelDelegate {
    func closeBanner() {
        disableOptInOnboardingBannerUseCase.disableOptInOnboardingBanner()
    }
    
    func openTutorial() {
        flowDelegate?.navigate(step: .openTutorialTappedFromTools)
        
        closeBanner()
    }
}

// MARK: - FavoriteToolsViewModelDelegate

extension FavoritesContentViewModel: FavoriteToolsViewModelDelegate {
    
    func viewAllFavoriteToolsButtonTapped() {
        flowDelegate?.navigate(step: .viewAllFavoriteToolsTappedFromFavoritedTools)
    }
    
    func goToToolsButtonTapped() {
        delegate?.favoriteToolsViewGoToToolsTapped()
    }
    
    func toolCardTapped(_ tool: ToolDomainModel) {
        trackOpenFavoritedToolButtonAnalytics(for: tool.resource)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: tool.resource))
    }
    
    func toolFavoriteButtonTapped(_ tool: ToolDomainModel) {
        let removedHandler = CallbackHandler { [weak self] in
            self?.removeToolFromFavoritesUseCase.removeToolFromFavorites(resourceId: tool.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: tool.resource, removeHandler: removedHandler))
    }
    
    func toolDetailsButtonTapped(_ tool: ToolDomainModel) {
        trackFavoritedToolDetailsButtonAnalytics(for: tool.resource)
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: tool.resource))
    }
    
    func openToolButtonTapped(_ tool: ToolDomainModel) {
        trackOpenFavoritedToolButtonAnalytics(for: tool.resource)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: tool.resource))
    }
}

// MARK: - Analytics

extension FavoritesContentViewModel {
    var analyticsScreenName: String {
        return "Favorites"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
        
        analytics.firebaseAnalytics.trackAction(
            screenName: "",
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            actionName: AnalyticsConstants.ActionNames.viewedMyToolsAction,
            data: nil
        )
        
        flowDelegate?.navigate(step: .userViewedFavoritedToolsListFromTools)
    }
    
    private func trackFeaturedLessonTappedAnalytics(for lesson: LessonDomainModel) {
       
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.featured,
                AnalyticsConstants.Keys.tool: lesson.analyticsToolName
              ]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
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
}
