//
//  LessonsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class LessonsViewModel: ObservableObject {
        
    private let resourcesRepository: ResourcesRepository
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase
    private let viewLessonsUseCase: ViewLessonsUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let attachmentsRepository: AttachmentsRepository
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var lessonFilterLanguageSelection: LessonFilterLanguageDomainModel?
    
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    @Published var languageFilterTitle: String = ""
    @Published var languageFilterButtonTitle: String = ""
    @Published var lessons: [LessonListItemDomainModel] = []
    @Published var isLoadingLessons: Bool = true
        
    init(flowDelegate: FlowDelegate, resourcesRepository: ResourcesRepository, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase, viewLessonsUseCase: ViewLessonsUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.flowDelegate = flowDelegate
        self.resourcesRepository = resourcesRepository
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getUserLessonFiltersUseCase = getUserLessonFiltersUseCase
        self.viewLessonsUseCase = viewLessonsUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.attachmentsRepository = attachmentsRepository
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        Publishers.CombineLatest(
            $appLanguage,
            $lessonFilterLanguageSelection
        )
        .dropFirst()
        .map { (appLanguage, languageFilter) in
        
            viewLessonsUseCase
                .viewPublisher(appLanguage: appLanguage, filterLessonsByLanguage: languageFilter)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (domainModel: ViewLessonsDomainModel) in
                            
            self?.sectionTitle = domainModel.interfaceStrings.title
            self?.subtitle = domainModel.interfaceStrings.subtitle
            self?.languageFilterTitle = domainModel.interfaceStrings.languageFilterTitle
            
            self?.lessons = domainModel.lessons
            self?.isLoadingLessons = false
        }
        .store(in: &cancellables)
    
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
            
                getUserLessonFiltersUseCase.getUserToolFiltersPublisher(translatedInAppLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userFilters in
                
                self?.languageFilterButtonTitle = userFilters.languageFilter?.translatedName ?? ""
                self?.lessonFilterLanguageSelection = userFilters.languageFilter
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
            actionName: AnalyticsConstants.ActionNames.viewedLessonsAction,
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
    }
    
    private func trackLessonTappedAnalytics(lessonListItem: LessonListItemDomainModel) {
        
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
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.lessons,
                AnalyticsConstants.Keys.tool: lessonListItem.analyticsToolName
            ]
        )
    }
}

// MARK: - Inputs

extension LessonsViewModel {
    
    func getLessonViewModel(lessonListItem: LessonListItemDomainModel) -> LessonCardViewModel {
        
        return LessonCardViewModel(
            lessonListItem: lessonListItem,
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func refreshData() {
        
        resourcesRepository
            .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in

            }, receiveValue: { (result: RealmResourcesCacheSyncResult) in
                
            })
            .store(in: &cancellables)
    }
    
    func pageViewed() {
        
        trackPageViewed()
    }
    
    func lessonLanguageFilterTapped() {
        flowDelegate?.navigate(step: .lessonLanguageFilterTappedFromLessons)
    }
    
    func lessonCardTapped(lessonListItem: LessonListItemDomainModel) {
        
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(lessonListItem: lessonListItem, languageFilter: lessonFilterLanguageSelection))
        
        trackLessonTappedAnalytics(lessonListItem: lessonListItem)
    }
}
