//
//  ParseTranslationManifestForRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import Combine

class ParseTranslationManifestForRenderer: TranslationManifestParser {
    
    private static let enabledFeatures: [String] = [
        ParserConfigKt.FEATURE_ANIMATION,
        ParserConfigKt.FEATURE_CONTENT_CARD,
        ParserConfigKt.FEATURE_FLOW,
        ParserConfigKt.FEATURE_MULTISELECT
    ]
        
    init(appConfig: AppConfig, resourcesFileCache: ResourcesSHA256FileCache) {
            
        let parserConfig = ParserConfig()
            .withParsePages(enabled: true)
            .withParseTips(enabled: true)
            .withSupportedFeatures(features: Set(ParseTranslationManifestForRenderer.enabledFeatures))
            .withAppVersion(deviceType: .ios, version: appConfig.appVersion)
        
        super.init(
            parserConfig: parserConfig,
            resourcesFileCache: resourcesFileCache
        )
    }
}
