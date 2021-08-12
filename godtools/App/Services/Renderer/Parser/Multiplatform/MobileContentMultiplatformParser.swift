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
    let pageModels: [PageModelType]
    let errors: [Error]
    
    required init(translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache) {
        
        let manifestParser = IosManifestParser(parserFactory: MobileContentMultiplatformParserFactory(translationsFileCache: translationsFileCache))
        
        let result = manifestParser.parseManifestBlocking(fileName: translationManifestData.translationZipFile.translationManifestFilename)
        
        var errors: [Error] = Array()
        
        if let resultData = result as? Result.Data {
            
            let manifest: Manifest = resultData.manifest
            
            self.manifest = MultiplatformManifest(manifest: manifest)
            
            if manifest.tractPages.count > 0 {
                
                self.pageModels = manifest.tractPages.map({MultiplatformTractPage(tractPage: $0)})
            }
            else if manifest.lessonPages.count > 0 {
                // TODO: Initialize with lesson pages. ~Levi
                self.pageModels = Array()
            }
            else {
                assertionFailure("Failed to parse multiplatform manifest.  Didn't find any tract or lesson pages.")
                self.pageModels = Array()
            }
        }
        else {
            let failedToParseManifest: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Multiplatform failed to parse manifest."])
            errors.append(failedToParseManifest)
            self.manifest = MockMobileContentManifest()
            self.pageModels = Array()
        }

        self.manifestResourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.errors = errors
    }
    
    required init(manifest: MobileContentManifestType, pageModels: [PageModelType], translationsFileCache: TranslationsFileCache) {
        
        self.manifest = manifest
        self.manifestResourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.pageModels = pageModels
        self.errors = Array()
    }
}
