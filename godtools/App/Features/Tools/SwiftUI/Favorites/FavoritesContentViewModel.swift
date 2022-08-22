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
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private weak var delegate: FavoritesContentViewModelDelegate?
    
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    
    private var cancellables = Set<AnyCancellable>()
        
    private(set) lazy var featuredLessonCardsViewModel: FeaturedLessonCardsViewModel = {
        return FeaturedLessonCardsViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            delegate: self
        )
    }()
    private(set) lazy var favoriteToolsViewModel: FavoriteToolsViewModel = {
        return FavoriteToolsViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: self
        )
    }()
    
    // MARK: - Published
    
    @Published var lessonsLoading: Bool = false
    @Published var toolsLoading: Bool = false
    @Published var pageTitle: String = ""
    @Published var hideTutorialBanner: Bool = true

    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, analytics: AnalyticsContainer, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase) {
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        
        super.init()
                        
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
        
        getOptInOnboardingBannerEnabledUseCase.getBannerIsEnabled()
            .receiveOnMain()
            .sink { [weak self] isEnabled in
                
                self?.hideTutorialBanner = !isEnabled
            }
            .store(in: &cancellables)
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
        trackFeaturedLessonTappedAnalytics(for: resource)
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
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
        
        analytics.firebaseAnalytics.trackAction(screenName: "", siteSection: "", siteSubSection: "", actionName: AnalyticsConstants.ActionNames.viewedMyToolsAction, data: nil)
        
        flowDelegate?.navigate(step: .userViewedFavoritedToolsListFromTools)
    }
    
    private func trackFeaturedLessonTappedAnalytics(for lesson: ResourceModel) {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [
                    AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.featured,
                    AnalyticsConstants.Keys.tool: lesson.abbreviation
                  ]
        ))
    }
    
    private func trackOpenFavoritedToolButtonAnalytics(for tool: ResourceModel) {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        ))
    }
    
    private func trackFavoritedToolDetailsButtonAnalytics(for tool: ResourceModel) {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        ))
    }
}
