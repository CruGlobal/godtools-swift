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

class ParseTranslationManifestForRelatedFiles {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let parser: IosManifestParser
    
    init(resourcesFileCache: ResourcesSHA256FileCache) {
              
        self.resourcesFileCache = resourcesFileCache
        self.parser = IosManifestParser(
            parserFactory: TranslationFileManifestParserFactory(resourcesFileCache: resourcesFileCache),
            defaultConfig: ParserConfig(supportedFeatures: [], supportedDeviceTypes: [], parsePages: false, parseTips: false)
        )
    }
    
    func parseManifestForRelatedFiles(manifestName: String) -> Result<[String], Error> {
        
        switch resourcesFileCache.getFileExists(location: FileCacheLocation(relativeUrlString: manifestName)) {
        
        case .success(let fileExists):
            
            guard fileExists else {
                let error: Error = NSError.errorWithDescription(description: "Failed to parse manifest because manifest does not exist in the resources file cache.")
                return .failure(error)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    
        guard let resultData = parser.parseManifestBlocking(fileName: manifestName) as? ParserResult.Data else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to parse tool manifest.")
            return .failure(error)
        }
        
        let manifest: Manifest = resultData.manifest
        
        return .success(Array(manifest.relatedFiles))
    }
    
    func parseManifestForRelatedFilesPublisher(manifestName: String) -> AnyPublisher<[String], Error> {
        
        switch parseManifestForRelatedFiles(manifestName: manifestName) {
        
        case .success(let relatedFiles):
            return Just(relatedFiles).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
