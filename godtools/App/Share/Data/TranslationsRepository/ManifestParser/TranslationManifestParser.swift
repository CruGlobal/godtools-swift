//
//  TranslationManifestParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import Combine

class TranslationManifestParser {
    
    private let parser: IosManifestParser
    private let parserConfig: ParserConfig
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    init(parserConfig: ParserConfig, resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.parser = IosManifestParser(
            parserFactory: TranslationManifestParserFactory(resourcesFileCache: resourcesFileCache),
            defaultConfig: parserConfig
        )
        
        self.parserConfig = parserConfig
        self.resourcesFileCache = resourcesFileCache
    }
    
    func parse(manifestName: String) -> AnyPublisher<Manifest, Error> {
                
        switch resourcesFileCache.getFileExists(location: FileCacheLocation(relativeUrlString: manifestName)) {
        
        case .success(let fileExists):
            
            guard fileExists else {
                return Fail(error: NSError.errorWithDescription(description: "Could not find translation manifest file in file cache."))
                    .eraseToAnyPublisher()
            }
            
        case .failure(let error):
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let result: ParserResult = self.parser.parseManifestBlocking(fileName: manifestName, config: self.parserConfig)
        
        if let resultData = result as? ParserResult.Data {
            
            return Just(resultData.manifest).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to parse tool manifest.")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
