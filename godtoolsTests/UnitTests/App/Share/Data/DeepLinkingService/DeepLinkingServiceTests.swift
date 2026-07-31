//
//  DeepLinkingServiceTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 2/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools

enum DeepLinkUrl: String {

    case godtoolsCustomUrlSchemeLessons = "godtools://org.cru.godtools/dashboard/lessons"
    case godtoolsCustomUrlSchemeHome = "godtools://org.cru.godtools/dashboard/home"
    case godtoolsCustomUrlSchemeTools = "godtools://org.cru.godtools/dashboard/tools"
    case godtoolsCustomUrlSchemeTractPowerOverFearEnglish = "godtools://org.cru.godtools/tool/tract/poweroverfear/en"
    case godtoolsCustomUrlSchemeLessonLessonConvoEnglish = "godtools://org.cru.godtools/tool/lesson/lessonconvo/en"
    case godtoolsCustomUrlSchemeArticleESEnglish = "godtools://org.cru.godtools/tool/article/es/en"
    case godtoolsCustomUrlSchemeUITestsOnboarding = "godtools://org.cru.godtools/ui_tests/onboarding"

    case godtoolsAppDeepLinkDashboard = "https://godtoolsapp.com/deeplink/dashboard"
    case godtoolsAppDeepLinkDashboardLessons = "https://godtoolsapp.com/deeplink/dashboard/lessons"
    case godtoolsAppDeepLinkDashboardHome = "https://godtoolsapp.com/deeplink/dashboard/home"
    case godtoolsAppDeepLinkDashboardTools = "https://godtoolsapp.com/deeplink/dashboard/tools"
    case godtoolsAppDeepLinkTractPowerOverFearEnglish = "https://godtoolsapp.com/deeplink/tool/tract/poweroverfear/en"
    case godtoolsAppDeepLinkLessonLessonConvoEnglish = "https://godtoolsapp.com/deeplink/tool/lesson/lessonconvo/en"
    case godtoolsAppDeepLinkArticleESEnglish = "https://godtoolsapp.com/deeplink/tool/article/es/en"
    case godtoolsAppDeepLinkTractPowerOverFearGermanPage5 = "https://godtoolsapp.com/deeplink/tool/tract/poweroverfear/de/5"
    case godtoolsAppArticleAemUri = "https://godtoolsapp.com/article/aem?uri=https://cru.org/content/experience-fragments/shared-library/language-masters/es/questions_about_god_/-quien-es-el-espiritu-santo-/godtools-variation/.html"
    case godtoolsAppLessons = "https://godtoolsapp.com/lessons"
    case godtoolsAppLessonsLessonConvoSpanish = "https://godtoolsapp.com/lessons/lessonconvo/es"

    case legacyKnowgodTractTeachMeToShareEnglishPage4 = "https://knowgod.com/en/teachmetoshare/4"
    case legacyKnowgodTractTeachMeToShareEnglishWithLiveShareStream = "https://knowgod.com/en/teachmetoshare?icid=gtshare&primaryLanguage=en&liveShareStream=acd9bee66b6057476cee-1612666248"
    case legacyKnowgodTractTeachMeToShareSpanishAndRussian = "https://knowgod.com/es/teachmetoshare?primaryLanguage=es&parallelLanguage=ru"
    case legacyKnowgodLessonListen = "https://knowgod.com/en/lessonlisten/2"
    case knowgodTractKpgEnglish = "https://knowgod.com/en/tool/v1/kgp"
    case knowgodTractKpgEnglishPage1 = "https://knowgod.com/en/tool/v1/kgp/1"
    case knowgodLessonLessonConvoEnglish = "https://knowgod.com/lessons/lessonconvo/en"
    case knowgodLessonLessonListenEnglish = "https://knowgod.com/en/lesson/lessonlisten/7"

    case knowgodCyoaOpenersEnglish = "https://knowgod.com/en/tool/v2/openers"
    case knowgodCyoaOpenersEnglishPageCulture = "https://knowgod.com/en/tool/v2/openers/culture"
    case knowgodCyoaOpenersEnglishPageCultureSubIndex2 = "https://knowgod.com/en/tool/v2/openers/culture/2"
    case knowgodCyoaSNLEnglishPageIntoPageCollectionSubIndex1 = "https://knowgod.com/en/tool/v2/seenknownloved/intro_page_collection/1"

