//
//  LessonsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonsViewModel: ObservableObject {
        
    private let dataDownloader: InitialDataDownloader
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getLessonsUseCase: GetLessonsUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let translationsRepository: TranslationsRepository
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    @Published var lessons: [LessonDomainModel] = []
        
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, analytics: AnalyticsContainer, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getLessonsUseCase: GetLessonsUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, translationsRepository: TranslationsRepository) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getLessonsUseCase = getLessonsUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.translationsRepository = translationsRepository
                
        getLessonsUseCase.getLessonsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lessons in
                
                self?.lessons = lessons
            }
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] primaryLanguage in
                self?.setupTitle(with: primaryLanguage)
            }
            .store(in: &cancellables)
    }
    
    private func setupTitle(with language: LanguageDomainModel?) {
        
        sectionTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: language?.localeIdentifier, key: "lessons.pageTitle")
        subtitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: language?.localeIdentifier, key: "lessons.pageSubtitle")
    }
    
    // MARK: - Analytics
    
    private var analyticsScreenName: String {
        return "Lessons"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func trackPageViewed() {
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
        
        analytics.appsFlyerAnalytics.trackAction(actionName: analyticsScreenName, data:  nil)
        
        analytics.firebaseAnalytics.trackAction(
            screenName: "",
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            actionName: AnalyticsConstants.ActionNames.viewedLessonsAction,
            data: nil
        )
    }
    
    private func trackLessonTappedAnalytics(for lesson: LessonDomainModel) {
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.lessons,
                AnalyticsConstants.Keys.tool: lesson.abbreviation
            ]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}

// MARK: - Inputs

extension LessonsViewModel {
    
    func cardViewModel(for lesson: LessonDomainModel) -> LessonCardViewModel {
        
        return LessonCardViewModel(
            lesson: lesson,
            dataDownloader: dataDownloader,
            translationsRepository: translationsRepository,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase
        )
    }
    
    func refreshData() {
        
        dataDownloader.downloadInitialData()
    }
    
    func pageViewed() {
        
        trackPageViewed()
    }
    
    func lessonCardTapped(lesson: LessonDomainModel) {
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(lesson: lesson))
        trackLessonTappedAnalytics(for: lesson)
    }
}
