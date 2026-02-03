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
        
    private let resourcesRepository: ResourcesRepository
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase
    private let getPersonalizedLessonsUseCase: GetPersonalizedLessonsUseCase
    private let getLessonsInterfaceStringsUseCase: GetLessonsInterfaceStringsUseCase
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
    @Published private(set) var strings: LessonsInterfaceStringsDomainModel = .emptyValue
    
    @Published var selectedToggle: PersonalizationToggleOptionValue = .personalized
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    @Published var languageFilterTitle: String = ""
    @Published var languageFilterButtonTitle: String = ""
    @Published var lessons: [LessonListItemDomainModel] = []
    @Published var isLoadingLessons: Bool = true
        
    init(flowDelegate: FlowDelegate, resourcesRepository: ResourcesRepository, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLocalizationSettingsUseCase: GetLocalizationSettingsUseCase, getPersonalizedLessonsUseCase: GetPersonalizedLessonsUseCase, getLessonsInterfaceStringsUseCase: GetLessonsInterfaceStringsUseCase, getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, getToolBannerUseCase: GetToolBannerUseCase) {

        self.flowDelegate = flowDelegate
        self.resourcesRepository = resourcesRepository
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLocalizationSettingsUseCase = getLocalizationSettingsUseCase
        self.getPersonalizedLessonsUseCase = getPersonalizedLessonsUseCase
        self.getLessonsInterfaceStringsUseCase = getLessonsInterfaceStringsUseCase
        self.getUserLessonFiltersUseCase = getUserLessonFiltersUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.getToolBannerUseCase = getToolBannerUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)

        getLocalizationSettingsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$localizationSettings)

        Publishers.CombineLatest4(
            $appLanguage,
            $lessonFilterLanguageSelection,
            $localizationSettings,
            $selectedToggle
        )
        .dropFirst()
        .flatMap { (appLanguage, languageFilter, localizationSettings, toggle) -> AnyPublisher<ViewLessonsDomainModel, Error> in

            let country = toggle == .personalized ? localizationSettings?.selectedCountryIsoRegionCode : nil

            return Publishers.CombineLatest(
                getLessonsInterfaceStringsUseCase
                    .getStringsPublisher(appLanguage: appLanguage)
                    .setFailureType(to: Error.self),
                getPersonalizedLessonsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        country: country,
                        filterLessonsByLanguage: languageFilter
                    )
            )
            .map { (interfaceStrings, lessons) in
                return ViewLessonsDomainModel(
                    interfaceStrings: interfaceStrings,
                    lessons: lessons
                )
            }
            .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak self] (domainModel: ViewLessonsDomainModel) in
            
            let interfaceStrings = domainModel.interfaceStrings

            self?.strings = interfaceStrings
            self?.sectionTitle = interfaceStrings.title
            self?.subtitle = interfaceStrings.subtitle
            self?.languageFilterTitle = interfaceStrings.languageFilterTitle
            self?.toggleOptions = [
                PersonalizationToggleOption(title: interfaceStrings.personalizedToolToggleTitle, selection: .personalized),
                PersonalizationToggleOption(title: interfaceStrings.allLessonsToggleTitle, selection: .all)
            ]

            self?.lessons = domainModel.lessons
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
        
        resourcesRepository
            .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(requestPriority: .high, forceFetchFromRemote: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in

            }, receiveValue: { (result: ResourcesCacheSyncResult) in
                
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