    var url: URL {
        return DeepLinkUrl.getUrl(string: rawValue)
    }

    var incomingDeepLinkUrl: IncomingDeepLinkType {
        return DeepLinkUrl.getIncomingDeepLinkUrl(url: url)
    }

    static func getUrl(string: String) -> URL {
        return URL(string: string)!
    }

    static func getIncomingDeepLinkUrl(url: URL) -> IncomingDeepLinkType {
        return .url(incomingUrl: IncomingDeepLinkUrl(url: url))
    }
}

struct DeepLinkArgument: Sendable {

    let deepLinkUrl: DeepLinkUrl
    let expectedParsedDeepLink: ParsedDeepLinkType
}

struct DeepLinkingServiceTests {

    private static let dashboardDeepLinkArguments: [DeepLinkArgument] = [
        DeepLinkArgument(deepLinkUrl: .godtoolsCustomUrlSchemeLessons, expectedParsedDeepLink: .lessonsList),
        DeepLinkArgument(deepLinkUrl: .godtoolsCustomUrlSchemeHome, expectedParsedDeepLink: .favoritedToolsList),
        DeepLinkArgument(deepLinkUrl: .godtoolsCustomUrlSchemeTools, expectedParsedDeepLink: .allToolsList),
        DeepLinkArgument(deepLinkUrl: .godtoolsAppDeepLinkDashboard, expectedParsedDeepLink: .dashboard),
        DeepLinkArgument(deepLinkUrl: .godtoolsAppDeepLinkDashboardLessons, expectedParsedDeepLink: .lessonsList),
        DeepLinkArgument(deepLinkUrl: .godtoolsAppDeepLinkDashboardHome, expectedParsedDeepLink: .favoritedToolsList),
        DeepLinkArgument(deepLinkUrl: .godtoolsAppDeepLinkDashboardTools, expectedParsedDeepLink: .allToolsList),
        DeepLinkArgument(deepLinkUrl: .godtoolsAppLessons, expectedParsedDeepLink: .lessonsList)
    ]

