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
        
    private let infoPlist: InfoPlist
    private let appBuild: AppBuild
    private let api: MobileContentTranslationsApi
    private let cache: RealmTranslationsCache
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
    
    init(infoPlist: InfoPlist, appBuild: AppBuild, api: MobileContentTranslationsApi, cache: RealmTranslationsCache, resourcesFileCache: ResourcesSHA256FileCache, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository) {
        
        self.infoPlist = infoPlist
        self.appBuild = appBuild
        self.api = api
        self.cache = cache
        self.resourcesFileCache = resourcesFileCache
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
    }
}

// MARK: - Translations

extension TranslationsRepository {
    
    func getTranslation(id: String) -> TranslationModel? {
        return cache.getTranslation(id: id)
    }
    
    func getTranslations(ids: [String]) -> [TranslationModel] {
        return cache.getTranslations(ids: ids)
    }
    
    func getLatestTranslation(resourceId: String, languageId: String) -> TranslationModel? {
        return cache.getTranslationsSortedByLatestVersion(resourceId: resourceId, languageId: languageId).first
    }
    
    func getLatestTranslation(resourceId: String, languageCode: String) -> TranslationModel? {
        return cache.getTranslationsSortedByLatestVersion(resourceId: resourceId, languageCode: languageCode).first
    }
}

// MARK: - Fetching Translation Manifests and Related Files By Manifest Parser Type From Cache

extension TranslationsRepository {
    
