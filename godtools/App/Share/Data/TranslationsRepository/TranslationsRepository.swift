//
//  TranslationsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser
import RequestOperation

class TranslationsRepository {
    
    typealias ManifestRelatedFileName = String
    
    private let api: MobileContentTranslationsApi
    private let cache: RealmTranslationsCache
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let fallsBackToZipFileDownloading: Bool = true // TODO: This will eventually be removed. ~Levi
    
    init(api: MobileContentTranslationsApi, cache: RealmTranslationsCache, resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.api = api
        self.cache = cache
        self.resourcesFileCache = resourcesFileCache
    }
    
    func downloadAnCacheTranslationFiles(translationIds: [String]) -> AnyPublisher<[TranslationFilesDataModel], Error> {
                
        let requests = translationIds.map {
            self.downloadAndCacheTranslationFiles(translationId: $0)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
}

extension TranslationsRepository {
    
    private func downloadAndCacheTranslationFiles(translationId: String) -> AnyPublisher<TranslationFilesDataModel, Error> {
        
        return getTranslationManifestFileName(translationId: translationId)
            .flatMap({ manifestFileName -> AnyPublisher<TranslationFilesDataModel, Error> in
                
                return self.downloadAndCacheTranslationManifestAndRelatedFilesIfNeeded(translationId: translationId)
                    .map {
                        
                        return TranslationFilesDataModel(
                            translationId: translationId,
                            manifestFileName: manifestFileName,
                            fileCacheLocations: $0
                        )
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getTranslationManifestFileName(translationId: String) -> AnyPublisher<String, Error> {
        
        guard let translation = cache.getTranslation(id: translationId) else {
            
            let errorDescription: String = "Failed to fetch manifest with translationId: \(translationId) because a translation object is not persisted in the realm database."
            
            return Fail(error: NSError.errorWithDescription(description: errorDescription))
                .eraseToAnyPublisher()
        }
        
        return Just(translation.manifestName).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func getTranslationManifestFromCacheElseRemote(translationId: String) -> AnyPublisher<Data?, Error> {
        
        return getTranslationManifestFileName(translationId: translationId)
            .flatMap {
                self.getTranslationManifestFromCacheElseRemote(manifestName: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func getTranslationManifestFromCacheElseRemote(manifestName: String) -> AnyPublisher<Data?, Error> {
        
        return resourcesFileCache.getTranslationManifest(manifestName: manifestName)
            .flatMap ({ data -> AnyPublisher<Data?, Error> in
                if let data = data {
                    return Just(data).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                else {
                    return self.api.getTranslationFile(fileName: manifestName)
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationManifestAndRelatedFilesIfNeeded(translationId: String) -> AnyPublisher<[FileCacheLocation], Error> {
        
        var fileCacheLocations: [FileCacheLocation] = Array()
        
        return getTranslationManifestFileName(translationId: translationId)
            .flatMap({ manifestFileName -> AnyPublisher<FileCacheLocation, Error> in
                
                return self.downloadAndCacheTranslationFileIfNeeded(translationId: translationId, fileName: manifestFileName)
            })
            .flatMap({ manifestFileCacheLocation -> AnyPublisher<[ManifestRelatedFileName], Error> in
                           
                fileCacheLocations.append(manifestFileCacheLocation)
                
                let parser = TranslationFileManifestParser(resourcesFileCache: self.resourcesFileCache)
                
                return parser.parseManifestRelatedFilesPublisher(manifestName: manifestFileCacheLocation.relativeUrlString)
            })
            .flatMap({ relatedFileNames -> AnyPublisher<[FileCacheLocation], Error> in
                
                return Publishers.MergeMany(
                    relatedFileNames.map({
                        self.downloadAndCacheTranslationFileIfNeeded(translationId: translationId, fileName: $0)
                    })
                )
                .collect()
                .eraseToAnyPublisher()
            })
            .flatMap({ relatedFileCacheLocations -> AnyPublisher<[FileCacheLocation], Error> in
                
                fileCacheLocations.append(contentsOf: relatedFileCacheLocations)
                
                return Just(fileCacheLocations).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationFileIfNeeded(translationId: String, fileName: String) -> AnyPublisher<FileCacheLocation, Error> {
        
        let location = FileCacheLocation(relativeUrlString: fileName)
        
        return resourcesFileCache.getDataPublisher(location: location)
            .flatMap({ data -> AnyPublisher<FileCacheLocation, Error> in
                
                let fileIsCached: Bool = data != nil
                
                guard !fileIsCached else {
                    return Just(location).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.api.getTranslationFile(fileName: fileName)
                    .flatMap({ data -> AnyPublisher<FileCacheLocation, Error> in
                        
                        guard let data = data else {
                            let error = NSError.errorWithDescription(description: "Failed to fetch file data from remote.")
                            return Fail(error: error)
                                .eraseToAnyPublisher()
                        }
                        
                        return self.resourcesFileCache.storeTranslationFile(
                            translationId: translationId,
                            fileName: fileName,
                            fileData: data
                        )
                    })
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationZipFileIfNeeded(translationId: String) {
        
    }
}
