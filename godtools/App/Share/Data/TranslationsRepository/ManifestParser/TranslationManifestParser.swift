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
    
    private let parser: ManifestParser
    private let parserConfig: ParserConfig
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    static func getManifestParser(type: TranslationManifestParserType, infoPlist: InfoPlist, resourcesFileCache: ResourcesSHA256FileCache) -> TranslationManifestParser {
        
        switch type {
                
        case .manifestOnly:
            let parserConfig = ParserConfig().withParseRelated(enabled: false)
            return TranslationManifestParser(parserConfig: parserConfig, resourcesFileCache: resourcesFileCache)
        
        case .renderer:
            return ParseTranslationManifestForRenderer(infoPlist: infoPlist, resourcesFileCache: resourcesFileCache)
        }
    }
    
    init(parserConfig: ParserConfig, resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.parser = ManifestParser(
            parserFactory: TranslationManifestParserFactory(resourcesFileCache: resourcesFileCache),
            defaultConfig: parserConfig
        )
        
        self.parserConfig = parserConfig
        self.resourcesFileCache = resourcesFileCache
    }
    
    func parsePublisher(manifestName: String) -> AnyPublisher<Manifest, Error> {
        
        return Future() { promise in

            self.parseAsync(manifestName: manifestName) { (result: Result<Manifest, Error>) in
                
                switch result {
                    
                case .success(let manifest):
                    promise(.success(manifest))
                    
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func parseAsync(manifestName: String, completion: @escaping ((_ result: Result<Manifest, Error>) -> Void)) {
        
        let location: FileCacheLocation = FileCacheLocation(relativeUrlString: manifestName)
        
        switch resourcesFileCache.getFileExists(location: location) {
        
        case .success(let fileExists):
            
            guard fileExists else {
                completion(.failure(NSError.errorWithDescription(description: "Could not find translation manifest file in file cache.")))
                return
            }
            
        case .failure(let error):
            completion(.failure(error))
            return
        }
        
        DispatchQueue.main.async {
            
            self.parser.parseManifest(fileName: manifestName, config: self.parserConfig) { (parserResult: ParserResult?, error: Error?) in
                    
                if let resultData = parserResult as? ParserResult.Data {
                    completion(.success(resultData.manifest))
                }
                else if let resultError = parserResult as? ParserResult.Error, let kotlinException = resultError.error {
                    completion(.failure(NSError.errorWithDescription(description: "Failed to parse tool manifest, found kotlin exception \(kotlinException)")))
                }
                else {
                    completion(.failure(NSError.errorWithDescription(description: "Failed to parse tool manifest.")))
                }
            }
        }
    }
}
