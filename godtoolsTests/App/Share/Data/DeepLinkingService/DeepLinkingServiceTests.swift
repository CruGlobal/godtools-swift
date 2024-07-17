//
//  DeepLinkingServiceTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 2/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class DeepLinkingServiceTests: XCTestCase {

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
        
        case knowgodTractTeachMeToShareEnglishPage4 = "https://knowgod.com/en/teachmetoshare/4"
        case knowgodTractTeachMeToShareEnglishWithLiveShareStream = "https://knowgod.com/en/teachmetoshare?icid=gtshare&primaryLanguage=en&liveShareStream=acd9bee66b6057476cee-1612666248"
        case knowgodTractTeachMeToShareSpanishAndRussian = "https://knowgod.com/es/teachmetoshare?primaryLanguage=es&parallelLanguage=ru"
        case knowgodLessonLessonConvoEnglish = "https://knowgod.com/lessons/lessonconvo/en"
        
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
    
    private let deepLinkingService: DeepLinkingService = DeepLinkingService(manifest: GodToolsDeepLinkingManifest())
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Dashboard
    
    func testLessonsDeepLinkFromGodToolsCustomUrlScheme() {
                
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsCustomUrlSchemeLessons.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .lessonsList)
    }
    
    func testHomeDeepLinkFromGodToolsCustomUrlScheme() {
                
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsCustomUrlSchemeHome.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .favoritedToolsList)
    }
    
    func testAllToolsDeepLinkFromGodToolsCustomUrlScheme() {
                
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsCustomUrlSchemeTools.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .allToolsList)
    }
    
    func testDashboardDeepLinkFromGodtoolsAppDeepLinkPath() {
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppDeepLinkDashboard.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .dashboard)
    }
    
    func testLessonsDeepLinkFromGodtoolsAppDashboardDeepLinkPath() {
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppDeepLinkDashboardLessons.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .lessonsList)
    }
    
    func testHomeDeepLinkFromGodtoolsAppDashboardDeepLinkPath() {
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppDeepLinkDashboardHome.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .favoritedToolsList)
    }
    
    func testAllToolsDeepLinkFromGodtoolsAppDashboardDeepLinkPath() {
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppDeepLinkDashboardTools.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .allToolsList)
    }
    
    func testLessonsDeepLinkFromGodToolsAppLessonsDeepLinkPath() {
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppLessons.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .lessonsList)
    }
    
    // MARK: - Tools
    
    func testTractPowerOverFearEnglishDeepLinkFromGodToolsCustomUrlScheme() {
        
        let powerOverFearEnglish: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "poweroverfear",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsCustomUrlSchemeTractPowerOverFearEnglish.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == powerOverFearEnglish)
    }
    
    func testLessonLessonConvoEnglishDeepLinkFromGodToolsCustomUrlScheme() {
        
        let lessonConvoEnglish: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "lessonconvo",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsCustomUrlSchemeLessonLessonConvoEnglish.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == lessonConvoEnglish)
    }
    
    func testArticleESEnglishDeepLinkFromGodToolsCustomUrlScheme() {
        
        let articleESEnglish: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "es",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsCustomUrlSchemeArticleESEnglish.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == articleESEnglish)
    }
    
    func testTractPowerOverFearEnglishDeepLinkFromGodToolsApp() {
        
        let powerOverFearEnglish: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "poweroverfear",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppDeepLinkTractPowerOverFearEnglish.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == powerOverFearEnglish)
    }
    
    func testLessonLessonConvoEnglishDeepLinkFromGodToolsApp() {
        
        let lessonConvoEnglish: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "lessonconvo",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppDeepLinkLessonLessonConvoEnglish.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == lessonConvoEnglish)
    }
    
    func testArticleESEnglishDeepLinkFromGodToolsApp() {
        
        let articleESEnglish: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "es",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppDeepLinkArticleESEnglish.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == articleESEnglish)
    }
    
    func testTractPowerOverFearGermanPage5DeepLinkFromGodToolsApp() {
        
        let powerOverFearGermanPage5: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "poweroverfear",
                primaryLanguageCodes: ["de"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: 5,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppDeepLinkTractPowerOverFearGermanPage5.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == powerOverFearGermanPage5)
    }
    
    func testArticleAemUriDeepLinkFromGodToolsApp() {

        let articleAemUri: ParsedDeepLinkType = .articleAemUri(aemUri: "https://cru.org/content/experience-fragments/shared-library/language-masters/es/questions_about_god_/-quien-es-el-espiritu-santo-/godtools-variation/.html")
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppArticleAemUri.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == articleAemUri)
    }
    
    func testLessonLessonConvoSpanishDeepLinkFromGodToolsAppLessonsPath() {
        
        let lessonConvoEnglish: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "lessonconvo",
                primaryLanguageCodes: ["es"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsAppLessonsLessonConvoSpanish.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == lessonConvoEnglish)
    }
    
    func testTractTeachMeToShareEnglishPage4FromKnowGod() {
        
        let primaryLanguageIndex: Int = 0
        
        let tract: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "teachmetoshare",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: 4,
                pageId: nil,
                selectedLanguageIndex: primaryLanguageIndex
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.knowgodTractTeachMeToShareEnglishPage4.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == tract)
    }
    
    func testTractTeachMeToShareEnglishWithLiveStreamFromKnowGod() {
        
        let primaryLanguageIndex: Int = 0
        
        let tract: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "teachmetoshare",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: "acd9bee66b6057476cee-1612666248",
                page: nil,
                pageId: nil,
                selectedLanguageIndex: primaryLanguageIndex
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.knowgodTractTeachMeToShareEnglishWithLiveShareStream.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == tract)
    }
    
    func testTractTeachMeToShareSpanishAndRussianFromKnowGod() {
        
        let primaryLanguageIndex: Int = 0
        
        let tract: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "teachmetoshare",
                primaryLanguageCodes: ["es"],
                parallelLanguageCodes: ["ru"],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: primaryLanguageIndex
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.knowgodTractTeachMeToShareSpanishAndRussian.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == tract)
    }
    
    func testLessonLessonConvoEnglishFromKnowGod() {
        
        let tract: ParsedDeepLinkType = .tool(
            toolDeepLink: ToolDeepLink(
                resourceAbbreviation: "lessonconvo",
                primaryLanguageCodes: ["en"],
                parallelLanguageCodes: [],
                liveShareStream: nil,
                page: nil,
                pageId: nil,
                selectedLanguageIndex: nil
            )
        )
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.knowgodLessonLessonConvoEnglish.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == tract)
    }
    
    // MARK: -
    
    func testOnboardingDeepLinkFromGodToolsCustomUrlScheme() {
        
        let parsedDeepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: DeepLinkUrl.godtoolsCustomUrlSchemeUITestsOnboarding.incomingDeepLinkUrl)
        
        XCTAssertTrue(parsedDeepLink == .onboarding(appLanguage: "en"))
    }
}
