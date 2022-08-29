//
//  ParseTranslationManifestForTips.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ParseTranslationManifestForTips: TranslationManifestParser {
    
    init(resourcesFileCache: ResourcesSHA256FileCache, parseRelated: Bool) {
        
        let parserConfig = ParserConfig().withParseRelated(enabled: parseRelated).withParseTips(enabled: true)
        
        super.init(
            parserConfig: parserConfig,
            resourcesFileCache: resourcesFileCache
        )
    }
}
