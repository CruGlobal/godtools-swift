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

class TranslationsRepository: RepositorySync<TranslationDataModel, MobileContentTranslationsApi, RealmTranslation> {
        
    private let infoPlist: InfoPlist
    private let api: MobileContentTranslationsApi
    private let cache: RealmTranslationsCache
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
    private let remoteConfigRepository: RemoteConfigRepository
    
    init(infoPlist: InfoPlist, api: MobileContentTranslationsApi, realmDatabase: RealmDatabase, cache: RealmTranslationsCache, resourcesFileCache: ResourcesSHA256FileCache, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository, remoteConfigRepository: RemoteConfigRepository) {
        
        self.infoPlist = infoPlist
        self.api = api
        self.cache = cache
        self.resourcesFileCache = resourcesFileCache
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
        self.remoteConfigRepository = remoteConfigRepository
        
        super.init(
            externalDataFetch: api,
            realmDatabase: realmDatabase,
            dataModelMapping: TranslationsDataModelMapping()
        )
    }
}

// MARK: - Cache

extension TranslationsRepository {
    
    func getCachedLatestTranslation(resourceId: String, languageId: String) -> TranslationDataModel? {
        return cache.getTranslationsSortedByLatestVersion(resourceId: resourceId, languageId: languageId).first
    }
    
    func getCachedLatestTranslation(resourceId: String, languageCode: BCP47LanguageIdentifier) -> TranslationDataModel? {
        return cache.getTranslationsSortedByLatestVersion(resourceId: resourceId, languageCode: languageCode).first
    }
}

// MARK: - Fetching Translation Manifests and Related Files By Manifest Parser Type From Cache

extension TranslationsRepository {
    
