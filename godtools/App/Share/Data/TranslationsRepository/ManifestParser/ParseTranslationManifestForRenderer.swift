//
//  ParseTranslationManifestForRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import Combine

class ParseTranslationManifestForRenderer: TranslationManifestParser {
         
    init(infoPlist: InfoPlist, resourcesFileCache: ResourcesSHA256FileCache, remoteConfigRepository: RemoteConfigRepository) {
            
        let appVersion: String? = infoPlist.appVersion
        
        if appVersion == nil {
            assertionFailure("Failed to get appVersion from plist, should not be null.")
        }
        
        let parserConfig = ParserConfig()
            .withParsePages(enabled: true)
            .withParseTips(enabled: true)
            .withSupportedFeatures(features: Set(Self.getSupportedFeatures(remoteConfigRepository: remoteConfigRepository)))
            .withAppVersion(deviceType: .ios, version: appVersion)
        
        super.init(
            parserConfig: parserConfig,
            resourcesFileCache: resourcesFileCache
        )
    }
    
    private static func getSupportedFeatures(remoteConfigRepository: RemoteConfigRepository) -> [String] {
        
        let defaultFeatures: [String] = [
            ParserConfig.companion.FEATURE_ANIMATION,
            ParserConfig.companion.FEATURE_CONTENT_CARD,
            ParserConfig.companion.FEATURE_FLOW,
            ParserConfig.companion.FEATURE_MULTISELECT
        ]
        
        var optionalFeatures: [String] = Array()
        
        let remoteConfigData: RemoteConfigDataModel? = remoteConfigRepository.getRemoteConfig()
        
        if let pageCollectionIsEnabled = remoteConfigData?.toolContentFeaturePageCollectionPageEnabled, pageCollectionIsEnabled {
            optionalFeatures.append(ParserConfig.companion.FEATURE_PAGE_COLLECTION)
        }
        
        return defaultFeatures + optionalFeatures
    }
}
