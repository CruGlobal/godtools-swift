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

@MainActor
final class LessonsViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
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
    private let inMemoryDataCache: InMemoryDataCache
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var pullToRefreshLessonsTask: Task<Void, Error>?
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var lessonFilterLanguageSelection: LessonFilterLanguageDomainModel?
    @Published private var localizationSettings: UserLocalizationSettingsDomainModel?
    @Published private var allLessonsList: [LessonListItemDomainModel] = Array()
    
    @Published private(set) var toggleOptions: [PersonalizationToggleOption] = []
    @Published private(set) var strings: LessonsStringsDomainModel = .emptyValue
    @Published private(set) var languageFilterButtonTitle: String = ""
    @Published private(set) var personalizedLessons = PersonalizedLessonsDomainModel.emptyValue
    @Published private(set) var lessonsList: [LessonListItemDomainModel] = []

    @Published var selectedToggle: PersonalizationToggleOptionValue = .personalized

    init(
        stepEmitter: FlowStepEmitter,
        pullToRefreshLessonsUseCase: PullToRefreshLessonsUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase,
        getPersonalizedLessonsUseCase: GetPersonalizedLessonsUseCase,
        getLessonsStringsUseCase: GetLessonsStringsUseCase,
        getAllLessonsUseCase: GetAllLessonsUseCase,
        getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase,
        getToolBannerUseCase: GetToolBannerUseCase,
        inMemoryDataCache: InMemoryDataCache
    ) {

        self.stepEmitter = stepEmitter
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
        self.inMemoryDataCache = inMemoryDataCache
        
        if !GodToolsApp.showsPersonalization {
            selectedToggle = .all
        }
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)

        getLocalizationSettingsUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$localizationSettings)

        Publishers.CombineLatest3(
            $appLanguage.dropFirst(),
            $localizationSettings,
            $lessonFilterLanguageSelection
        )
        .map { (appLanguage: AppLanguageDomainModel, localizationSettings: UserLocalizationSettingsDomainModel?, languageFilter: LessonFilterLanguageDomainModel?) in
            
            getPersonalizedLessonsUseCase
                .execute(
                    appLanguage: appLanguage,
                    country: localizationSettings?.selectedCountry,
                    filterLessonsByLanguage: languageFilter
                )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        } receiveValue: { [weak self] (personalizedLessons: PersonalizedLessonsDomainModel) in
            
            self?.personalizedLessons = personalizedLessons
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            $lessonFilterLanguageSelection
        )
        .map { (appLanguage: AppLanguageDomainModel, languageFilter: LessonFilterLanguageDomainModel?) in
            
            getAllLessonsUseCase
                .execute(
                    appLanguage: appLanguage,
                    filterLessonsByLanguage: languageFilter
                )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        } receiveValue: { [weak self] (lessons: [LessonListItemDomainModel]) in
            
            self?.allLessonsList = lessons
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $personalizedLessons,
            $allLessonsList,
            $selectedToggle
        )
        .map { (personalizedLessons: PersonalizedLessonsDomainModel, allLessons: [LessonListItemDomainModel], toggle: PersonalizationToggleOptionValue) in
            
            let lessonsList: [LessonListItemDomainModel]
            
            switch toggle {
            case .personalized:
                lessonsList = personalizedLessons.lessons
            case .all:
                lessonsList = allLessons
            }
            
            return Just(lessonsList)
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (lessonsList: [LessonListItemDomainModel]) in
            
            self?.lessonsList = lessonsList
        }
        .store(in: &cancellables)
    
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
            
                getUserLessonFiltersUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                    
            }, receiveValue: { [weak self] (userFilters: UserLessonFiltersDomainModel) in
                
                self?.languageFilterButtonTitle = userFilters.languageFilter?.languageNameTranslatedInAppLanguage ?? ""
                self?.lessonFilterLanguageSelection = userFilters.languageFilter
            })
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        pullToRefreshLessonsTask?.cancel()
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        Task {

            let strings = await getLessonsStringsUseCase
                .execute(translateInLanguage: appLanguage)

            self.strings = strings

            toggleOptions = Self.getPersonalizedToggleOptions(strings: strings)
        }
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
            properties: AnalyticsProperties(
                screenName: analyticsScreenName,
                siteSection: analyticsSiteSection,
                siteSubSection: analyticsSiteSubSection,
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            )
        )
        
        trackActionAnalyticsUseCase.trackAction(
            properties: AnalyticsProperties(
                screenName: "",
                siteSection: "",
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            ),
            actionName: AnalyticsConstants.ActionNames.viewedLessonsAction,
            data: nil
        )
    }
    
    private func trackLessonTappedAnalytics(lessonListItem: LessonListItemDomainModel) {
        
        trackActionAnalyticsUseCase.trackAction(
            properties: AnalyticsProperties(
                screenName: analyticsScreenName,
                siteSection: "",
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            ),
            actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.lessons,
                AnalyticsConstants.Keys.tool: lessonListItem.analyticsToolName
            ]
        )
    }
    
    private static func getPersonalizedToggleOptions(strings: LessonsStringsDomainModel) -> [PersonalizationToggleOption] {
        
        if !GodToolsApp.showsPersonalization {
            return [PersonalizationToggleOption(title: strings.allLessonsToggleTitle, selection: .all, buttonAccessibility: .allLessons)]
        }
        
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
            getToolBannerUseCase: getToolBannerUseCase,
            inMemoryDataCache: inMemoryDataCache
        )
    }
    
    func pullToRefresh() {
        
        pullToRefreshLessonsTask = Task {
            
            try await pullToRefreshLessonsUseCase
                .execute(
                    appLanguage: appLanguage,
                    country: localizationSettings?.selectedCountry,
                    filterLessonsByLanguage: lessonFilterLanguageSelection
                )
        }
    }
    
    func pageViewed() {
        
        trackPageViewed()
    }
    
    func lessonLanguageFilterTapped() {
        stepEmitter.emit(step: AppFlowStep.lessonLanguageFilterTappedFromLessons)
    }
    
    func lessonCardTapped(lessonListItem: LessonListItemDomainModel) {

        stepEmitter.emit(step: AppFlowStep.lessonTappedFromLessonsList(lessonListItem: lessonListItem, languageFilter: lessonFilterLanguageSelection))

        trackLessonTappedAnalytics(lessonListItem: lessonListItem)
    }

    func changeLocalizationSettingsTapped() {

        stepEmitter.emit(step: AppFlowStep.changeLocalizationSettingsTappedFromLessons)
    }

    func goToAllLessonsTapped() {
        selectedToggle = .all
    }
}