    private static let toolDeepLinkArguments: [DeepLinkArgument] = [
        DeepLinkArgument(
            deepLinkUrl: .godtoolsCustomUrlSchemeTractPowerOverFearEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(resourceAbbreviation: "poweroverfear")
        ),
        DeepLinkArgument(
            deepLinkUrl: .godtoolsCustomUrlSchemeLessonLessonConvoEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(resourceAbbreviation: "lessonconvo")
        ),
        DeepLinkArgument(
            deepLinkUrl: .godtoolsCustomUrlSchemeArticleESEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(resourceAbbreviation: "es")
        ),
        DeepLinkArgument(
            deepLinkUrl: .godtoolsAppDeepLinkTractPowerOverFearEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(resourceAbbreviation: "poweroverfear")
        ),
        DeepLinkArgument(
            deepLinkUrl: .godtoolsAppDeepLinkLessonLessonConvoEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(resourceAbbreviation: "lessonconvo")
        ),
        DeepLinkArgument(
            deepLinkUrl: .godtoolsAppDeepLinkArticleESEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(resourceAbbreviation: "es")
        ),
        DeepLinkArgument(
            deepLinkUrl: .godtoolsAppDeepLinkTractPowerOverFearGermanPage5,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "poweroverfear",
                primaryLanguageCodes: ["de"],
                page: 5
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .godtoolsAppLessonsLessonConvoSpanish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "lessonconvo",
                primaryLanguageCodes: ["es"]
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .legacyKnowgodTractTeachMeToShareEnglishPage4,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "teachmetoshare",
                page: 4,
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .legacyKnowgodTractTeachMeToShareEnglishWithLiveShareStream,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "teachmetoshare",
                liveShareStream: "acd9bee66b6057476cee-1612666248",
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .legacyKnowgodTractTeachMeToShareSpanishAndRussian,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "teachmetoshare",
                primaryLanguageCodes: ["es"],
                parallelLanguageCodes: ["ru"],
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .legacyKnowgodLessonListen,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "lessonlisten",
                page: 2,
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .knowgodTractKpgEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "kgp",
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .knowgodTractKpgEnglishPage1,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "kgp",
                page: 1,
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .knowgodLessonLessonConvoEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(resourceAbbreviation: "lessonconvo")
        ),
        DeepLinkArgument(
            deepLinkUrl: .knowgodLessonLessonListenEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "lessonlisten",
                page: 7
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .knowgodCyoaOpenersEnglish,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "openers",
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .knowgodCyoaOpenersEnglishPageCulture,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "openers",
                pageId: "culture",
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .knowgodCyoaOpenersEnglishPageCultureSubIndex2,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "openers",
                pageId: "culture",
                pageSubIndex: 2,
                selectedLanguageIndex: 0
            )
        ),
        DeepLinkArgument(
            deepLinkUrl: .knowgodCyoaSNLEnglishPageIntoPageCollectionSubIndex1,
            expectedParsedDeepLink: DeepLinkingServiceTests.toolDeepLink(
                resourceAbbreviation: "seenknownloved",
                pageId: "intro_page_collection",
                pageSubIndex: 1,
                selectedLanguageIndex: 0
            )
        )
    ]

    private let deepLinkingService: DeepLinkingService = DeepLinkingService(manifest: GodToolsDeepLinkingManifest())

    // MARK: - Dashboard

    @Test(
        """
        Given: A user opens a dashboard deep link.
        When: The deep link is parsed.
        Then: The deep link should be parsed into the expected dashboard destination.
        """,
        arguments: DeepLinkingServiceTests.dashboardDeepLinkArguments
    )
    func dashboardDeepLinkIsParsedIntoExpectedDestination(argument: DeepLinkArgument) {

        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: argument.deepLinkUrl.incomingDeepLinkUrl)

        #expect(parsedDeepLink == argument.expectedParsedDeepLink)
    }

    // MARK: - Tools

    @Test(
        """
        Given: A user opens a tool deep link.
        When: The deep link is parsed.
        Then: The deep link should be parsed into the expected tool deep link.
        """,
        arguments: DeepLinkingServiceTests.toolDeepLinkArguments
    )
    func toolDeepLinkIsParsedIntoExpectedToolDeepLink(argument: DeepLinkArgument) {

        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: argument.deepLinkUrl.incomingDeepLinkUrl)

        #expect(parsedDeepLink == argument.expectedParsedDeepLink)
    }

    @Test(
        """
        Given: A user opens an article aem uri deep link.
        When: The deep link is parsed.
        Then: The deep link should be parsed into the article's aem uri.
        """
    )
    func articleAemUriDeepLinkIsParsedIntoAemUri() {

        let expectedParsedDeepLink: ParsedDeepLinkType = .articleAemUri(aemUri: "https://cru.org/content/experience-fragments/shared-library/language-masters/es/questions_about_god_/-quien-es-el-espiritu-santo-/godtools-variation/.html")

        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppArticleAemUri.incomingDeepLinkUrl)

        #expect(parsedDeepLink == expectedParsedDeepLink)
    }

    // MARK: - Onboarding

    @Test(
        """
        Given: A user opens an onboarding deep link.
        When: The deep link is parsed.
        Then: The deep link should be parsed into onboarding with the english app language.
        """
    )
    func onboardingDeepLinkIsParsedIntoOnboarding() {

        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsCustomUrlSchemeUITestsOnboarding.incomingDeepLinkUrl)

        #expect(parsedDeepLink == .onboarding(appLanguage: "en"))
    }
}

extension DeepLinkingServiceTests {

    private static func toolDeepLink(resourceAbbreviation: String, primaryLanguageCodes: [String] = ["en"], parallelLanguageCodes: [String] = [], liveShareStream: String? = nil, page: Int? = nil, pageId: String? = nil, pageSubIndex: Int? = nil, selectedLanguageIndex: Int? = nil) -> ParsedDeepLinkType {

        return .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: resourceAbbreviation,
                primaryLanguageCodes: primaryLanguageCodes,
                parallelLanguageCodes: parallelLanguageCodes,
                liveShareStream: liveShareStream,
                page: page,
                pageId: pageId,
                pageSubIndex: pageSubIndex,
                selectedLanguageIndex: selectedLanguageIndex
            )
        )
    }
}
