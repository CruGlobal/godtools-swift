//
//  MobileContentParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentParser {
                
    private let iOSManifestParser: IosManifestParser
    
    required init(translationsFileCache: TranslationsFileCache) {
                        
        let enabledFeatures: [String] = [
            ParserConfigKt.FEATURE_ANIMATION,
            ParserConfigKt.FEATURE_CONTENT_CARD,
            ParserConfigKt.FEATURE_FLOW,
            ParserConfigKt.FEATURE_MULTISELECT
        ]
                        
        ParserConfig().supportedFeatures = Set(enabledFeatures)
        
        iOSManifestParser = IosManifestParser(parserFactory: MobileContentMultiplatformParserFactory(translationsFileCache: translationsFileCache))
    }
    
    func parse(translationManifestData: TranslationManifestData) -> Result<Manifest, Error> {
        
        let result = iOSManifestParser.parseManifestBlocking(fileName: translationManifestData.translationZipFile.translationManifestFilename)
        
        if let resultData = result as? ParserResult.Data {
            return .success(resultData.manifest)
        }
        else {
            let error: Error = NSError.errorWithDescription(description: "Failed to parse tool manifest.")
            return .failure(error)
        }
    }
}

