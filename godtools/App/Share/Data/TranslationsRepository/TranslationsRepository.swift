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
    private let mainThreadManifestRendererParser: ParseTranslationManifestForRenderer
    
    init(api: MobileContentTranslationsApi, cache: RealmTranslationsCache, resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.api = api
        self.cache = cache
        self.resourcesFileCache = resourcesFileCache
        self.mainThreadManifestRendererParser = ParseTranslationManifestForRenderer(resourcesFileCache: resourcesFileCache)
    }
    
    func getTranslation(id: String) -> TranslationModel? {
        return cache.getTranslation(id: id)
    }
    
    func getTranslations(ids: [String]) -> [TranslationModel] {
        return cache.getTranslations(ids: ids)
    }
    
    func getTranslationManifestOnMainThread(manifestFileDataModel: TranslationManifestFileDataModel) -> Manifest? {
        
        switch mainThreadManifestRendererParser.parse(manifestName: manifestFileDataModel.translation.manifestName) {
        
        case .success(let manifest):
            return manifest
        
        case .failure( _):
            return nil
        }
    }
        
    func getTranslationManifests(translations: [TranslationModel], manifestParserType: TranslationManifestParserType) -> AnyPublisher<[TranslationManifestFileDataModel], Error> {
       
        let requests = translations.map {
            self.getTranslationManifest(translation: $0, manifestParserType: manifestParserType)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getTranslationManifest(translation: TranslationModel, manifestParserType: TranslationManifestParserType) -> AnyPublisher<TranslationManifestFileDataModel, Error> {
        
        let manifestParser: TranslationManifestParser = self.getManifestParser(manifestParserType: manifestParserType)
        
        return manifestParser.parse(manifestName: translation.manifestName).publisher
            .map { manifest in
                
                return TranslationManifestFileDataModel(manifest: manifest, translation: translation)
            }
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheTranslationsFiles(translations: [TranslationModel]) -> AnyPublisher<[TranslationFilesDataModel], URLResponseError> {
        
        let requests = translations.map {
            self.downloadAndCacheTranslationFiles(translation: $0)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheTranslationFiles(translation: TranslationModel) -> AnyPublisher<TranslationFilesDataModel, URLResponseError> {
        
        return getTranslationManifest(translation: translation, manifestParserType: .relatedFiles)
            .mapError { error in
                return .decodeError(error: error)
            }
            .flatMap({ manifestFile -> AnyPublisher<TranslationFilesDataModel, URLResponseError> in
                
                let requests = manifestFile.manifest.relatedFiles.map {
                    self.downloadAndCacheTranslationFile(translation: translation, fileName: $0)
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
}

extension TranslationsRepository {
    
    private func getManifestParser(manifestParserType: TranslationManifestParserType) -> TranslationManifestParser {
                
        switch manifestParserType {
        case .relatedFiles:
            return ParseTranslationManifestForRelatedFiles(resourcesFileCache: resourcesFileCache)
        case .renderer:
            return ParseTranslationManifestForRenderer(resourcesFileCache: resourcesFileCache)
        }
    }
    
    private func downloadAndCacheTranslationFile(translation: TranslationModel, fileName: String) -> AnyPublisher<FileCacheLocation, URLResponseError> {
        
        return api.getTranslationFile(fileName: fileName)
            .mapError { error in
                return error as URLResponseError
            }
            .flatMap({ responseObject -> AnyPublisher<FileCacheLocation, Error> in
                    
                return self.resourcesFileCache.storeTranslationFile(translationId: translation.id, fileName: fileName, fileData: responseObject.data)
            })
            .mapError { error in
                return .otherError(error: error)
            }
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
