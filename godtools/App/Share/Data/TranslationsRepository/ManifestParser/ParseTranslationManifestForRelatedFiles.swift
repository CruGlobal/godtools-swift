//
//  ParseTranslationManifestForRelatedFiles.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import Combine

class ParseTranslationManifestForRelatedFiles: TranslationManifestParser {
    
    init(resourcesFileCache: ResourcesSHA256FileCache) {
    
        super.init(
            parserConfig: ParserConfig().withParseRelated(enabled: false),
            resourcesFileCache: resourcesFileCache
        )
    }
}
