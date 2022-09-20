//
//  LessonsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonsViewModel: LessonCardProvider {
    
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
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    
    @Published var isLoading: Bool = false
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    
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
        
        setupBinding()
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for lesson: LessonDomainModel) -> BaseLessonCardViewModel {
        return LessonCardViewModel(
            lesson: lesson,
            dataDownloader: dataDownloader,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            delegate: self
        )
    }
}

// MARK: - Public

extension LessonsViewModel {
    func refreshData() {
        dataDownloader.downloadInitialData()
    }
}

// MARK: - Private

extension LessonsViewModel {
    
    private func setupBinding() {
        
        getLessonsUseCase.getLessonsPublisher()
            .receiveOnMain()
            .sink { [weak self] lessons in
                
                self?.isLoading = lessons.isEmpty
                self?.lessons = lessons
            }
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receiveOnMain()
            .sink { [weak self] primaryLanguage in
                self?.setupTitle(with: primaryLanguage)
            }
            .store(in: &cancellables)
    }
    
    private func setupTitle(with language: LanguageDomainModel?) {
        guard let language = language,
              let languageBundle = localizationServices.bundleLoader.bundleForResource(resourceName: language.localeIdentifier)
        else { return }
        
        sectionTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "lessons.pageTitle")
        subtitle = localizationServices.stringForBundle(bundle: languageBundle, key: "lessons.pageSubtitle")
    }
}

// MARK: - LessonCardDelegate

extension LessonsViewModel: LessonCardDelegate {
    
    func lessonCardTapped(lesson: LessonDomainModel) {
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(lesson: lesson))
        trackLessonTappedAnalytics(for: lesson)
    }
}

// MARK: - Analytics

extension LessonsViewModel {
    
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
