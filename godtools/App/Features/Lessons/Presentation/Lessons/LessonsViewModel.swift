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

@MainActor class LessonsViewModel: ObservableObject {
        
    private let pullToRefreshLessonsUseCase: PullToRefreshLessonsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase
    private let getPersonalizedLessonsUseCase: GetPersonalizedLessonsUseCase
    private let getLessonsStringsUseCase: GetLessonsStringsUseCase
    private let getAllLessonsUseCase: GetAllLessonsUseCase
    private let getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var lessonFilterLanguageSelection: LessonFilterLanguageDomainModel?
    @Published private var localizationSettings: UserLocalizationSettingsDomainModel?
    
    @Published private(set) var toggleOptions: [PersonalizationToggleOption] = []
    @Published private(set) var strings: LessonsStringsDomainModel = .emptyValue
    @Published private(set) var languageFilterButtonTitle: String = ""
    @Published private(set) var lessons: [LessonListItemDomainModel] = []
    @Published private(set) var isLoadingLessons: Bool = true
    
    @Published var selectedToggle: PersonalizationToggleOptionValue = .personalized
        
    init(flowDelegate: FlowDelegate, pullToRefreshLessonsUseCase: PullToRefreshLessonsUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase, getPersonalizedLessonsUseCase: GetPersonalizedLessonsUseCase, getLessonsStringsUseCase: GetLessonsStringsUseCase, getAllLessonsUseCase: GetAllLessonsUseCase, getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, getToolBannerUseCase: GetToolBannerUseCase) {

        self.flowDelegate = flowDelegate
        self.pullToRefreshLessonsUseCase = pullToRefreshLessonsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLocalizationSettingsUseCase = getLocalizationSettingsUseCase
        self.getPersonalizedLessonsUseCase = getPersonalizedLessonsUseCase
        self.getLessonsStringsUseCase = getLessonsStringsUseCase
        self.getAllLessonsUseCase = getAllLessonsUseCase
        self.getUserLessonFiltersUseCase = getUserLessonFiltersUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)

        getLocalizationSettingsUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$localizationSettings)

        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getLessonsStringsUseCase
                    .execute(translateInLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: LessonsStringsDomainModel) in

                self?.strings = strings
                
                self?.toggleOptions = Self.getToggleOptions(strings: strings)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest4(
            $appLanguage,
            $lessonFilterLanguageSelection,
            $localizationSettings,
            $selectedToggle
        )
        .dropFirst()
        .map { (appLanguage, languageFilter, localizationSettings, toggle) -> AnyPublisher<[LessonListItemDomainModel], Error> in

            switch toggle {
            
            case .personalized:
                return getPersonalizedLessonsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        country: localizationSettings?.selectedCountry,
                        filterLessonsByLanguage: languageFilter
                    )
            
            case .all:
                return getAllLessonsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        filterLessonsByLanguage: languageFilter
                    )
            }
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in

        }, receiveValue: { [weak self] (lessons: [LessonListItemDomainModel]) in

            self?.lessons = lessons
            self?.isLoadingLessons = false
        })
        .store(in: &cancellables)
    
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
            
                getUserLessonFiltersUseCase.getUserToolFiltersPublisher(translatedInAppLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (userFilters: UserLessonFiltersDomainModel) in
                
                self?.languageFilterButtonTitle = userFilters.languageFilter?.languageNameTranslatedInAppLanguage ?? ""
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
    
    private static func getToggleOptions(strings: LessonsStringsDomainModel) -> [PersonalizationToggleOption] {
        
        return [
            PersonalizationToggleOption(title: strings.personalizedToolToggleTitle, selection: .personalized, buttonAccessibility: .personalizedLessons),
            PersonalizationToggleOption(title: strings.allLessonsToggleTitle, selection: .all, buttonAccessibility: .allLessons)
        ]
    }
}

// MARK: - Inputs

extension LessonsViewModel {
    
    func getLessonViewModel(lessonListItem: LessonListItemDomainModel) -> LessonCardViewModel {
        
        return LessonCardViewModel(
            lessonListItem: lessonListItem,
            getToolBannerUseCase: getToolBannerUseCase
        )
    }
    
    func pullToRefresh() {
        
        pullToRefreshLessonsUseCase
            .execute(
                appLanguage: appLanguage,
                country: localizationSettings?.selectedCountry,
                filterLessonsByLanguage: lessonFilterLanguageSelection
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in

            }, receiveValue: { _ in
                
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

    func localizationSettingsTapped() {

        flowDelegate?.navigate(step: .localizationSettingsTappedFromLessons)
    }
}
