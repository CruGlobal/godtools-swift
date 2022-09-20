//
//  LessonsContentViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LessonsContentViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private weak var flowDelegate: FlowDelegate?
    private let dataDownloader: InitialDataDownloader
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getLessonsUseCase: GetLessonsUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    
    private(set) lazy var lessonsListViewModel: LessonsListViewModel = {
        return LessonsListViewModel(
            dataDownloader: dataDownloader,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getLessonsUseCase: getLessonsUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            delegate: self
        )
    }()
    
    // MARK: - Published
    
    @Published var isLoading: Bool = false
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, analytics: AnalyticsContainer, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getLessonsUseCase: GetLessonsUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getLessonsUseCase = getLessonsUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        
        super.init()
    }
}

// MARK: - Public

extension LessonsContentViewModel {
    func refreshData() {
        dataDownloader.downloadInitialData()
    }
}

// MARK: - LessonsListViewModelDelegate

extension LessonsContentViewModel: LessonsListViewModelDelegate {
    func lessonsAreLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func lessonCardTapped(lesson: LessonDomainModel) {
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(lesson: lesson))
        trackLessonTappedAnalytics(for: lesson)
    }
}

// MARK: - Analytics

extension LessonsContentViewModel {
    
    var analyticsScreenName: String {
        return "Lessons"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
        analytics.appsFlyerAnalytics.trackAction(actionName: analyticsScreenName, data:  nil)
        analytics.firebaseAnalytics.trackAction(screenName: "", siteSection: "", siteSubSection: "", actionName: AnalyticsConstants.ActionNames.viewedLessonsAction, data: nil)
    }
    
    private func trackLessonTappedAnalytics(for lesson: LessonDomainModel) {
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.lessons,
                AnalyticsConstants.Keys.tool: lesson.abbreviation
            ]
        ))
    }
}