    func getTranslationManifestsFromCache(translations: [TranslationDataModel], manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool) -> AnyPublisher<[TranslationManifestFileDataModel], Error> {
       
        let requests = translations.map {
            self.getTranslationManifestFromCache(translation: $0, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getTranslationManifestFromCache(translation: TranslationDataModel, manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool) -> AnyPublisher<TranslationManifestFileDataModel, Error> {
        
        let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(
            type: manifestParserType,
            infoPlist: infoPlist,
            resourcesFileCache: resourcesFileCache,
            remoteConfigRepository: remoteConfigRepository
        )
        
        return manifestParser.parsePublisher(manifestName: translation.manifestName)
            .flatMap({ manifest -> AnyPublisher<TranslationManifestFileDataModel, Error> in
            
                guard includeRelatedFiles else {
                    
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
    
    func getTranslationManifestFromCacheElseRemote(translation: TranslationDataModel, manifestParserType: TranslationManifestParserType, requestPriority: RequestPriority, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) -> AnyPublisher<TranslationManifestFileDataModel, Error> {
        
        return getTranslationManifestFromCache(translation: translation, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
            .catch({ (error: Error) -> AnyPublisher<TranslationManifestFileDataModel, Error> in
                
                return self.getTranslationManifestFromRemote(
                    translation: translation,
                    manifestParserType: manifestParserType,
                    requestPriority: requestPriority,
                    includeRelatedFiles: includeRelatedFiles,
                    shouldFallbackToLatestDownloadedTranslationIfRemoteFails: shouldFallbackToLatestDownloadedTranslationIfRemoteFails
                )
                .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Fetching Translation Manifests and Related Files By Manifest Parser Type From Remote

extension TranslationsRepository {
    
    func getTranslationManifestsFromRemoteWithProgress(translations: [TranslationDataModel], manifestParserType: TranslationManifestParserType, requestPriority: RequestPriority, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) -> AnyPublisher<TranslationsDownloadProgressDataModel, Error> {
        
        let requests = translations.map {
            
            self.getTranslationManifestFromRemote(
                translation: $0,
                manifestParserType: manifestParserType,
                requestPriority: requestPriority,
                includeRelatedFiles: includeRelatedFiles,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: shouldFallbackToLatestDownloadedTranslationIfRemoteFails
            )
        }
        
        var downloadCount: Double = 0
        let numberOfTranslationsToDownload: Int = translations.count
        let numberOfTranslationsToDownloadDouble: Double = Double(numberOfTranslationsToDownload)
        
        return Publishers.MergeMany(requests)
            .map { (dataModel: TranslationManifestFileDataModel) in
                
                downloadCount += 1
                
                let progress: Double = downloadCount / numberOfTranslationsToDownloadDouble
                
                return TranslationsDownloadProgressDataModel(
                    progress: progress,
                    numberOfTranslationsToDownload: numberOfTranslationsToDownload,
                    currentNumberOfTranslationsDownloaded: Int(downloadCount)
                )
            }
            .eraseToAnyPublisher()
    }
    
    func getTranslationManifestsFromRemote(translations: [TranslationDataModel], manifestParserType: TranslationManifestParserType, requestPriority: RequestPriority, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) -> AnyPublisher<[TranslationManifestFileDataModel], Error> {
       
        let requests: [AnyPublisher<TranslationManifestFileDataModel, Error>] = translations.map {
            
            self.getTranslationManifestFromRemote(
                translation: $0,
                manifestParserType: manifestParserType,
                requestPriority: requestPriority,
                includeRelatedFiles: includeRelatedFiles,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: shouldFallbackToLatestDownloadedTranslationIfRemoteFails
            )
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .map({ (downloadedTranslationManifestFileDataModels: [TranslationManifestFileDataModel]) in
                
                var maintainTranslationDownloadOrder: [TranslationManifestFileDataModel] = Array()
                
                for translation in translations {
                    
                    let translationManifest: TranslationManifestFileDataModel?
                    
                    if let downloadedTranslationManifest = downloadedTranslationManifestFileDataModels.first(where: {$0.translation.id == translation.id}) {
                        translationManifest = downloadedTranslationManifest
                    }
                    else if let downloadedTranslationManifest = downloadedTranslationManifestFileDataModels.first(where: {$0.translation.resourceDataModel?.id == translation.resourceDataModel?.id && $0.translation.languageDataModel?.id == translation.languageDataModel?.id}) {
                        translationManifest = downloadedTranslationManifest
                    }
                    else {
                        translationManifest = nil
                    }
                    
                    guard let translationManifest = translationManifest else {
                        continue
                    }
                    
                    maintainTranslationDownloadOrder.append(translationManifest)
                }
                
                return maintainTranslationDownloadOrder
            })
            .eraseToAnyPublisher()
    }
    
    func getTranslationManifestFromRemote(translation: TranslationDataModel, manifestParserType: TranslationManifestParserType, requestPriority: RequestPriority, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) -> AnyPublisher<TranslationManifestFileDataModel, Error> {
        
        return getTranslationFileFromCacheElseRemote(translation: translation, fileName: translation.manifestName, requestPriority: requestPriority)
            .flatMap({ fileCacheLocation -> AnyPublisher<Manifest, Error> in
                
                let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(
                    type: manifestParserType,
                    infoPlist: self.infoPlist,
                    resourcesFileCache: self.resourcesFileCache,
                    remoteConfigRepository: self.remoteConfigRepository
                )
                
                return manifestParser.parsePublisher(manifestName: translation.manifestName)
                    .eraseToAnyPublisher()
            })
            .flatMap({ manifest -> AnyPublisher<TranslationManifestFileDataModel, Error> in
                
                guard includeRelatedFiles else {
                    
                    let manifestWithoutRelatedFiles = TranslationManifestFileDataModel(manifest: manifest, relatedFiles: [], translation: translation)
                    
                    return Just(manifestWithoutRelatedFiles).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                let requests = manifest.relatedFiles.map {
                    self.getTranslationFileFromCacheElseRemote(translation: translation, fileName: $0, requestPriority: requestPriority)
                }
                
                return Publishers.MergeMany(requests)
                    .collect()
                    .map { relatedFiles in
                        
                        return TranslationManifestFileDataModel(manifest: manifest, relatedFiles: relatedFiles, translation: translation)
                    }
                    .eraseToAnyPublisher()
            })
            .catch({ (error: Error) -> AnyPublisher<TranslationManifestFileDataModel, Error> in
                                     
                guard !error.isUrlErrorCancelledCode else {
                    
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
                
                let shouldFallbackToLatestDownloadedTranslation: Bool = includeRelatedFiles && shouldFallbackToLatestDownloadedTranslationIfRemoteFails
                
                let latestDownloadedTranslation: TranslationDataModel?
                
                if shouldFallbackToLatestDownloadedTranslation, let resourceId = translation.resourceDataModel?.id, let languageId = translation.languageDataModel?.id, let latestTrackedDownloadedTranslation = self.trackDownloadedTranslationsRepository.getLatestDownloadedTranslation(resourceId: resourceId, languageId: languageId) {
                    
                    latestDownloadedTranslation = self.getCachedObject(id: latestTrackedDownloadedTranslation.translationId)
                }
                else {
                    latestDownloadedTranslation = nil
                }
                
                if !error.isUrlErrorNotConnectedToInternetCode {
                    
                    return self.downloadAndCacheTranslationZipFiles(translation: translation, requestPriority: requestPriority)
                        .flatMap({ translationFilesDataModel -> AnyPublisher<TranslationManifestFileDataModel, Error> in
                            
                            return self.getTranslationManifestFromCache(translation: translation, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
                                .eraseToAnyPublisher()
                        })
                        .catch({ (error: Error) -> AnyPublisher<TranslationManifestFileDataModel, Error> in
                            
                            if let latestDownloadedTranslation = latestDownloadedTranslation {
                             
                                return self.getTranslationManifestFromCache(
                                    translation: latestDownloadedTranslation,
                                    manifestParserType: manifestParserType,
                                    includeRelatedFiles: includeRelatedFiles
                                )
                                .eraseToAnyPublisher()
                            }
                            
                            return Fail(error: error)
                                .eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                }
                else if let latestDownloadedTranslation = latestDownloadedTranslation {
                 
                    return self.getTranslationManifestFromCache(
                        translation: latestDownloadedTranslation,
                        manifestParserType: manifestParserType,
                        includeRelatedFiles: includeRelatedFiles
                    )
                    .eraseToAnyPublisher()
                }
                
                return Fail(error: error)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Downloading and Cacheing Translation Files

extension TranslationsRepository {
    
    func downloadAndCacheFilesForTranslations(translations: [TranslationDataModel], requestPriority: RequestPriority) -> AnyPublisher<[TranslationFilesDataModel], Error> {
        
        let requests = translations.map {
            self.downloadAndCacheTranslationFiles(translation: $0, requestPriority: requestPriority)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheFilesForTranslationsIgnoringError(translations: [TranslationDataModel], requestPriority: RequestPriority) -> AnyPublisher<[TranslationFilesDataModel], Never> {
        
        let requests = translations.map { (translation: TranslationDataModel) in
            self.downloadAndCacheTranslationFiles(translation: translation, requestPriority: requestPriority)
                .catch({ (error: Error) in
                    return Just(TranslationFilesDataModel(files: [], translation: translation))
                        .eraseToAnyPublisher()
                })
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheTranslationFiles(translation: TranslationDataModel, requestPriority: RequestPriority) -> AnyPublisher<TranslationFilesDataModel, Error> {
        
        return getTranslationFileFromCacheElseRemote(translation: translation, fileName: translation.manifestName, requestPriority: requestPriority)
            .flatMap({ (fileCacheLocation: FileCacheLocation) -> AnyPublisher<Manifest, Error> in
                
                let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(
                    type: .manifestOnly,
                    infoPlist: self.infoPlist,
                    resourcesFileCache: self.resourcesFileCache,
                    remoteConfigRepository: self.remoteConfigRepository
                )
                
                return manifestParser.parsePublisher(manifestName: translation.manifestName)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (manifest: Manifest) -> AnyPublisher<TranslationFilesDataModel, Error> in
                
                let requestsForRelatedFiles = manifest.relatedFiles.map {
                    self.getTranslationFileFromCacheElseRemote(translation: translation, fileName: $0, requestPriority: requestPriority)
                }
                
                return Publishers.MergeMany(requestsForRelatedFiles)
                    .collect()
                    .flatMap({ (files: [FileCacheLocation]) -> AnyPublisher<TranslationFilesDataModel, Error> in
                        
                        return self.didDownloadTranslationAndRelatedFiles(translation: translation, files: files)
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            })
            .catch({ (error: Error) in
                
                if !error.isUrlErrorNotConnectedToInternetCode {
                    return self.downloadAndCacheTranslationZipFiles(translation: translation, requestPriority: requestPriority)
                }
                else {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func getTranslationFileFromCacheElseRemote(translation: TranslationDataModel, fileName: String, requestPriority: RequestPriority) -> AnyPublisher<FileCacheLocation, Error> {
                        
        return getTranslationFileFromCache(translation: translation, fileName: fileName).publisher
            .catch({ (error: Error) -> AnyPublisher<FileCacheLocation, Error> in
                
                return self.getTranslationFileFromRemote(translation: translation, fileName: fileName, requestPriority: requestPriority)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (fileCacheLocation: FileCacheLocation) -> AnyPublisher<FileCacheLocation, Error> in
                
                return Just(fileCacheLocation).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getTranslationFileFromCache(translation: TranslationDataModel, fileName: String) -> Result<FileCacheLocation, Error> {
                
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
    
    private func getTranslationFileFromRemote(translation: TranslationDataModel, fileName: String, requestPriority: RequestPriority) -> AnyPublisher<FileCacheLocation, Error> {
        
        return api.getTranslationFile(fileName: fileName, requestPriority: requestPriority)
            .flatMap({ (response: RequestDataResponse) -> AnyPublisher<FileCacheLocation, Error> in
                
                return self.resourcesFileCache.storeTranslationFile(translationId: translation.id, fileName: fileName, fileData: response.data)
                    .eraseToAnyPublisher()
            })
            .flatMap({ fileLocation -> AnyPublisher<FileCacheLocation, Error> in
                
                return Just(fileLocation).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationZipFiles(translation: TranslationDataModel, requestPriority: RequestPriority) -> AnyPublisher<TranslationFilesDataModel, Error> {
        
        return api.getTranslationZipFile(translationId: translation.id, requestPriority: requestPriority)
            .flatMap({ (response: RequestDataResponse) -> AnyPublisher<TranslationFilesDataModel, Error> in
                
                return self.resourcesFileCache.storeTranslationZipFile(translationId: translation.id, zipFileData: response.data)
                    .flatMap({ files -> AnyPublisher<TranslationFilesDataModel, Error> in
                        
                        return self.didDownloadTranslationAndRelatedFiles(translation: translation, files: files)
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Completed Downloading Translation And Related Files

extension TranslationsRepository {
    
    private func didDownloadTranslationAndRelatedFiles(translation: TranslationDataModel, files: [FileCacheLocation]) -> AnyPublisher<TranslationFilesDataModel, Error> {
        
        return trackDownloadedTranslationsRepository.trackTranslationDownloaded(translation: translation)
            .flatMap({ translationId -> AnyPublisher<TranslationFilesDataModel, Error> in
                
                return Just(TranslationFilesDataModel(files: files, translation: translation)).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
