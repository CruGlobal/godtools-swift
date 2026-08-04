//
//  ParseTranslationManifestForRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

final class ParseTranslationManifestForRenderer: TranslationManifestParser {
                 
    init(
        infoPlist: InfoPlistInterface,
        resourcesFileCache: ResourcesFileCache,
        features: Set<String>
    ) {
            
        let appVersion: String? = infoPlist.appVersion
        
        if appVersion == nil {
            assertionFailure("Failed to get appVersion from plist, should not be null.")
        }
        
        let parserConfig = ParserConfig()
            .withParsePages(enabled: true)
            .withParseTips(enabled: true)
            .withSupportedFeatures(features: features)
            .withAppVersion(deviceType: .ios, version: appVersion)
        
        super.init(
            parserConfig: parserConfig,
            resourcesFileCache: resourcesFileCache
        )
    }
}
