//
//  GetGlobalActivityThisWeekUseCaseTests.swift
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

@Suite(.serialized)
struct GetGlobalActivityThisWeekUseCaseTests {

    struct GlobalAnalyticsFixture {
        let users: Int
        let gospelPresentations: Int
        let launches: Int
        let countries: Int
    }

    struct AppLanguageArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedCounts: [String]
    }

    private static let globalAnalyticsStringKeys: [LocalizableStringKeys] = [
        .accountActivityGlobalAnalyticsUsersTitle,
        .accountActivityGlobalAnalyticsGospelPresentationTitle,
        .accountActivityGlobalAnalyticsLaunchesTitle,
        .accountActivityGlobalAnalyticsCountriesTitle
    ]

    private let defaultGlobalAnalytics: GlobalAnalyticsFixture = GlobalAnalyticsFixture(
        users: 1234567,
        gospelPresentations: 89012,
        launches: 345,
        countries: 0
    )

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing global activity this week.
        When: Global analytics have been downloaded.
        Then: I expect users, gospel presentations, launches and countries in that order.
        """
    )
    @MainActor func activityIsListedAsUsersGospelPresentationsLaunchesAndCountries() async throws {

        let activity: [GlobalActivityDomainModel] = try await getGlobalActivityThisWeek(
            appLanguage: LanguageCodeDomainModel.english.value,
            globalAnalytics: defaultGlobalAnalytics
        )

        let expectedLabels: [String] = Self.globalAnalyticsStringKeys.map { (stringKey: LocalizableStringKeys) in
            "\(LanguageCodeDomainModel.english.value):\(stringKey.key)"
        }

        #expect(activity.map({ $0.label }) == expectedLabels)
        #expect(activity.map({ $0.count }) == ["1,234,567", "89,012", "345", "0"])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing global activity this week.
        When: My app language is set.
        Then: I expect each label to be localized in my app language.
        """,
        arguments: [
            LanguageCodeDomainModel.english.value,
            LanguageCodeDomainModel.spanish.value
        ]
    )
    @MainActor func labelsAreLocalizedInMyAppLanguage(appLanguage: AppLanguageDomainModel) async throws {

        let activity: [GlobalActivityDomainModel] = try await getGlobalActivityThisWeek(
            appLanguage: appLanguage,
            globalAnalytics: defaultGlobalAnalytics
        )

        let expectedLabels: [String] = Self.globalAnalyticsStringKeys.map { (stringKey: LocalizableStringKeys) in
            "\(appLanguage):\(stringKey.key)"
        }

        #expect(activity.map({ $0.label }) == expectedLabels)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing global activity this week.
        When: My app language is set.
        Then: I expect each count to be number formatted for my app language.
        """,
        arguments: [
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedCounts: ["1,234,567", "89,012", "345", "0"]
            ),
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedCounts: ["1.234.567", "89.012", "345", "0"]
            )
        ]
    )
    @MainActor func countsAreNumberFormattedForMyAppLanguage(argument: AppLanguageArgument) async throws {

        let activity: [GlobalActivityDomainModel] = try await getGlobalActivityThisWeek(
            appLanguage: argument.appLanguage,
            globalAnalytics: defaultGlobalAnalytics
        )

        #expect(activity.map({ $0.count }) == argument.expectedCounts)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing global activity this week.
        When: Global analytics have not been downloaded.
        Then: I expect no activity to be listed.
        """
    )
    @MainActor func noActivityIsListedWhenGlobalAnalyticsHaveNotBeenDownloaded() async throws {

        let activity: [GlobalActivityDomainModel] = try await getGlobalActivityThisWeek(
            appLanguage: LanguageCodeDomainModel.english.value,
            globalAnalytics: nil
        )

        #expect(activity.isEmpty)
    }
}

// MARK: - Test Helpers

extension GetGlobalActivityThisWeekUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getGlobalActivityThisWeek(appLanguage: AppLanguageDomainModel, globalAnalytics: GlobalAnalyticsFixture?) async throws -> [GlobalActivityDomainModel] {

        let useCase: GetGlobalActivityThisWeekUseCase = try getUseCase(globalAnalytics: globalAnalytics)

        var cancellables: Set<AnyCancellable> = Set()

        var activityRef: [GlobalActivityDomainModel]?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(appLanguage: appLanguage)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (activity: [GlobalActivityDomainModel]) in

                    guard activityRef == nil else {
                        return
                    }

                    activityRef = activity

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return try #require(activityRef)
    }

    @available(iOS 17.4, *)
    private func getUseCase(globalAnalytics: GlobalAnalyticsFixture?) throws -> GetGlobalActivityThisWeekUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        if let globalAnalytics = globalAnalytics {

            let context: ModelContext = swiftDatabase.openContext()

            context.insertObjects(objects: [Self.createGlobalAnalytics(fixture: globalAnalytics)])

            try context.saveIfHasChanges()
        }

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        return GetGlobalActivityThisWeekUseCase(
            globalAnalyticsRepository: testsDiContainer.feature.globalActivity.dataLayer.getGlobalAnalyticsRepository(),
            localizationServices: FakeLocalizationServices(
                localizableStrings: FakeLocalizationServices.getStrings(
                    stringKeys: Self.globalAnalyticsStringKeys,
                    languages: [.english, .spanish]
                )
            ),
            getTranslatedNumberCount: GetTranslatedNumberCount()
        )
    }

    @available(iOS 17.4, *)
    private static func createGlobalAnalytics(fixture: GlobalAnalyticsFixture) -> SwiftGlobalAnalytics {

        let globalAnalytics = SwiftGlobalAnalytics()
        globalAnalytics.id = GlobalAnalyticsRepository.sharedGlobalAnalyticsId
        globalAnalytics.createdAt = Date()
        globalAnalytics.users = fixture.users
        globalAnalytics.gospelPresentations = fixture.gospelPresentations
        globalAnalytics.launches = fixture.launches
        globalAnalytics.countries = fixture.countries

        return globalAnalytics
    }
}
