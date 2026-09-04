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
import Flow

@MainActor
final class LessonsViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let pullToRefreshLessonsUseCase: PullToRefreshLessonsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase
    private let getPersonalizedLessonsUseCase: GetPersonalizedLessonsUseCase
    private let getLessonsStringsUseCase: GetLessonsStringsUseCase
    private let getAllLessonsUseCase: GetAllLessonsUseCase
    private let getUserLessonFilterLanguageUseCase: GetUserLessonFilterLanguageUseCase
    private let getUserPersonalizedLessonFilterLanguageUseCase: GetUserPersonalizedLessonFilterLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let getToolBannerUseCase: GetToolBannerUseCase
    private let imageCache: ImageCacheInterface
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var pullToRefreshLessonsTask: Task<Void, Error>?
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var localizationSettings: UserLocalizationSettingsDomainModel?
    @Published private var allLessonsList: [LessonListItemDomainModel] = Array()
    @Published private var selectedAllLessonsFilterLanguage: LessonFilterLanguageDomainModel?
    @Published private var selectedPersonalizedLessonsFilterLanguage: PersonalizedLessonFilterLanguageDomainModel?
    
    @Published private(set) var toggleOptions: [PersonalizationToggleOption] = []
    @Published private(set) var strings: LessonsStringsDomainModel = .emptyValue
    @Published private(set) var languageFilterActionTitle: String = ""
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
        getUserLessonFilterLanguageUseCase: GetUserLessonFilterLanguageUseCase,
        getUserPersonalizedLessonFilterLanguageUseCase: GetUserPersonalizedLessonFilterLanguageUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase,
        getToolBannerUseCase: GetToolBannerUseCase,
        imageCache: ImageCacheInterface
    ) {

        self.stepEmitter = stepEmitter
        self.pullToRefreshLessonsUseCase = pullToRefreshLessonsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLocalizationSettingsUseCase = getLocalizationSettingsUseCase
        self.getPersonalizedLessonsUseCase = getPersonalizedLessonsUseCase
        self.getLessonsStringsUseCase = getLessonsStringsUseCase
        self.getAllLessonsUseCase = getAllLessonsUseCase
        self.getUserLessonFilterLanguageUseCase = getUserLessonFilterLanguageUseCase
        self.getUserPersonalizedLessonFilterLanguageUseCase = getUserPersonalizedLessonFilterLanguageUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        self.imageCache = imageCache
        
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
            $selectedPersonalizedLessonsFilterLanguage
        )
        .map { (appLanguage: AppLanguageDomainModel, localizationSettings: UserLocalizationSettingsDomainModel?, languageFilter: PersonalizedLessonFilterLanguageDomainModel?) in
            
            getPersonalizedLessonsUseCase
                .execute(
                    appLanguage: appLanguage,
                    country: localizationSettings?.selectedCountry,
                    filterLessonsByLanguageId: languageFilter?.languageId
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
            $selectedAllLessonsFilterLanguage
        )
        .map { (appLanguage: AppLanguageDomainModel, languageFilter: LessonFilterLanguageDomainModel?) in
            
            getAllLessonsUseCase
                .execute(
                    appLanguage: appLanguage,
                    filterLessonsByLanguageId: languageFilter?.languageId
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
            
            return lessonsList
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (lessonsList: [LessonListItemDomainModel]) in
            
            self?.lessonsList = lessonsList
        }
        .store(in: &cancellables)
    
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
            
                getUserLessonFilterLanguageUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                    
            }, receiveValue: { [weak self] (languageFilter: LessonFilterLanguageDomainModel?) in
                
                self?.selectedAllLessonsFilterLanguage = languageFilter
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
            
                getUserPersonalizedLessonFilterLanguageUseCase
                    .execute(
                        appLanguage: appLanguage
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                    
            }, receiveValue: { [weak self] (languageFilter: PersonalizedLessonFilterLanguageDomainModel?) in
                
                self?.selectedPersonalizedLessonsFilterLanguage = languageFilter
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $selectedAllLessonsFilterLanguage,
            $selectedPersonalizedLessonsFilterLanguage,
            $selectedToggle
        )
        .map { (
            lessonsLanguageFilter: LessonFilterLanguageDomainModel?,
            personalizedLessonsLanguageFilter: PersonalizedLessonFilterLanguageDomainModel?,
            selectedToggle: PersonalizationToggleOptionValue
        ) in
            
            let languageNamePair: TranslatedLanguageNamePairDomainModel?
            
            switch selectedToggle {
                
            case .personalized:
                languageNamePair = personalizedLessonsLanguageFilter?.languageNamePair
            case .all:
                languageNamePair = lessonsLanguageFilter?.languageNamePair
            }
                        
            return languageNamePair?.nameInAppLanguage ?? ""
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (title: String) in
            
            self?.languageFilterActionTitle = title
        }
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        pullToRefreshLessonsTask?.cancel()
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        let strings = getLessonsStringsUseCase
            .execute(translateInLanguage: appLanguage)

        self.strings = strings

        toggleOptions = Self.getPersonalizedToggleOptions(strings: strings)
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
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
    
        let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase = self.trackScreenViewAnalyticsUseCase
        
        Task.detached {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: analyticsProperties
            )
        }
    }
    
    private func trackViewedLessons() {
        
        let analyticsProperties = AnalyticsProperties(
            screenName: "",
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackActionAnalyticsUseCase.execute(
                properties: analyticsProperties,
                actionName: AnalyticsConstants.ActionNames.viewedLessonsAction,
                data: nil
            )
        }
    }
    
    private func trackLessonTappedAnalytics(lessonListItem: LessonListItemDomainModel) {
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: "",
            siteSubSection: "",
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let analyticsToolName: String = lessonListItem.analyticsToolName
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackActionAnalyticsUseCase.execute(
                properties: analyticsProperties,
                actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
                data: [
                    AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.lessons,
                    AnalyticsConstants.Keys.tool: analyticsToolName
                ]
            )
        }
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
    
    private func pullToRefreshLessons() {
        
        pullToRefreshLessonsTask?.cancel()
        
        pullToRefreshLessonsTask = Task { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            try await weakSelf.pullToRefreshLessonsUseCase
                .execute(
                    appLanguage: weakSelf.appLanguage,
                    country: weakSelf.localizationSettings?.selectedCountry,
                    languageFilterLanguageId: weakSelf.selectedAllLessonsFilterLanguage?.languageId
                )
        }
    }
}

