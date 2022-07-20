//
//  TranslationFileManifestParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import Combine

class TranslationFileManifestParser {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let iOSManifestParser: IosManifestParser
    
    init(resourcesFileCache: ResourcesSHA256FileCache) {
              
        self.resourcesFileCache = resourcesFileCache
        
        let parserFactory = TranslationFileManifestParserFactory(resourcesFileCache: resourcesFileCache)
                
        iOSManifestParser = IosManifestParser(
            parserFactory: parserFactory,
            defaultConfig: ParserConfig(supportedFeatures: [], supportedDeviceTypes: [], parsePages: false, parseTips: false)
        )
    }
    
    func parseManifest(manifestName: String) -> Result<Manifest, Error> {
        
        switch resourcesFileCache.getFileExists(location: FileCacheLocation(relativeUrlString: manifestName)) {
        case .success(let fileExists):
            guard fileExists else {
                let error: Error = NSError.errorWithDescription(description: "Failed to parse manifest because manifest does not exist in the resources file cache.")
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
        
        let result = iOSManifestParser.parseManifestBlocking(fileName: manifestName)
        
        if let resultData = result as? ParserResult.Data {
            return .success(resultData.manifest)
        }
        else {
            let error: Error = NSError.errorWithDescription(description: "Failed to parse tool manifest.")
            return .failure(error)
        }
    }
    
    func parseManifestPublisher(manifestName: String) -> AnyPublisher<Manifest, Error> {
        
        switch parseManifest(manifestName: manifestName) {
        case .success(let manifest):
            return Just(manifest).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func parseManifestRelatedFilesPublisher(manifestName: String) -> AnyPublisher<[String], Error> {
        
        return parseManifestPublisher(manifestName: manifestName)
            .map {
                return Array($0.relatedFiles)
            }
            .eraseToAnyPublisher()
    }
}
