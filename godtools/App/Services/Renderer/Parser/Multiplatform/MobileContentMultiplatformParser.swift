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
            
            switch manifest.type {
            
            case .tract:
                self.pageModels = manifest.tractPages.map({MultiplatformTractPage(tractPage: $0)})
            
            case .lesson:
                self.pageModels = manifest.lessonPages.map({MultiplatformLessonPage(lessonPage: $0)})
                
            case .article:
                // TODO: I think eventually we can update articles manifest parser to use this. ~Levi
                assertionFailure("Not implemented for articles.")
                self.pageModels = Array()
                
            case .unknown:
                self.pageModels = Array()
                
            default:
                assertionFailure("Found unsupported manifest type.  Ensure all types are supported.")
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
