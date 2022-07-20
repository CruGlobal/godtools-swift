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

class FavoritesContentViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
        
    private weak var flowDelegate: FlowDelegate?
    private let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let analytics: AnalyticsContainer
    private weak var delegate: FavoritesContentViewModelDelegate?
    
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private var disableOptInOnboardingBannerSubscription: AnyCancellable?
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
        
    private(set) lazy var featuredLessonCardsViewModel: FeaturedLessonCardsViewModel = {
        return FeaturedLessonCardsViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            delegate: self
        )
    }()
    private(set) lazy var favoriteToolsViewModel: FavoriteToolsViewModel = {
        return FavoriteToolsViewModel(
            dataDownloader: dataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            delegate: self
        )
    }()
    
    // MARK: - Published
    
    @Published var lessonsLoading: Bool = false
    @Published var toolsLoading: Bool = false
    @Published var pageTitle: String = ""
    @Published var hideTutorialBanner: Bool = true

    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, analytics: AnalyticsContainer, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase) {
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.analytics = analytics
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        
        super.init()
                
        disableOptInOnboardingBannerSubscription = getOptInOnboardingBannerEnabledUseCase.getBannerIsEnabled()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (isEnabled: Bool) in
                self?.hideTutorialBanner = !isEnabled
         })
                        
        setup()
    }
    
    deinit {
        languageSettingsService.primaryLanguage.removeObserver(self)
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
            analytics: analytics,
            delegate: self
        )
    }
}

// MARK: - Private

extension FavoritesContentViewModel {
    
    private func setup() {
        setupBinding()
        setupTitle()
    }
    
    private func setupBinding() {
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.setupTitle()
            }
        }
    }
    
    private func setupTitle() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        pageTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.pageTitle")
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

// MARK: - FeaturedLessonCardsViewModelDelegate

extension FavoritesContentViewModel: FeaturedLessonCardsViewModelDelegate {
    func lessonsAreLoading(_ isLoading: Bool) {
        lessonsLoading = isLoading
    }
    
    func lessonCardTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .lessonTappedFromFeaturedLessons(resource: resource))
        trackFeaturedLessonTappedAnalytics()
    }
}

// MARK: - FavoriteToolsViewModelDelegate

extension FavoritesContentViewModel: FavoriteToolsViewModelDelegate {
    func toolsAreLoading(_ isLoading: Bool) {
        toolsLoading = isLoading
    }
    
    func viewAllFavoriteToolsButtonTapped() {
        flowDelegate?.navigate(step: .viewAllFavoriteToolsTappedFromFavoritedTools)
    }
    
    func goToToolsButtonTapped() {
        delegate?.favoriteToolsViewGoToToolsTapped()
    }
    
    func toolCardTapped(resource: ResourceModel) {
        trackFavoritedToolTappedAnalytics()
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func toolFavoriteButtonTapped(resource: ResourceModel) {
        let removedHandler = CallbackHandler { [weak self] in
            self?.favoritedResourcesCache.removeFromFavorites(resourceId: resource.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: resource, removeHandler: removedHandler))
    }
    
    func toolDetailsButtonTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: resource))
    }
    
    func openToolButtonTapped(resource: ResourceModel) {
        trackOpenFavoritedToolButtonAnalytics()
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
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
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
        
        analytics.firebaseAnalytics.trackAction(screenName: "", siteSection: "", siteSubSection: "", actionName: AnalyticsConstants.ActionNames.viewedMyToolsAction, data: nil)
        
        flowDelegate?.navigate(step: .userViewedFavoritedToolsListFromTools)
    }
    
    func trackFeaturedLessonTappedAnalytics() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
            siteSection: AnalyticsConstants.SiteSections.featured,
            siteSubSection: "",
            url: nil,
            data: [AnalyticsConstants.Keys.lessonOpenTapped: 1]
        ))
    }
    
    func trackFavoritedToolTappedAnalytics() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpenTapped,
            siteSection: AnalyticsConstants.SiteSections.favorited,
            siteSubSection: "",
            url: nil,
            data: [AnalyticsConstants.Keys.toolOpenTapped: 1]
        ))
    }
    
    func trackOpenFavoritedToolButtonAnalytics() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: AnalyticsConstants.SiteSections.favorited,
            siteSubSection: "",
            url: nil,
            data: [AnalyticsConstants.Keys.toolOpened: 1]
        ))
    }
}