    func getTranslationManifestsFromCache(translations: [TranslationModel], manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool) -> AnyPublisher<[TranslationManifestFileDataModel], Error> {
       
        let requests = translations.map {
            self.getTranslationManifestFromCache(translation: $0, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getTranslationManifestFromCache(translation: TranslationModel, manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool) -> AnyPublisher<TranslationManifestFileDataModel, Error> {
        
        let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(type: manifestParserType, infoPlist: infoPlist, resourcesFileCache: resourcesFileCache, appBuild: appBuild)
        
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
    
    func getTranslationManifestFromCacheElseRemote(translation: TranslationModel, manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) -> AnyPublisher<TranslationManifestFileDataModel, Error> {
        
        return getTranslationManifestFromCache(translation: translation, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
            .catch({ (error: Error) -> AnyPublisher<TranslationManifestFileDataModel, Error> in
                
                return self.getTranslationManifestFromRemote(
                    translation: translation,
                    manifestParserType: manifestParserType,
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
    
    func getTranslationManifestsFromRemoteWithProgress(translations: [TranslationModel], manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) -> AnyPublisher<TranslationsDownloadProgressDataModel, Error> {
        
        let requests = translations.map {
            
            self.getTranslationManifestFromRemote(
                translation: $0,
                manifestParserType: manifestParserType,
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
    
    func getTranslationManifestsFromRemote(translations: [TranslationModel], manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) -> AnyPublisher<[TranslationManifestFileDataModel], Error> {
       
        let requests = translations.map {
            
            self.getTranslationManifestFromRemote(
                translation: $0,
                manifestParserType: manifestParserType,
                includeRelatedFiles: includeRelatedFiles,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: shouldFallbackToLatestDownloadedTranslationIfRemoteFails
            )
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .map({ downloadedTranslationManifestFileDataModels in
                
                var maintainTranslationDownloadOrder: [TranslationManifestFileDataModel] = Array()
                
                for translation in translations {
                    
                    let translationManifest: TranslationManifestFileDataModel?
                    
                    if let downloadedTranslationManifest = downloadedTranslationManifestFileDataModels.first(where: {$0.translation.id == translation.id}) {
                        translationManifest = downloadedTranslationManifest
                    }
                    else if let downloadedTranslationManifest = downloadedTranslationManifestFileDataModels.first(where: {$0.translation.resource?.id == translation.resource?.id && $0.translation.language?.id == translation.language?.id}) {
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
    
    func getTranslationManifestFromRemote(translation: TranslationModel, manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) -> AnyPublisher<TranslationManifestFileDataModel, Error> {
        
        return getTranslationFileFromCacheElseRemote(translation: translation, fileName: translation.manifestName)
            .flatMap({ fileCacheLocation -> AnyPublisher<Manifest, Error> in
                
                let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(type: manifestParserType, infoPlist: self.infoPlist, resourcesFileCache: self.resourcesFileCache, appBuild: self.appBuild)
                
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
                    self.getTranslationFileFromCacheElseRemote(translation: translation, fileName: $0)
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
                
                let latestDownloadedTranslation: TranslationModel?
                
                if shouldFallbackToLatestDownloadedTranslation,
                   let resourceId = translation.resource?.id,
                   let languageId = translation.language?.id,
                   let latestTrackedDownloadedTranslation = self.trackDownloadedTranslationsRepository.getLatestDownloadedTranslation(resourceId: resourceId, languageId: languageId) {
                    
                    latestDownloadedTranslation = self.getTranslation(id: latestTrackedDownloadedTranslation.translationId)
                }
                else {
                    latestDownloadedTranslation = nil
                }
                
                if !error.isUrlErrorNotConnectedToInternetCode {
                    
                    return self.downloadAndCacheTranslationZipFiles(translation: translation)
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
    
    func downloadAndCacheFilesForTranslations(translations: [TranslationModel]) -> AnyPublisher<[TranslationFilesDataModel], Error> {
        
        let requests = translations.map {
            self.downloadAndCacheTranslationFiles(translation: $0)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheFilesForTranslationsIgnoringError(translations: [TranslationModel]) -> AnyPublisher<[TranslationFilesDataModel], Never> {
        
        let requests = translations.map { (translation: TranslationModel) in
            self.downloadAndCacheTranslationFiles(translation: translation)
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
    
    private func downloadAndCacheTranslationFiles(translation: TranslationModel) -> AnyPublisher<TranslationFilesDataModel, Error> {
        
        return getTranslationFileFromCacheElseRemote(translation: translation, fileName: translation.manifestName)
            .flatMap({ fileCacheLocation -> AnyPublisher<Manifest, Error> in
                
                let manifestParser: TranslationManifestParser = TranslationManifestParser.getManifestParser(type: .manifestOnly, infoPlist: self.infoPlist, resourcesFileCache: self.resourcesFileCache, appBuild: self.appBuild)
                
                return manifestParser.parsePublisher(manifestName: translation.manifestName)
                    .eraseToAnyPublisher()
            })
            .flatMap({ manifest -> AnyPublisher<TranslationFilesDataModel, Error> in
                
                let requests = manifest.relatedFiles.map {
                    self.getTranslationFileFromCacheElseRemote(translation: translation, fileName: $0)
                }
                
                return Publishers.MergeMany(requests)
                    .collect()
                    .flatMap({ files -> AnyPublisher<TranslationFilesDataModel, Error> in
                        
                        return self.didDownloadTranslationAndRelatedFiles(translation: translation, files: files)
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            })
            .catch({ (error: Error) in
                
                return self.downloadAndCacheTranslationZipFiles(translation: translation)
            })
            .eraseToAnyPublisher()
    }
    
    private func getTranslationFileFromCacheElseRemote(translation: TranslationModel, fileName: String) -> AnyPublisher<FileCacheLocation, Error> {
                        
        return getTranslationFileFromCache(translation: translation, fileName: fileName).publisher
            .catch({ (error: Error) -> AnyPublisher<FileCacheLocation, Error> in
                
                return self.getTranslationFileFromRemote(translation: translation, fileName: fileName)
                    .eraseToAnyPublisher()
            })
            .flatMap({ fileCacheLocation -> AnyPublisher<FileCacheLocation, Error> in
                
                return Just(fileCacheLocation).setFailureType(to: Error.self)
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
    
    private func getTranslationFileFromRemote(translation: TranslationModel, fileName: String) -> AnyPublisher<FileCacheLocation, Error> {
        
        return api.getTranslationFile(fileName: fileName)
            .flatMap({ responseObject -> AnyPublisher<FileCacheLocation, Error> in
                
                return self.resourcesFileCache.storeTranslationFile(translationId: translation.id, fileName: fileName, fileData: responseObject.data)
                    .eraseToAnyPublisher()
            })
            .flatMap({ fileLocation -> AnyPublisher<FileCacheLocation, Error> in
                
                return Just(fileLocation).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheTranslationZipFiles(translation: TranslationModel) -> AnyPublisher<TranslationFilesDataModel, Error> {
        
        return api.getTranslationZipFile(translationId: translation.id)
            .flatMap({ responseObject -> AnyPublisher<TranslationFilesDataModel, Error> in
                
                return self.resourcesFileCache.storeTranslationZipFile(translationId: translation.id, zipFileData: responseObject.data)
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
    
    private func didDownloadTranslationAndRelatedFiles(translation: TranslationModel, files: [FileCacheLocation]) -> AnyPublisher<TranslationFilesDataModel, Error> {
        
        return trackDownloadedTranslationsRepository.trackTranslationDownloaded(translation: translation)
            .flatMap({ translationId -> AnyPublisher<TranslationFilesDataModel, Error> in
                
                return Just(TranslationFilesDataModel(files: files, translation: translation)).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
