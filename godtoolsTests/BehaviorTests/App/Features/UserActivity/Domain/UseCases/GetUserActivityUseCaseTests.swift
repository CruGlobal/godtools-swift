//
//  GetUserActivityUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine
import GodToolsShared
import SwiftData
import RepositorySync

@Suite(.serialized)
struct GetUserActivityUseCaseTests {

    struct CounterFixture {
        let id: String
        let count: Int
    }

    struct AppLanguageArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedToolOpensValue: String
        let expectedToolOpensText: String
    }

    struct BadgeArgument {
        let badgeId: String
        let expectedIsEarned: Bool
    }

    private static let statStringKeys: [LocalizableStringKeys] = [
        .accountActivityToolOpens,
        .accountActivityLessonCompletions,
        .accountActivityScreenShares,
        .accountActivityLinksShared,
        .accountActivityLanguagesUsed,
        .accountActivitySessions
    ]

    private static let badgeStringKeys: [String] = [
        "badges.articlesOpened",
        "badges.imagesShared",
        "badges.lessonsCompleted",
        "badges.toolsOpened",
        "badges.tipsCompleted"
    ]

    private let defaultCounters: [CounterFixture] = [
        CounterFixture(id: UserCounterNames.shared.TOOL_OPEN(tool: "kgp"), count: 3),
        CounterFixture(id: UserCounterNames.shared.TOOL_OPEN(tool: "fourlaws"), count: 2),
        CounterFixture(id: UserCounterNames.shared.LESSON_COMPLETION(tool: "lesson1"), count: 4),
        CounterFixture(id: UserCounterNames.shared.SCREEN_SHARE(tool: "kgp"), count: 5),
        CounterFixture(id: UserCounterNames.shared.LINK_SHARED, count: 6),
        CounterFixture(id: UserCounterNames.shared.SESSION, count: 7),
        CounterFixture(id: UserCounterNames.shared.LANGUAGE_USED(locale: Locale(identifier: "en")), count: 8),
        CounterFixture(id: UserCounterNames.shared.LANGUAGE_USED(locale: Locale(identifier: "es")), count: 9)
    ]

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: The activity is requested.
        Then: I expect stats for tool opens, lesson completions, screen shares, links shared, languages used and sessions in that order.
        """
    )
    @MainActor func statsAreListedInAFixedOrderWithTheirOwnIcons() async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.english.value,
            counters: defaultCounters
        )

        #expect(userActivity.stats.map({ $0.iconImageName }) == [
            ImageCatalog.userActivityToolOpens.name,
            ImageCatalog.userActivityLessonCompletions.name,
            ImageCatalog.userActivityScreenShares.name,
            ImageCatalog.userActivityLinksShared.name,
            ImageCatalog.userActivityLanguagesUsed.name,
            ImageCatalog.userActivitySessions.name
        ])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: My user counters have been recorded.
        Then: I expect each stat value to be totalled from my user counters.
        """
    )
    @MainActor func statValuesAreTotalledFromMyUserCounters() async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.english.value,
            counters: defaultCounters
        )

        #expect(userActivity.stats.map({ $0.value }) == ["5", "4", "5", "6", "2", "7"])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: No user counters have been recorded.
        Then: I expect every stat value to be zero.
        """
    )
    @MainActor func statValuesAreZeroWhenNoUserCountersHaveBeenRecorded() async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.english.value,
            counters: []
        )

        #expect(userActivity.stats.map({ $0.value }) == ["0", "0", "0", "0", "0", "0"])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: My app language is set.
        Then: I expect each stat text and value to be translated in my app language.
        """,
        arguments: [
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedToolOpensValue: "1,234,567",
                expectedToolOpensText: "en:\(LocalizableStringKeys.accountActivityToolOpens.key) 1234567"
            ),
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedToolOpensValue: "1.234.567",
                expectedToolOpensText: "es:\(LocalizableStringKeys.accountActivityToolOpens.key) 1234567"
            )
        ]
    )
    @MainActor func statTextAndValueAreTranslatedInMyAppLanguage(argument: AppLanguageArgument) async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: argument.appLanguage,
            counters: [CounterFixture(id: UserCounterNames.shared.TOOL_OPEN(tool: "kgp"), count: 1234567)]
        )

        let toolOpensStat: UserActivityStatDomainModel = try #require(userActivity.stats.first)

        #expect(toolOpensStat.value == argument.expectedToolOpensValue)
        #expect(toolOpensStat.text == argument.expectedToolOpensText)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: The activity is requested.
        Then: I expect a badge for every badge type and variant.
        """
    )
    @MainActor func aBadgeIsReturnedForEveryBadgeTypeAndVariant() async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.english.value,
            counters: []
        )

        let badgeIds: [String] = userActivity.badges.map({ $0.id }).sorted()

        #expect(badgeIds == [
            "ARTICLES_OPENED_1", "ARTICLES_OPENED_2", "ARTICLES_OPENED_3",
            "IMAGES_SHARED_1", "IMAGES_SHARED_2", "IMAGES_SHARED_3",
            "LESSONS_COMPLETED_1", "LESSONS_COMPLETED_2", "LESSONS_COMPLETED_3",
            "TIPS_COMPLETED_1", "TIPS_COMPLETED_2", "TIPS_COMPLETED_3",
            "TOOLS_OPENED_1", "TOOLS_OPENED_2", "TOOLS_OPENED_3"
        ])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: No activity has been recorded.
        Then: I expect no badge to be earned.
        """
    )
    @MainActor func noBadgeIsEarnedWhenNoActivityHasBeenRecorded() async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.english.value,
            counters: []
        )

        #expect(userActivity.badges.contains(where: { $0.isEarned }) == false)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: I have opened enough tools to reach a badge target.
        Then: I expect only the badges whose target I reached to be earned.
        """,
        arguments: [
            BadgeArgument(badgeId: "TOOLS_OPENED_1", expectedIsEarned: true),
            BadgeArgument(badgeId: "TOOLS_OPENED_2", expectedIsEarned: true),
            BadgeArgument(badgeId: "TOOLS_OPENED_3", expectedIsEarned: false)
        ]
    )
    @MainActor func onlyBadgesWhoseTargetIsReachedAreEarned(argument: BadgeArgument) async throws {

        let openedTools: [CounterFixture] = (0..<5).map { (toolIndex: Int) in
            CounterFixture(id: UserCounterNames.shared.TOOL_OPEN(tool: "tool-\(toolIndex)"), count: 1)
        }

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.english.value,
            counters: openedTools
        )

        let badge: UserActivityBadgeDomainModel = try #require(userActivity.badges.first(where: { $0.id == argument.badgeId }))

        #expect(badge.isEarned == argument.expectedIsEarned)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: I have completed training tips.
        Then: I expect the completed training tips to count toward my tips completed badges.
        """
    )
    @MainActor func completedTrainingTipsCountTowardMyTipsCompletedBadges() async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.english.value,
            counters: [],
            numberOfCompletedTrainingTips: 5
        )

        let firstTipsBadge: UserActivityBadgeDomainModel = try #require(userActivity.badges.first(where: { $0.id == "TIPS_COMPLETED_1" }))
        let secondTipsBadge: UserActivityBadgeDomainModel = try #require(userActivity.badges.first(where: { $0.id == "TIPS_COMPLETED_2" }))

        #expect(firstTipsBadge.isEarned)
        #expect(secondTipsBadge.isEarned == false)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: A tips completed user counter is cached and I have completed training tips.
        Then: I expect my completed training tips to be used instead of the cached counter.
        """
    )
    @MainActor func completedTrainingTipsAreUsedInsteadOfACachedTipsCompletedCounter() async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.english.value,
            counters: [CounterFixture(id: UserCounterNames.shared.TIPS_COMPLETED, count: 99)],
            numberOfCompletedTrainingTips: 0
        )

        let firstTipsBadge: UserActivityBadgeDomainModel = try #require(userActivity.badges.first(where: { $0.id == "TIPS_COMPLETED_1" }))

        #expect(firstTipsBadge.isEarned == false)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their activity.
        When: My app language is set.
        Then: I expect each badge text to be localized in my app language.
        """
    )
    @MainActor func badgeTextIsLocalizedInMyAppLanguage() async throws {

        let userActivity: UserActivityDomainModel = try await getUserActivity(
            appLanguage: LanguageCodeDomainModel.spanish.value,
            counters: []
        )

        let toolsOpenedBadge: UserActivityBadgeDomainModel = try #require(userActivity.badges.first(where: { $0.id == "TOOLS_OPENED_2" }))

        #expect(toolsOpenedBadge.badgeText == "es:badges.toolsOpened 5")
        #expect(toolsOpenedBadge.iconImageName == "tools-2")
    }
}

