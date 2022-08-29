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
        
    init(resourcesFileCache: ResourcesSHA256FileCache) {
    
        super.init(
            parserConfig: ParserConfig().withSupportedFeatures(features: Set(ParseTranslationManifestForRenderer.enabledFeatures)),
            resourcesFileCache: resourcesFileCache
        )
    }
}