// MARK: - Inputs

extension LessonsViewModel {
    
    func getLessonViewModel(lessonListItem: LessonListItemDomainModel) -> LessonCardViewModel {
        
        return LessonCardViewModel(
            lessonListItem: lessonListItem,
            getToolBannerUseCase: getToolBannerUseCase,
            imageCache: imageCache
        )
    }
    
    func pullToRefresh() {
        pullToRefreshLessons()
    }
    
    func pageViewed() {
        
        trackPageViewed()
        
        trackViewedLessons()
    }
    
    func lessonLanguageFilterTapped() {
        stepEmitter.emit(step: AppFlowStep.lessonLanguageFilterTappedFromLessons)
    }
    
    func personalizedLessonLanguageFilterTapped() {
        stepEmitter.emit(step: AppFlowStep.personalizedLessonLanguageFilterTappedFromLessons)
    }
    
    func lessonCardTapped(lessonListItem: LessonListItemDomainModel) {

        stepEmitter.emit(
            step: AppFlowStep.lessonTappedFromLessonsList(
                lessonListItem: lessonListItem,
                languageFilterLanguageId: selectedAllLessonsFilterLanguage?.languageId
            )
        )

        trackLessonTappedAnalytics(lessonListItem: lessonListItem)
    }

    func changeLocalizationSettingsTapped() {

        stepEmitter.emit(step: AppFlowStep.changeLocalizationSettingsTappedFromLessons)
    }

    func goToAllLessonsTapped() {
        selectedToggle = .all
    }
}
