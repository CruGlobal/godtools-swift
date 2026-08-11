//
//  GetFeaturedLessonsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine
import SwiftData
import RepositorySync

private enum TestLessonId {
    static let featuredFirst: String = "featured-lesson-first"
    static let featuredSecond: String = "featured-lesson-second"
    static let featuredThird: String = "featured-lesson-third"
    static let featuredUntranslated: String = "featured-lesson-untranslated"
    static let notSpotlighted: String = "lesson-not-spotlighted"
    static let hiddenSpotlighted: String = "lesson-hidden-spotlighted"
    static let spotlightedTract: String = "tract-spotlighted"
}

struct GetFeaturedLessonsUseCaseTests {

    struct LessonFixture {
        let id: String
        let abbreviation: String
        let bannerImageId: String
        let defaultOrder: Int
        let defaultLocale: LanguageCodeDomainModel
        let name: String
        let isSpotlight: Bool
        let isHidden: Bool
        let resourceType: ResourceType
        let languageCodes: [LanguageCodeDomainModel]
        let translatedNamesByLanguageCode: [LanguageCodeDomainModel: String]
    }

    struct LessonProgress {
        let lessonId: String
        let progress: Double
    }

    struct AppLanguageArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedNames: [String]
    }

    struct AvailabilityArgument {
        let appLanguage: AppLanguageDomainModel
        let lessonId: String
        let expectedAvailabilityString: String
        let expectedIsAvailable: Bool
    }

    struct LanguageDirectionArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedLanguageDirection: LanguageDirectionDomainModel
    }

    private let englishLessonCompleted: String = "Completed"
    private let englishCompletionProgress: String = "%@ complete"
    private let englishLanguageNotAvailable: String = "%@ not available"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: Lessons exist that are not spotlighted, are hidden, or are not lessons.
        Then: I expect to see only the spotlighted, visible lessons.
        """
    )
    @MainActor func onlySpotlightedVisibleLessonsAreFeatured() async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: LanguageCodeDomainModel.english.value
        )

        let lessonIds: [String] = featuredLessons.map({ $0.dataModelId })

        #expect(lessonIds.contains(TestLessonId.notSpotlighted) == false)
        #expect(lessonIds.contains(TestLessonId.hiddenSpotlighted) == false)
        #expect(lessonIds.contains(TestLessonId.spotlightedTract) == false)
        #expect(lessonIds.count == 4)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: The featured lessons are requested.
        Then: I expect to see them sorted by their default order.
        """
    )
    @MainActor func featuredLessonsAreSortedByTheirDefaultOrder() async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: LanguageCodeDomainModel.english.value
        )

        #expect(featuredLessons.map({ $0.dataModelId }) == [
            TestLessonId.featuredFirst,
            TestLessonId.featuredSecond,
            TestLessonId.featuredThird,
            TestLessonId.featuredUntranslated
        ])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: My app language is set.
        Then: I expect the lesson names to be translated in my app language.
        """,
        arguments: [
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedNames: ["Lesson First", "Lesson Second", "Lesson Third", "Lesson Untranslated Resource Name"]
            ),
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedNames: ["Lección primera", "Lesson Second", "Lección tercera", "Lesson Untranslated Resource Name"]
            )
        ]
    )
    @MainActor func lessonNamesAreTranslatedInMyAppLanguage(argument: AppLanguageArgument) async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: argument.appLanguage
        )

        #expect(featuredLessons.map({ $0.name }) == argument.expectedNames)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: A lesson is not translated in my app language.
        Then: I expect its name to fall back to the lesson's default locale translation, then to the lesson's name.
        """
    )
    @MainActor func lessonNamesFallBackToTheDefaultLocaleTranslationThenTheLessonName() async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: LanguageCodeDomainModel.spanish.value
        )

        let translatedInDefaultLocale: FeaturedLessonDomainModel = try #require(featuredLessons.first(where: { $0.dataModelId == TestLessonId.featuredSecond }))
        let notTranslatedAtAll: FeaturedLessonDomainModel = try #require(featuredLessons.first(where: { $0.dataModelId == TestLessonId.featuredUntranslated }))

        #expect(translatedInDefaultLocale.name == "Lesson Second")
        #expect(notTranslatedAtAll.name == "Lesson Untranslated Resource Name")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: A lesson is or is not translated in my app language.
        Then: I expect its availability in my app language to say so.
        """,
        arguments: [
            AvailabilityArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                lessonId: TestLessonId.featuredFirst,
                expectedAvailabilityString: "English ✓",
                expectedIsAvailable: true
            ),
            AvailabilityArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                lessonId: TestLessonId.featuredFirst,
                expectedAvailabilityString: "Español ✓",
                expectedIsAvailable: true
            ),
            AvailabilityArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                lessonId: TestLessonId.featuredSecond,
                expectedAvailabilityString: "Español not available",
                expectedIsAvailable: false
            )
        ]
    )
    @MainActor func availabilityInAppLanguageReflectsWhetherTheLessonSupportsMyAppLanguage(argument: AvailabilityArgument) async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: argument.appLanguage
        )

        let lesson: FeaturedLessonDomainModel = try #require(featuredLessons.first(where: { $0.dataModelId == argument.lessonId }))

        #expect(lesson.availabilityInAppLanguage.availabilityString == argument.expectedAvailabilityString)
        #expect(lesson.availabilityInAppLanguage.isAvailable == argument.expectedIsAvailable)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: My app language reads left to right or right to left.
        Then: I expect the lesson name language direction to match.
        """,
        arguments: [
            LanguageDirectionArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedLanguageDirection: .leftToRight
            ),
            LanguageDirectionArgument(
                appLanguage: LanguageCodeDomainModel.arabic.value,
                expectedLanguageDirection: .rightToLeft
            )
        ]
    )
    @MainActor func lessonNameLanguageDirectionMatchesMyAppLanguage(argument: LanguageDirectionArgument) async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: argument.appLanguage
        )

        #expect(featuredLessons.isEmpty == false)

        for featuredLesson in featuredLessons {
            #expect(featuredLesson.nameLanguageDirection == argument.expectedLanguageDirection)
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: My app language has not been downloaded.
        Then: I expect no availability to be shown and the name to read left to right.
        """
    )
    @MainActor func noAvailabilityIsShownWhenMyAppLanguageHasNotBeenDownloaded() async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: LanguageCodeDomainModel.vietnamese.value
        )

        #expect(featuredLessons.isEmpty == false)

        for featuredLesson in featuredLessons {

            #expect(featuredLesson.availabilityInAppLanguage.availabilityString == "")
            #expect(featuredLesson.availabilityInAppLanguage.isAvailable == false)
            #expect(featuredLesson.nameLanguageDirection == .leftToRight)
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: A lesson has not been started.
        Then: I expect its progress to be hidden.
        """
    )
    @MainActor func lessonProgressIsHiddenWhenTheLessonHasNotBeenStarted() async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: LanguageCodeDomainModel.english.value
        )

        let lesson: FeaturedLessonDomainModel = try #require(featuredLessons.first(where: { $0.dataModelId == TestLessonId.featuredFirst }))

        guard case .hidden = lesson.lessonProgress else {
            Issue.record("Expected lesson progress to be hidden, but was \(lesson.lessonProgress).")
            return
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: A lesson has been partially completed.
        Then: I expect its progress to be shown as a percentage in my app language.
        """
    )
    @MainActor func lessonProgressIsShownAsAPercentageWhenTheLessonIsPartiallyCompleted() async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: LanguageCodeDomainModel.english.value,
            lessonProgress: [LessonProgress(lessonId: TestLessonId.featuredSecond, progress: 0.25)]
        )

        let lesson: FeaturedLessonDomainModel = try #require(featuredLessons.first(where: { $0.dataModelId == TestLessonId.featuredSecond }))

        guard case .inProgress(let progress, let progressString) = lesson.lessonProgress else {
            Issue.record("Expected lesson progress to be in progress, but was \(lesson.lessonProgress).")
            return
        }

        #expect(progress == 0.25)
        #expect(progressString == "25% complete")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: A lesson has been fully completed.
        Then: I expect its progress to be shown as completed.
        """
    )
    @MainActor func lessonProgressIsShownAsCompletedWhenTheLessonIsFullyCompleted() async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: LanguageCodeDomainModel.english.value,
            lessonProgress: [LessonProgress(lessonId: TestLessonId.featuredThird, progress: 1)]
        )

        let lesson: FeaturedLessonDomainModel = try #require(featuredLessons.first(where: { $0.dataModelId == TestLessonId.featuredThird }))

        guard case .complete(let completeString) = lesson.lessonProgress else {
            Issue.record("Expected lesson progress to be complete, but was \(lesson.lessonProgress).")
            return
        }

        #expect(completeString == englishLessonCompleted)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing featured lessons.
        When: The featured lessons are requested.
        Then: I expect each to carry the banner image and analytics name from the lesson.
        """
    )
    @MainActor func featuredLessonsCarryTheBannerImageAndAnalyticsNameFromTheLesson() async throws {

        let featuredLessons: [FeaturedLessonDomainModel] = try await getFeaturedLessons(
            appLanguage: LanguageCodeDomainModel.english.value
        )

        let lesson: FeaturedLessonDomainModel = try #require(featuredLessons.first(where: { $0.dataModelId == TestLessonId.featuredFirst }))

        #expect(lesson.bannerImageId == "banner-first")
        #expect(lesson.analyticsToolName == "lessonfirst")
    }
}

// MARK: - Test Helpers

extension GetFeaturedLessonsUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getFeaturedLessons(appLanguage: AppLanguageDomainModel, lessonProgress: [LessonProgress] = []) async throws -> [FeaturedLessonDomainModel] {

        let useCase: GetFeaturedLessonsUseCase = try await getUseCase(lessonProgress: lessonProgress)

        var cancellables: Set<AnyCancellable> = Set()

        var featuredLessonsRef: [FeaturedLessonDomainModel]?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(appLanguage: appLanguage)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (featuredLessons: [FeaturedLessonDomainModel]) in

                    guard featuredLessonsRef == nil else {
                        return
                    }

                    featuredLessonsRef = featuredLessons

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return try #require(featuredLessonsRef)
    }

    @available(iOS 17.4, *)
    private func getUseCase(lessonProgress: [LessonProgress]) async throws -> GetFeaturedLessonsUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        let lessonProgressRepository: UserLessonProgressRepository = testsDiContainer.core.dataLayer.getUserLessonProgressRepository()

        for storeProgress in lessonProgress {

            _ = try await lessonProgressRepository.storeLessonProgress(
                lessonId: storeProgress.lessonId,
                lastViewedPageId: "page-id",
                progress: storeProgress.progress
            )
        }

        let resourcesRepository: ResourcesRepository = testsDiContainer.core.dataLayer.getResourcesRepository()
        let languagesRepository: LanguagesRepository = testsDiContainer.core.dataLayer.getLanguagesRepository()

        return GetFeaturedLessonsUseCase(
            resourcesRepository: resourcesRepository,
            languagesRepository: languagesRepository,
            getTranslatedToolName: GetTranslatedToolName(
                resourcesRepository: resourcesRepository,
                translationsRepository: testsDiContainer.core.dataLayer.getTranslationsRepository()
            ),
            getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability(
                localizationServices: getLocalizationServices(),
                resourcesRepository: resourcesRepository,
                languagesRepository: languagesRepository,
                getTranslatedLanguageName: getTranslatedLanguageName()
            ),
            lessonProgressRepository: lessonProgressRepository,
            getLessonListItemProgress: GetLessonListItemProgress(
                lessonProgressRepository: lessonProgressRepository,
                userCountersRepository: testsDiContainer.core.dataLayer.getUserCountersRepository(),
                localizationServices: getLocalizationServices(),
                getTranslatedPercentage: GetTranslatedPercentage()
            )
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: englishLanguageNotAvailable,
                LocalizableStringKeys.lessonsLessonCompleted.key: englishLessonCompleted,
                LocalizableStringKeys.lessonsCompletionProgress.key: englishCompletionProgress
            ],
            LanguageCodeDomainModel.spanish.value: [
                GetTranslatedToolLanguageAvailability.localizedKeyLanguageNotAvailable: englishLanguageNotAvailable,
                LocalizableStringKeys.lessonsLessonCompleted.key: englishLessonCompleted,
                LocalizableStringKeys.lessonsCompletionProgress.key: englishCompletionProgress
            ]
        ]

        return FakeLocalizationServices.createLanguageNamesLocalizationServices(
            addAdditionalLocalizableStrings: localizableStrings
        )
    }

    private func getTranslatedLanguageName() -> GetTranslatedLanguageName {

        return GetTranslatedLanguageName(
            localizationLanguageName: FakeLocalizationLanguageNameRepository(localizationServices: getLocalizationServices()),
            localeLanguageName: FakeLocaleLanguageName.getDefault(),
            localeRegionName: FakeLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languagesByCode: [LanguageCodeDomainModel: SwiftLanguage] = [
            .arabic: Self.createLanguage(code: .arabic, directionString: "rtl"),
            .english: Self.createLanguage(code: .english, directionString: "ltr"),
            .spanish: Self.createLanguage(code: .spanish, directionString: "ltr")
        ]

        var translations: [SwiftTranslation] = Array()

        let lessons: [SwiftResource] = allLessons.map { (fixture: LessonFixture) in

            let lesson = SwiftResource()
            lesson.id = fixture.id
            lesson.abbreviation = fixture.abbreviation
            lesson.attrBanner = fixture.bannerImageId
            lesson.attrDefaultOrder = fixture.defaultOrder
            lesson.attrDefaultLocale = fixture.defaultLocale.rawValue
            lesson.name = fixture.name
            lesson.attrSpotlight = fixture.isSpotlight
            lesson.isHidden = fixture.isHidden
            lesson.resourceType = fixture.resourceType.rawValue

            for languageCode in fixture.languageCodes {

                guard let language = languagesByCode[languageCode] else {
                    continue
                }

                lesson.addLanguage(language: language)
            }

            for (languageCode, translatedName) in fixture.translatedNamesByLanguageCode {

                guard let language = languagesByCode[languageCode] else {
                    continue
                }

                let translation = SwiftTranslation()
                translation.id = fixture.id + "-" + languageCode.rawValue
                translation.translatedName = translatedName
                translation.version = 1
                translation.isPublished = true
                translation.language = language
                translation.resource = lesson

                lesson.addLatestTranslation(translation: translation)

                translations.append(translation)
            }

            return lesson
        }

        return Array(languagesByCode.values) + lessons + translations
    }

    @available(iOS 17.4, *)
    private static func createLanguage(code: LanguageCodeDomainModel, directionString: String) -> SwiftLanguage {

        let language = SwiftLanguage()
        language.id = code.rawValue
        language.code = code.rawValue
        language.name = code.rawValue + " Name"
        language.directionString = directionString

        return language
    }

    private var allLessons: [LessonFixture] {

        return [
            LessonFixture(
                id: TestLessonId.featuredFirst,
                abbreviation: "lessonfirst",
                bannerImageId: "banner-first",
                defaultOrder: 0,
                defaultLocale: .english,
                name: "Lesson First Resource Name",
                isSpotlight: true,
                isHidden: false,
                resourceType: .lesson,
                languageCodes: [.arabic, .english, .spanish],
                translatedNamesByLanguageCode: [
                    .english: "Lesson First",
                    .spanish: "Lección primera"
                ]
            ),
            LessonFixture(
                id: TestLessonId.featuredSecond,
                abbreviation: "lessonsecond",
                bannerImageId: "banner-second",
                defaultOrder: 1,
                defaultLocale: .english,
                name: "Lesson Second Resource Name",
                isSpotlight: true,
                isHidden: false,
                resourceType: .lesson,
                languageCodes: [.english],
                translatedNamesByLanguageCode: [
                    .english: "Lesson Second"
                ]
            ),
            LessonFixture(
                id: TestLessonId.featuredThird,
                abbreviation: "lessonthird",
                bannerImageId: "banner-third",
                defaultOrder: 2,
                defaultLocale: .english,
                name: "Lesson Third Resource Name",
                isSpotlight: true,
                isHidden: false,
                resourceType: .lesson,
                languageCodes: [.arabic, .english, .spanish],
                translatedNamesByLanguageCode: [
                    .english: "Lesson Third",
                    .spanish: "Lección tercera"
                ]
            ),
            LessonFixture(
                id: TestLessonId.featuredUntranslated,
                abbreviation: "lessonuntranslated",
                bannerImageId: "banner-untranslated",
                defaultOrder: 3,
                defaultLocale: .english,
                name: "Lesson Untranslated Resource Name",
                isSpotlight: true,
                isHidden: false,
                resourceType: .lesson,
                languageCodes: [.english],
                translatedNamesByLanguageCode: [:]
            ),
            LessonFixture(
                id: TestLessonId.notSpotlighted,
                abbreviation: "lessonnotspotlighted",
                bannerImageId: "banner-not-spotlighted",
                defaultOrder: 4,
                defaultLocale: .english,
                name: "Lesson Not Spotlighted Resource Name",
                isSpotlight: false,
                isHidden: false,
                resourceType: .lesson,
                languageCodes: [.english],
                translatedNamesByLanguageCode: [
                    .english: "Lesson Not Spotlighted"
                ]
            ),
            LessonFixture(
                id: TestLessonId.hiddenSpotlighted,
                abbreviation: "lessonhidden",
                bannerImageId: "banner-hidden",
                defaultOrder: 5,
                defaultLocale: .english,
                name: "Lesson Hidden Resource Name",
                isSpotlight: true,
                isHidden: true,
                resourceType: .lesson,
                languageCodes: [.english],
                translatedNamesByLanguageCode: [
                    .english: "Lesson Hidden"
                ]
            ),
            LessonFixture(
                id: TestLessonId.spotlightedTract,
                abbreviation: "tractspotlighted",
                bannerImageId: "banner-tract",
                defaultOrder: 6,
                defaultLocale: .english,
                name: "Tract Spotlighted Resource Name",
                isSpotlight: true,
                isHidden: false,
                resourceType: .tract,
                languageCodes: [.english],
                translatedNamesByLanguageCode: [
                    .english: "Tract Spotlighted"
                ]
            )
        ]
    }
}