// MARK: - Test Helpers

extension GetUserActivityUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getUserActivity(appLanguage: AppLanguageDomainModel, counters: [CounterFixture], numberOfCompletedTrainingTips: Int = 0) async throws -> UserActivityDomainModel {

        let useCase: GetUserActivityUseCase = try await getUseCase(
            counters: counters,
            numberOfCompletedTrainingTips: numberOfCompletedTrainingTips
        )

        var cancellables: Set<AnyCancellable> = Set()

        var userActivityRef: UserActivityDomainModel?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(appLanguage: appLanguage)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (userActivity: UserActivityDomainModel) in

                    guard userActivityRef == nil else {
                        return
                    }

                    userActivityRef = userActivity

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return try #require(userActivityRef)
    }

    @available(iOS 17.4, *)
    private func getUseCase(counters: [CounterFixture], numberOfCompletedTrainingTips: Int) async throws -> GetUserActivityUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects(counters: counters))

        try context.saveIfHasChanges()

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        let completedTrainingTipRepository: CompletedTrainingTipRepository = testsDiContainer.core.dataLayer.getCompletedTrainingTipRepository()

        for tipIndex in 0..<numberOfCompletedTrainingTips {

            try await completedTrainingTipRepository.storeCompletedTrainingTip(
                id: TrainingTipId(trainingTipId: "tip-\(tipIndex)", languageId: "en", resourceId: "tool-\(tipIndex)")
            )
        }

        return GetUserActivityUseCase(
            getUserActivityBadge: GetUserActivityBadge(
                localizationServices: getLocalizationServices(),
                stringWithLocaleCount: FakeStringWithLocaleCount()
            ),
            getUserActivityStats: GetUserActivityStats(
                localizationServices: getLocalizationServices(),
                getTranslatedNumberCount: GetTranslatedNumberCount(),
                stringWithLocaleCount: FakeStringWithLocaleCount()
            ),
            userCounterRepository: testsDiContainer.core.dataLayer.getUserCountersRepository(),
            completedTrainingTipRepository: completedTrainingTipRepository
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        var localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = FakeLocalizationServices.getStrings(
            stringKeys: Self.statStringKeys,
            languages: [.english, .spanish]
        )

        for language in [LanguageCodeDomainModel.english, LanguageCodeDomainModel.spanish] {

            var stringsForLanguage: [FakeLocalizationServices.StringKey: String] = localizableStrings[language.value] ?? Dictionary()

            for badgeStringKey in Self.badgeStringKeys {
                stringsForLanguage[badgeStringKey] = "\(language.value):\(badgeStringKey)"
            }

            localizableStrings[language.value] = stringsForLanguage
        }

        return FakeLocalizationServices(localizableStrings: localizableStrings)
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects(counters: [CounterFixture]) -> [any PersistentModel] {

        return counters.map { (fixture: CounterFixture) in

            let userCounter = SwiftUserCounter()
            userCounter.id = fixture.id
            userCounter.count = fixture.count

            return userCounter
        }
    }
}
