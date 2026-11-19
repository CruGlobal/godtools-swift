//
//  GetDeferredDeepLinkUseCaseTests.swift
//  godtoolsTests
//
//  Created by Claude on 9/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import RepositorySync

private enum TestDeferredDeepLinkUrl {
    static let dynalinksLanguageSettings: String = "https://godtools.dynalinks.app/deeplink/settings/language"
    static let godToolsAppLanguageSettings: String = "https://godtoolsapp.com/deeplink/settings/language"
    static let dynalinksUnrecognizedPath: String = "https://godtools.dynalinks.app/unrecognized/path"
}

struct GetDeferredDeepLinkUseCaseTests {

    struct DeferredDeepLinkArgument {
        let deepLinkUrl: String
        let expectedDeepLink: ParsedDeepLinkType
    }

    private static let firstLaunchCount: Int = 1

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I installed GodTools by tapping a GodTools link.
        When: I open the app for the first time.
        Then: I expect to be taken to the content the link points to.
        """,
        arguments: [
            DeferredDeepLinkArgument(
                deepLinkUrl: TestDeferredDeepLinkUrl.dynalinksLanguageSettings,
                expectedDeepLink: .languageSettings
            ),
            DeferredDeepLinkArgument(
                deepLinkUrl: TestDeferredDeepLinkUrl.godToolsAppLanguageSettings,
                expectedDeepLink: .languageSettings
            )
        ]
    )
    func firstLaunchFromADeferredLinkReturnsTheLinkedContent(argument: DeferredDeepLinkArgument) async throws {

        let deferredDeepLinkUrl: URL = try #require(URL(string: argument.deepLinkUrl))

        let useCase: GetDeferredDeepLinkUseCase = try await getUseCase(
            launchCount: Self.firstLaunchCount,
            deferredDeepLinkUrl: deferredDeepLinkUrl
        )

        let deepLink: ParsedDeepLinkType? = await useCase.execute()

        #expect(deepLink == argument.expectedDeepLink)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I installed GodTools without tapping a GodTools link.
        When: I open the app for the first time.
        Then: I expect no deferred deep link so the app continues its normal launch.
        """
    )
    func firstLaunchWithoutADeferredLinkReturnsNoDeepLink() async throws {

        let useCase: GetDeferredDeepLinkUseCase = try await getUseCase(
            launchCount: Self.firstLaunchCount,
            deferredDeepLinkUrl: nil
        )

        let deepLink: ParsedDeepLinkType? = await useCase.execute()

        #expect(deepLink == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I have opened GodTools before and a deferred link is available.
        When: I open the app again.
        Then: I expect the deferred link to be ignored.
        """,
        arguments: [2, 10]
    )
    func deferredLinkIsIgnoredAfterTheFirstLaunch(launchCount: Int) async throws {

        let deferredDeepLinkUrl: URL = try #require(URL(string: TestDeferredDeepLinkUrl.dynalinksLanguageSettings))

        let useCase: GetDeferredDeepLinkUseCase = try await getUseCase(
            launchCount: launchCount,
            deferredDeepLinkUrl: deferredDeepLinkUrl
        )

        let deepLink: ParsedDeepLinkType? = await useCase.execute()

        #expect(deepLink == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: I installed GodTools by tapping a link GodTools does not recognize.
        When: I open the app for the first time.
        Then: I expect no deferred deep link so the app continues its normal launch.
        """
    )
    func unrecognizedDeferredLinkReturnsNoDeepLink() async throws {

        let deferredDeepLinkUrl: URL = try #require(URL(string: TestDeferredDeepLinkUrl.dynalinksUnrecognizedPath))

        let useCase: GetDeferredDeepLinkUseCase = try await getUseCase(
            launchCount: Self.firstLaunchCount,
            deferredDeepLinkUrl: deferredDeepLinkUrl
        )

        let deepLink: ParsedDeepLinkType? = await useCase.execute()

        #expect(deepLink == nil)
    }
}

// MARK: - Test Helpers

extension GetDeferredDeepLinkUseCaseTests {

    @available(iOS 17.4, *)
    private func getUseCase(launchCount: Int, deferredDeepLinkUrl: URL?) async throws -> GetDeferredDeepLinkUseCase {

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())
            )
        )

        let launchCountRepository: LaunchCountRepositoryInterface = testsDiContainer.core.dataLayer.getLaunchCountRepository()

        try await launchCountRepository.storeLaunchCount(count: launchCount)

        return GetDeferredDeepLinkUseCase(
            deepLinkService: testsDiContainer.core.dataLayer.getDeepLinkingService(),
            dynalinkDeferredDeepLink: FakeDynalinkDeferredDeepLink(deepLinkUrl: deferredDeepLinkUrl),
            launchCountRepository: launchCountRepository
        )
    }
}
