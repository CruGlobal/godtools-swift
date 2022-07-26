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
            .flatMap({ manifestFileName -> AnyPublisher<(manifestName: String, fileResponses: [DownloadAndCacheTranslationFileResponse]), Error> in
                
                return self.downloadAndCacheTranslationManifestAndRelatedFilesIfNeeded(translationId: translationId)
                    .map { fileResponses in
                        return (manifestFileName, fileResponses)
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ data -> AnyPublisher<TranslationFilesDataModel, Error> in

                let failedResponseHttpStatusCodes: [Int] = data.fileResponses.compactMap({$0.urlResponseObject?.httpStatusCode}).filter({$0 >= 400})
                let failedToDownloadRelatedFile: Bool = failedResponseHttpStatusCodes.count > 0
                
                if !failedToDownloadRelatedFile {
                    
                    let translationFilesDataModel = TranslationFilesDataModel(
                        translationId: translationId,
                        manifestFileName: data.manifestName,
                        fileCacheLocations: data.fileResponses.compactMap({$0.fileCacheLocation})
                    )
                    
                    return Just(translationFilesDataModel).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                else {
                    
                    return self.downloadAndCacheTranslationZipFileFromRemote(translationId: translationId)
                        .map { zipFileResponse in
                            
                            let translationFilesDataModel = TranslationFilesDataModel(
                                translationId: translationId,
                                manifestFileName: data.manifestName,
                                fileCacheLocations: zipFileResponse.fileCacheLocations
                            )
                            
                            return translationFilesDataModel
                        }
                        .eraseToAnyPublisher()
                }
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
    
    private func downloadAndCacheTranslationManifestAndRelatedFilesIfNeeded(translationId: String) -> AnyPublisher<[DownloadAndCacheTranslationFileResponse], Error> {
        
        var downloadAndCacheTranslationFileResponses: [DownloadAndCacheTranslationFileResponse] = Array()
        
        return getTranslationManifestFileName(translationId: translationId)
            .flatMap({ manifestFileName -> AnyPublisher<DownloadAndCacheTranslationFileResponse, Error> in
                
                return self.downloadAndCacheTranslationFileIfNeeded(translationId: translationId, fileName: manifestFileName)
            })
            .flatMap({ getManifestTranslationFileResponse -> AnyPublisher<[ManifestRelatedFileName], Error> in
                       
                downloadAndCacheTranslationFileResponses.append(getManifestTranslationFileResponse)
                
                guard let manifestFileCacheLocation = getManifestTranslationFileResponse.fileCacheLocation else {
                    return Just([]).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                let parser = ParseTranslationManifestForRelatedFiles(resourcesFileCache: self.resourcesFileCache)
                
                return parser.parseManifestForRelatedFilesPublisher(manifestName: manifestFileCacheLocation.relativeUrlString)
            })
            .flatMap({ relatedFileNames -> AnyPublisher<[DownloadAndCacheTranslationFileResponse], Error> in
            
                return Publishers.MergeMany(
                    relatedFileNames.map({
                        self.downloadAndCacheTranslationFileIfNeeded(translationId: translationId, fileName: $0)
                    })
                )
                .collect()
                .eraseToAnyPublisher()
            })
            .flatMap({ getRelatedFileResponses -> AnyPublisher<[DownloadAndCacheTranslationFileResponse], Error> in
                
                downloadAndCacheTranslationFileResponses.append(contentsOf: getRelatedFileResponses)
                
                return Just(downloadAndCacheTranslationFileResponses).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationFileIfNeeded(translationId: String, fileName: String) -> AnyPublisher<DownloadAndCacheTranslationFileResponse, Error> {
        
        let location = FileCacheLocation(relativeUrlString: fileName)
        
        return resourcesFileCache.getData(location: location).publisher
            .flatMap({ cachedFileData -> AnyPublisher<DownloadAndCacheTranslationFileResponse, Error> in
                
                let fileIsCached: Bool = cachedFileData != nil
                
                guard !fileIsCached else {
                    
                    let response = DownloadAndCacheTranslationFileResponse(fileCacheLocation: location, urlResponseObject: nil)
                    
                    return Just(response).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.downloadAndCacheTranslationFileFromRemote(translationId: translationId, fileName: fileName)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationFileFromRemote(translationId: String, fileName: String) -> AnyPublisher<DownloadAndCacheTranslationFileResponse, Error> {
        
        return api.getTranslationFile(fileName: fileName)
            .flatMap({ urlResponseObject -> AnyPublisher<DownloadAndCacheTranslationFileResponse, Error> in
                                    
                let httpStatusSuccess: Bool = urlResponseObject.httpStatusCode == 200
                
                guard httpStatusSuccess else {
                    
                    let response = DownloadAndCacheTranslationFileResponse(fileCacheLocation: nil, urlResponseObject: urlResponseObject)
                    
                    return Just(response).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.resourcesFileCache.storeTranslationFile(
                    translationId: translationId,
                    fileName: fileName,
                    fileData: urlResponseObject.data
                )
                .flatMap({ fileCacheLocation -> AnyPublisher<DownloadAndCacheTranslationFileResponse, Error> in
                    
                    let response = DownloadAndCacheTranslationFileResponse(fileCacheLocation: fileCacheLocation, urlResponseObject: urlResponseObject)
                    
                    return Just(response).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                })
                .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationZipFileFromRemote(translationId: String) -> AnyPublisher<DownloadAndCacheTranslationZipFileResponse, Error> {
        
        return api.getTranslationZipFile(translationId: translationId)
            .flatMap({ urlResponseObject -> AnyPublisher<DownloadAndCacheTranslationZipFileResponse, Error> in
                    
                let httpStatusSuccess: Bool = urlResponseObject.httpStatusCode == 200
                
                guard httpStatusSuccess else {
                    
                    let response = DownloadAndCacheTranslationZipFileResponse(fileCacheLocations: [], urlResponseObject: urlResponseObject)
                    
                    return Just(response).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.resourcesFileCache.storeTranslationZipFile(translationId: translationId, zipFileData: urlResponseObject.data)
                    .map { fileCacheLocations in
                        return DownloadAndCacheTranslationZipFileResponse(fileCacheLocations: fileCacheLocations, urlResponseObject: urlResponseObject)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
