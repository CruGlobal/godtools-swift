//
//  GodToolsDeepLinkingManifest.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GodToolsDeepLinkingManifest: DeepLinkingManifestInterface {
    
    let parserManifests: [DeepLinkingParserManifestInterface]
    
    init() {
        
        parserManifests = [
            DeepLinkingParserManifestUrl(
                scheme: "godtools",
                host: "org.cru.godtools",
                path: "dashboard",
                parserClass: DashboardPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "godtoolsapp.com",
                path: "deeplink/dashboard",
                parserClass: DashboardPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "godtools",
                host: "org.cru.godtools",
                path: "tool",
                parserClass: ToolPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "godtoolsapp.com",
                path: "deeplink/tool",
                parserClass: ToolPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "godtoolsapp.com",
                path: "article/aem",
                parserClass: ArticleAemPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "knowgod.com",
                path: nil,
                parserClass: KnowGodDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "godtools",
                host: "knowgod.com",
                path: nil,
                parserClass: KnowGodDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "godtoolsapp.com",
                path: "lessons",
                parserClass: GodToolsAppLessonsPathDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "godtools",
                host: "org.cru.godtools",
                path: "settings/language",
                parserClass: LanguageSettingsDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "godtoolsapp.com",
                path: "deeplink/settings/language",
                parserClass: LanguageSettingsDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "godtools",
                host: "org.cru.godtools",
                path: "ui_tests",
                parserClass: UITestsDeepLinkParser.self
            )
        ]
    }
}
