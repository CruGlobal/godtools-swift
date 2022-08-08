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
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    
    private(set) lazy var lessonsListViewModel: LessonsListViewModel = {
        return LessonsListViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices, getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            delegate: self
        )
    }()
    
    // MARK: - Published
    
    @Published var isLoading: Bool = false
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, analytics: AnalyticsContainer, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase) {
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        
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
    
    func lessonCardTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(resource: resource))
        trackLessonTappedAnalytics(for: resource)
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
    
    private func trackLessonTappedAnalytics(for lesson: ResourceModel) {
        
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
