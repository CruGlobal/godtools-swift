//
//  MobileContentMultiplatformParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentMultiplatformParser: MobileContentParserType {
    
    let manifest: MobileContentManifestType
    let manifestResourcesCache: ManifestResourcesCacheType
    var pageModels: [PageModelType]
    var errors: [Error]
    
    required init(translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache) {
        
        let manifestParser = IosManifestParser(parserFactory: MobileContentMultiplatformParserFactory(translationsFileCache: translationsFileCache))
        
        let result = manifestParser.parseManifestBlocking(fileName: translationManifestData.translationZipFile.translationManifestFilename)
        
        var errors: [Error] = Array()
        
        if let resultData = result as? Result.Data {
            self.manifest = MultiplatformManifest(manifest: resultData.manifest)
        }
        else {
            let failedToParseManifest: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Multiplatform failed to parse manifest."])
            errors.append(failedToParseManifest)
            self.manifest = MockMobileContentManifest()
        }

        self.manifestResourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.pageModels = Array()
        self.errors = errors
    }
    
    required init(manifest: MobileContentManifestType, pageModels: [PageModelType], translationsFileCache: TranslationsFileCache) {
        
        self.manifest = manifest
        self.manifestResourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.pageModels = pageModels
        self.errors = Array()
    }
}
