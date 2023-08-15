//
//  FavoritesViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Combine

protocol FavoritesViewModelDelegate: AnyObject {
    func favoriteToolsViewGoToToolsTapped()
}

class FavoritesViewModel: ObservableObject {
            
    private let dataDownloader: InitialDataDownloader
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let attachmentsRepository: AttachmentsRepository
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
    private weak var delegate: FavoritesViewModelDelegate?
        
    private(set) lazy var featuredLessonViewModel: FeaturedLessonViewModel = {
        
        return FeaturedLessonViewModel(
            localizationServices: localizationServices,
            getFeaturedLessonsUseCase: getFeaturedLessonsUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            attachmentsRepository: attachmentsRepository
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
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, analytics: AnalyticsContainer, attachmentsRepository: AttachmentsRepository, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.attachmentsRepository = attachmentsRepository
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

extension FavoritesViewModel {
    
    func lessonTapped(lesson: LessonDomainModel) {
        
        flowDelegate?.navigate(step: .lessonTappedFromFeaturedLessons(lesson: lesson))
        trackFeaturedLessonTappedAnalytics(for: lesson)
    }
}

// MARK: - Public

extension FavoritesViewModel {
    
    func setDelegate(delegate: FavoritesViewModelDelegate) {
        self.delegate = delegate
    }
    
    func refreshData() {
        dataDownloader.downloadInitialData()
    }
    
    func getTutorialBannerViewModel() -> OpenTutorialBannerViewModel {
        
        return OpenTutorialBannerViewModel(
            localizationServices: localizationServices,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            analytics: analytics,
            delegate: self
        )
    }
}

// MARK: - Private

extension FavoritesViewModel {
    
    private func setupTitle(with language: LanguageDomainModel?) {

        pageTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: language?.localeIdentifier, key: "favorites.pageTitle")
    }
}

// MARK: - OpenTutorialBannerViewModelDelegate

extension FavoritesViewModel: OpenTutorialBannerViewModelDelegate {
    func closeBanner() {
        disableOptInOnboardingBannerUseCase.disableOptInOnboardingBanner()
    }
    
    func openTutorial() {
        flowDelegate?.navigate(step: .openTutorialTappedFromTools)
        
        closeBanner()
    }
}

// MARK: - FavoriteToolsViewModelDelegate

extension FavoritesViewModel: FavoriteToolsViewModelDelegate {
    
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

extension FavoritesViewModel {
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
