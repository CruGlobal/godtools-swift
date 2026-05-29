//
//  SetAppLanguageUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
import Foundation
@testable import godtools
import Combine
import RepositorySync

struct SetAppLanguageUseCaseTests {
    
    private let testsDiContainer: TestsDiContainer
    private let languageCodes: [LanguageCodeDomainModel] = [.afrikaans, .arabic, .chinese, .czech, .english, .french, .hebrew, .latvian, .portuguese, .russian, .spanish, .vietnamese]
    private let allLanguages: [LanguageCodable]
    
    init() async throws {
        
        testsDiContainer = try TestsDiContainer()
        
        allLanguages = languageCodes.map {
            LanguageCodable(code: $0.rawValue, id: UUID().uuidString)
        }
        
        try await testsDiContainer.core.dataLayer.getLanguagesPersistence().writeObjects(externalObjects: allLanguages)
    }
        
    @Test(
        """
        Given: User is viewing the language settings
        When: The app language is switched from English to Spanish
        Then: The user's lesson language filter should update to Spanish.
        """
    )
    @MainActor func setUserPreferredAppLanguageRepositoryTest() async throws {
        
        let setAppLanguageUseCase = SetAppLanguageUseCase(
            userAppLanguageRepository: testsDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository(),
            userLessonFiltersRepository: testsDiContainer.core.dataLayer.getUserLessonFiltersRepository(),
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository()
        )
        
        let getUserLessonFiltersRepository = GetUserLessonFiltersUseCase(
            userLessonFiltersRepository: testsDiContainer.core.dataLayer.getUserLessonFiltersRepository(),
            getLessonFilterLanguage: testsDiContainer.feature.lessonFilter.domainLayer.getLessonFilterLangauge()
        )
        
        let appLanguageSpanish = LanguageCodeDomainModel.spanish.rawValue
        let spanishLanguage = allLanguages.first(where: { $0.code == appLanguageSpanish.languageCode })
                
        var lessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getUserLessonFiltersRepository
                .execute(
                    appLanguage: appLanguageSpanish
                )
                .sink { (userLessonFilters: UserLessonFiltersDomainModel) in
                    
                    triggerCount += 1
                                    
                    if triggerCount == 2 {
                        
                        lessonLanguageFilterRef = userLessonFilters.languageFilter
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
            
            Task {
                try await setAppLanguageUseCase
                    .execute(appLanguage: LanguageCodeDomainModel.spanish.rawValue)
            }
        }
        
        #expect(spanishLanguage != nil)
        #expect(lessonLanguageFilterRef?.languageId == spanishLanguage?.id)
    }
}
