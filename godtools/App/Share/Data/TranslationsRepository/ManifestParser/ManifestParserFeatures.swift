//
//  ManifestParserFeatures.swift
//  godtools
//
//  Created by Levi Eggert on 7/31/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

final class ManifestParserFeatures: Sendable {
    
    private let remoteConfigRepository: RemoteConfigRepository
    
    init(remoteConfigRepository: RemoteConfigRepository) {
        
        self.remoteConfigRepository = remoteConfigRepository
    }
    
    func getSupportedFeatures() async -> Set<String> {
        
        let defaultFeatures: [String] = [
            ParserConfig.companion.FEATURE_ANIMATION,
            ParserConfig.companion.FEATURE_CONTENT_CARD,
            ParserConfig.companion.FEATURE_FLOW,
            ParserConfig.companion.FEATURE_MULTISELECT
        ]
        
        var optionalFeatures: [String] = Array()
        
        let remoteConfigData: RemoteConfigDataModel? = await remoteConfigRepository.getRemoteConfig()
        
        if let pageCollectionIsEnabled = remoteConfigData?.toolContentFeaturePageCollectionPageEnabled, pageCollectionIsEnabled {
            optionalFeatures.append(ParserConfig.companion.FEATURE_PAGE_COLLECTION)
        }
        
        return Set(defaultFeatures + optionalFeatures)
    }
}
