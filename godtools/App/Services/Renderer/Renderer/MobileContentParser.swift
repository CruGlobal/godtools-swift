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
            
    let manifest: Manifest?
    let manifestResourcesCache: ManifestResourcesCache?
    let pageModels: [Page]
    let errors: [Error]
    
    required init(translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache) {
                        
        let enabledFeatures: [String] = [
            ParserConfigKt.FEATURE_ANIMATION,
            ParserConfigKt.FEATURE_CONTENT_CARD,
            ParserConfigKt.FEATURE_FLOW,
            ParserConfigKt.FEATURE_MULTISELECT
        ]
                        
        ParserConfig().supportedFeatures = Set(enabledFeatures)
        
        let manifestParser = IosManifestParser(parserFactory: MobileContentMultiplatformParserFactory(translationsFileCache: translationsFileCache))
        
        let result = manifestParser.parseManifestBlocking(fileName: translationManifestData.translationZipFile.translationManifestFilename)
        
        var errors: [Error] = Array()
        
        if let resultData = result as? ParserResult.Data {
            
            let manifest: Manifest = resultData.manifest
            
            self.pageModels = manifest.pages
            
            self.manifest = manifest
            self.manifestResourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        }
        else {
            let failedToParseManifest: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Multiplatform failed to parse manifest."])
            errors.append(failedToParseManifest)
            self.manifest = nil
            self.manifestResourcesCache = nil
            self.pageModels = Array()
        }

        self.errors = errors
    }
    
    required init(manifest: Manifest, pageModels: [Page], translationsFileCache: TranslationsFileCache) {
        
        self.manifest = manifest
        self.manifestResourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.pageModels = pageModels
        self.errors = Array()
    }
    
    func getPageModel(page: Int) -> Page? {
        guard page >= 0 && page < pageModels.count else {
            return nil
        }
        return pageModels[page]
    }
    
    func getVisiblePageModels() -> [Page] {
        return pageModels.filter({!$0.isHidden})
    }
    
    func getPageForListenerEvents(eventIds: [EventId]) -> Int? {
                
        for pageIndex in 0 ..< pageModels.count {
            
            let pageModel: Page = pageModels[pageIndex]
            
            for listener in pageModel.listeners {
               
                if eventIds.contains(listener) {
                    return pageIndex
                }
            }
        }
        
        return nil
    }
}

