//
//  GodToolsDeepLinkingManifest.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GodToolsDeepLinkingManifest: DeepLinkingManifestType {
    
    let parserManifests: [DeepLinkingParserManifestType]
    
    required init() {
        
        parserManifests = [
            DeepLinkingParserManifestUrl(
                scheme: "godtools",
                host: "org.cru.godtools",
                rootPathComponent: "tool",
                parserClass: ToolDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "godtoolsapp.com",
                rootPathComponent: "lessons",
                parserClass: LessonDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "godtoolsapp.com",
                rootPathComponent: "article",
                parserClass: ArticleDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "godtools",
                host: "org.cru.godtools",
                rootPathComponent: "dashboard",
                parserClass: DashboardDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "knowgod.com",
                rootPathComponent: "lessons",
                parserClass: DashboardDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "godtoolsapp.com",
                rootPathComponent: "lessons",
                parserClass: DashboardDeepLinkParser.self
            ),
            DeepLinkingParserManifestUrl(
                scheme: "https",
                host: "knowgod.com",
                rootPathComponent: nil,
                parserClass: KnowGodTractDeepLinkParser.self
            ),
            DeepLinkingParserManifestAppsFlyer(
                parserClass: AppsFlyerDeepLinkValueParser.self
            ),
            DeepLinkingParserManifestAppsFlyer(
                parserClass: LegacyAppsFlyerDeepLinkValueParser.self
            )
        ]
    }
}
