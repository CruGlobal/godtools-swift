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
        
    private static let defaultEnabledFeatures: [String] = [
        ParserConfig.companion.FEATURE_ANIMATION,
        ParserConfig.companion.FEATURE_CONTENT_CARD,
        ParserConfig.companion.FEATURE_FLOW,
        ParserConfig.companion.FEATURE_MULTISELECT
    ]
        
    init(infoPlist: InfoPlist, resourcesFileCache: ResourcesSHA256FileCache, remoteConfigRepository: RemoteConfigRepository) {
            
        let appVersion: String? = infoPlist.appVersion
        
        if appVersion == nil {
            assertionFailure("Failed to get appVersion from plist, should not be null.")
        }
        
        let parserConfig = ParserConfig()
            .withParsePages(enabled: true)
            .withParseTips(enabled: true)
            .withSupportedFeatures(features: Set(Self.getEnabledFeatures(remoteConfigRepository: remoteConfigRepository)))
            .withAppVersion(deviceType: .ios, version: appVersion)
        
        super.init(
            parserConfig: parserConfig,
            resourcesFileCache: resourcesFileCache
        )
    }
    
    private static func getEnabledFeatures(remoteConfigRepository: RemoteConfigRepository) -> [String] {
        
        var features: [String] = Self.defaultEnabledFeatures
        
        let remoteConfigData: RemoteConfigDataModel? = remoteConfigRepository.remoteDatabase.getRemoteConfig()
        
        if let pageCollectionIsEnabled = remoteConfigData?.toolContentFeaturePageCollectionPageEnabled, pageCollectionIsEnabled {
            features.append(ParserConfig.companion.FEATURE_PAGE_COLLECTION)
        }
        
        return features
    }
}
