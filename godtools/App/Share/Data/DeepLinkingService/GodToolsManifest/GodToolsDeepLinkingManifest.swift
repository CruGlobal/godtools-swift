//
//  GodToolsDeepLinkingManifest.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GodToolsDeepLinkingManifest: DeepLinkingManifestInterface {
    
    private static let schemeGodTools: String = "godtools"
    private static let schemeHttps: String = "https"
    private static let hostGodTools: String = "org.cru.godtools"
    private static let hostGodToolsApp: String = "godtoolsapp.com"
    private static let hostKnowGod: String = "knowgod.com"
    private static let hostDynalinks: String = "godtools.dynalinks.app"
    
    let parserManifests: [DeepLinkingParserManifestInterface]
    
    init() {
        
        parserManifests = [
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeGodTools,
                hosts: [Self.hostGodTools],
                path: "dashboard",
                parserClass: DashboardPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeHttps,
                hosts: [Self.hostGodToolsApp, Self.hostDynalinks],
                path: "deeplink/dashboard",
                parserClass: DashboardPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeGodTools,
                hosts: [Self.hostGodTools],
                path: "tool",
                parserClass: ToolPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeHttps,
                hosts: [Self.hostGodToolsApp, Self.hostDynalinks],
                path: "deeplink/tool",
                parserClass: ToolPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeHttps,
                hosts: [Self.hostGodToolsApp, Self.hostDynalinks],
                path: "article/aem",
                parserClass: ArticleAemPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeHttps,
                hosts: [Self.hostKnowGod],
                path: nil,
                parserClass: KnowGodDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeGodTools,
                hosts: [Self.hostKnowGod],
                path: nil,
                parserClass: KnowGodDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeHttps,
                hosts: [Self.hostKnowGod],
                path: nil,
                parserClass: LegacyKnowGodDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeGodTools,
                hosts: [Self.hostKnowGod],
                path: nil,
                parserClass: LegacyKnowGodDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeHttps,
                hosts: [Self.hostGodToolsApp, Self.hostDynalinks],
                path: "lessons",
                parserClass: GodToolsAppLessonsPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeGodTools,
                hosts: [Self.hostGodTools],
                path: "settings/language",
                parserClass: LanguageSettingsDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeHttps,
                hosts: [Self.hostGodToolsApp, Self.hostDynalinks],
                path: "deeplink/settings/language",
                parserClass: LanguageSettingsDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: Self.schemeGodTools,
                hosts: [Self.hostGodTools, Self.hostDynalinks],
                path: "ui_tests",
                parserClass: UITestsDeepLinkParser.self
            )
        ]
    }
}
