//
//  TranslationManifestParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class TranslationManifestParser {
    
    private let parser: ManifestParser
    private let parserConfig: ParserConfig
    private let resourcesFileCache: ResourcesFileCache
    
    static func getManifestParser(
        type: TranslationManifestParserType,
        infoPlist: InfoPlistInterface,
        resourcesFileCache: ResourcesFileCache,
        manifestParserFeatures: ManifestParserFeatures
    ) async -> TranslationManifestParser {
        
        switch type {
                
        case .manifestOnly:
            let parserConfig = ParserConfig().withParseRelated(enabled: false)
            return TranslationManifestParser(parserConfig: parserConfig, resourcesFileCache: resourcesFileCache)
        
        case .renderer:
            let features: Set<String> = await manifestParserFeatures.getSupportedFeatures()
            
            return ParseTranslationManifestForRenderer(
                infoPlist: infoPlist,
                resourcesFileCache: resourcesFileCache,
                features: features
            )
        }
    }
    
    init(parserConfig: ParserConfig, resourcesFileCache: ResourcesFileCache) {
        
        self.parser = ManifestParser(
            parserFactory: TranslationManifestParserFactory(resourcesFileCache: resourcesFileCache),
            defaultConfig: parserConfig
        )
        
        self.parserConfig = parserConfig
        self.resourcesFileCache = resourcesFileCache
    }
    
    func parse(manifestName: String) async throws -> Manifest {
        
        let location: FileCacheLocation = FileCacheLocation(relativeUrlString: manifestName)
        
        let exists = try await resourcesFileCache.cache.getFileExists(location: location)
        
        guard exists else {
            throw NSError.errorWithDescription(description: "Could not find translation manifest file in file cache.")
        }
        
        let parserResult: ParserResult = try await parser.parseManifest(fileName: manifestName, config: parserConfig)
        
        guard let resultData = parserResult as? ParserResult.Data else {
            throw NSError.errorWithDescription(description: "Failed to parse tool manifest.")
        }
        
        return resultData.manifest
    }
}
