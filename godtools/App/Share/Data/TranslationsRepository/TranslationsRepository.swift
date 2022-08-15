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
        
    private let api: MobileContentTranslationsApi
    private let cache: RealmTranslationsCache
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    init(api: MobileContentTranslationsApi, cache: RealmTranslationsCache, resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.api = api
        self.cache = cache
        self.resourcesFileCache = resourcesFileCache
    }
    
    func getTranslation(id: String) -> TranslationModel? {
        return cache.getTranslation(id: id)
    }
    
    func getTranslations(ids: [String]) -> [TranslationModel] {
        return cache.getTranslations(ids: ids)
    }
}

// MARK: - Fetching Translation Manifests and Related Files By Manifest Parser Type From Cache

extension TranslationsRepository {
    
    func getTranslationManifestsFromCache(translations: [TranslationModel], manifestParserType: TranslationManifestParserType) -> AnyPublisher<[TranslationManifestFileDataModel], Error> {
       
        let requests = translations.map {
            self.getTranslationManifestFromCache(translation: $0, manifestParserType: manifestParserType)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getTranslationManifestFromCache(translation: TranslationModel, manifestParserType: TranslationManifestParserType) -> AnyPublisher<TranslationManifestFileDataModel, Error> {
        
        let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(type: manifestParserType, resourcesFileCache: resourcesFileCache)
        
        return manifestParser.parse(manifestName: translation.manifestName).publisher
            .flatMap({ manifest -> AnyPublisher<TranslationManifestFileDataModel, Error> in
            
                guard manifestParserType.parsesRelatedFiles else {
                    
                    let manifestWithoutRelatedFiles = TranslationManifestFileDataModel(manifest: manifest, relatedFiles: [], translation: translation)
                    
                    return Just(manifestWithoutRelatedFiles).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                let requests = manifest.relatedFiles.map {
                    self.getTranslationFileFromCache(translation: translation, fileName: $0).publisher
                }
                
                return Publishers.MergeMany(requests)
                    .collect()
                    .map { relatedFiles in
                        
                        return TranslationManifestFileDataModel(manifest: manifest, relatedFiles: relatedFiles, translation: translation)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Fetching Translation Manifests and Related Files By Manifest Parser Type From Remote

extension TranslationsRepository {
    
    func getTranslationManifestsFromRemote(translations: [TranslationModel], manifestParserType: TranslationManifestParserType) -> AnyPublisher<[TranslationManifestFileDataModel], URLResponseError> {
       
        let requests = translations.map {
            self.getTranslationManifestFromRemote(translation: $0, manifestParserType: manifestParserType)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getTranslationManifestFromRemote(translation: TranslationModel, manifestParserType: TranslationManifestParserType) -> AnyPublisher<TranslationManifestFileDataModel, URLResponseError> {
        
        return getTranslationFileFromCacheElseRemote(translation: translation, fileName: translation.manifestName)
            .flatMap({ fileCacheLocation -> AnyPublisher<Manifest, URLResponseError> in
                
                let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(type: manifestParserType, resourcesFileCache: self.resourcesFileCache)
                
                return manifestParser.parse(manifestName: translation.manifestName).publisher
                    .mapError({ error in
                        return  .otherError(error: error)
                    })
                    .eraseToAnyPublisher()
            })
            .flatMap({ manifest -> AnyPublisher<TranslationManifestFileDataModel, URLResponseError> in
                
                guard manifestParserType.parsesRelatedFiles else {
                    
                    let manifestWithoutRelatedFiles = TranslationManifestFileDataModel(manifest: manifest, relatedFiles: [], translation: translation)
                    
                    return Just(manifestWithoutRelatedFiles).setFailureType(to: URLResponseError.self)
                        .eraseToAnyPublisher()
                }
                
                let requests = manifest.relatedFiles.map {
                    self.getTranslationFileFromCacheElseRemote(translation: translation, fileName: $0)
                }
                
                return Publishers.MergeMany(requests)
                    .collect()
                    .map { relatedFiles in
                        
                        return TranslationManifestFileDataModel(manifest: manifest, relatedFiles: relatedFiles, translation: translation)
                    }
                    .eraseToAnyPublisher()
            })
            .catch({ (error: URLResponseError) -> AnyPublisher<TranslationManifestFileDataModel, URLResponseError> in
                
                return self.downloadAndCacheTranslationZipFiles(translation: translation)
                    .flatMap({ translationFilesDataModel -> AnyPublisher<TranslationManifestFileDataModel, URLResponseError> in
                        return self.getTranslationManifestFromCache(translation: translation, manifestParserType: manifestParserType)
                            .mapError({ error in
                                return .otherError(error: error)
                            })
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Downloading and Cacheing Translation Files

extension TranslationsRepository {
    
    func downloadAndCacheTranslationsFiles(translations: [TranslationModel]) -> AnyPublisher<[TranslationFilesDataModel], URLResponseError> {
        
        let requests = translations.map {
            self.downloadAndCacheTranslationFiles(translation: $0)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationFiles(translation: TranslationModel) -> AnyPublisher<TranslationFilesDataModel, URLResponseError> {
        
        return getTranslationFileFromCacheElseRemote(translation: translation, fileName: translation.manifestName)
            .flatMap({ fileCacheLocation -> AnyPublisher<Manifest, URLResponseError> in
                
                let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(type: .related, resourcesFileCache: self.resourcesFileCache)
                
                return manifestParser.parse(manifestName: translation.manifestName).publisher
                    .mapError({ error in
                        return .otherError(error: error)
                    })
                    .eraseToAnyPublisher()
            })
            .flatMap({ manifest -> AnyPublisher<TranslationFilesDataModel, URLResponseError> in
                
                let requests = manifest.relatedFiles.map {
                    self.getTranslationFileFromCacheElseRemote(translation: translation, fileName: $0)
                }
                
                return Publishers.MergeMany(requests)
                    .collect()
                    .map { files in
                        return TranslationFilesDataModel(files: files, translation: translation)
                    }
                    .eraseToAnyPublisher()
            })
            .catch({ (error: URLResponseError) in
                
                return self.downloadAndCacheTranslationZipFiles(translation: translation)
            })
            .eraseToAnyPublisher()
    }
    
    private func getTranslationFileFromCacheElseRemote(translation: TranslationModel, fileName: String) -> AnyPublisher<FileCacheLocation, URLResponseError> {
                        
        return getTranslationFileFromCache(translation: translation, fileName: fileName).publisher
            .catch({ error -> AnyPublisher<FileCacheLocation, URLResponseError> in
                
                return self.getTranslationFileFromRemote(translation: translation, fileName: fileName)
                    .eraseToAnyPublisher()
            })
            .mapError({ error in
                return URLResponseError.otherError(error: error)
            })
            .flatMap({ fileCacheLocation -> AnyPublisher<FileCacheLocation, URLResponseError> in
                
                return Just(fileCacheLocation).setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getTranslationFileFromCache(translation: TranslationModel, fileName: String) -> Result<FileCacheLocation, Error> {
                
        let fileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        switch resourcesFileCache.getFileExists(location: fileCacheLocation) {
            
        case .success(let fileExists):
            if fileExists {
                return .success(fileCacheLocation)
            }
            else {
                return .failure(NSError.errorWithDescription(description: "Failed to get translation file.  File does not exist in the cache."))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func getTranslationFileFromRemote(translation: TranslationModel, fileName: String) -> AnyPublisher<FileCacheLocation, URLResponseError> {
        
        return api.getTranslationFile(fileName: fileName)
            .flatMap({ responseObject -> AnyPublisher<FileCacheLocation, URLResponseError> in
                
                return self.resourcesFileCache.storeTranslationFile(translationId: translation.id, fileName: fileName, fileData: responseObject.data)
                    .mapError { error in
                        return .otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ fileLocation -> AnyPublisher<FileCacheLocation, URLResponseError> in
                
                return Just(fileLocation).setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationZipFiles(translation: TranslationModel) -> AnyPublisher<TranslationFilesDataModel, URLResponseError> {
        
        return api.getTranslationZipFile(translationId: translation.id)
            .flatMap({ responseObject -> AnyPublisher<TranslationFilesDataModel, URLResponseError> in
                
                return self.resourcesFileCache.storeTranslationZipFile(translationId: translation.id, zipFileData: responseObject.data)
                    .mapError { error in
                        return .otherError(error: error)
                    }
                    .map { files in
                        return TranslationFilesDataModel(files: files, translation: translation)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
