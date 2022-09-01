//
//  TranslationManifestParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class TranslationManifestParser {
    
    private let parser: IosManifestParser
    private let parserConfig: ParserConfig
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    static func getManifestParser(type: TranslationManifestParserType, resourcesFileCache: ResourcesSHA256FileCache) -> TranslationManifestParser {
        
        switch type {
        
        case .downloadManifestAndRelatedFiles:
            return ParseTranslationManifestForRelatedFiles(resourcesFileCache: resourcesFileCache)
        
        case .downloadManifestOnly:
            return TranslationManifestParser(parserConfig: ParserConfig().withParseRelated(enabled: false), resourcesFileCache: resourcesFileCache)
        
        case .renderer:
            return ParseTranslationManifestForRenderer(resourcesFileCache: resourcesFileCache)
        }
    }
    
    init(parserConfig: ParserConfig, resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.parser = IosManifestParser(
            parserFactory: TranslationManifestParserFactory(resourcesFileCache: resourcesFileCache),
            defaultConfig: parserConfig
        )
        
        self.parserConfig = parserConfig
        self.resourcesFileCache = resourcesFileCache
    }
    
    func parse(manifestName: String) -> Result<Manifest, Error> {
                
        let location: FileCacheLocation = FileCacheLocation(relativeUrlString: manifestName)
        
        switch resourcesFileCache.getData(location: location) {
        case .success(let data):
            print("data: \(data)")
        case .failure(let error):
            print(error)
        }
        
        switch resourcesFileCache.getFileExists(location: location) {
        
        case .success(let fileExists):
            
            guard fileExists else {
                return .failure(NSError.errorWithDescription(description: "Could not find translation manifest file in file cache."))
            }
            
        case .failure(let error):
            return .failure(error)
        }
        
        let result: ParserResult = self.parser.parseManifestBlocking(fileName: manifestName, config: self.parserConfig)
        
        if let resultData = result as? ParserResult.Data {
            return .success(resultData.manifest)
        }
        else if let resultError = result as? ParserResult.Error, let kotlinException = resultError.error {
            return .failure(NSError.errorWithDescription(description: "Failed to parse tool manifest, found kotlin exception \(kotlinException)"))
        }
        else {
            return .failure(NSError.errorWithDescription(description: "Failed to parse tool manifest."))
        }
    }
}
