//
//  TranslationsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import RequestOperation
import RepositorySync

final class TranslationsRepository {
    
    private let api: TranslationsApiInterface
    private let cache: TranslationsCache
    private let infoPlist: InfoPlist
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
    private let remoteConfigRepository: RemoteConfigRepository
    
    init(api: TranslationsApiInterface, cache: TranslationsCache, infoPlist: InfoPlist, resourcesFileCache: ResourcesSHA256FileCache, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository, remoteConfigRepository: RemoteConfigRepository) {
        
        self.api = api
        self.cache = cache
        self.infoPlist = infoPlist
        self.resourcesFileCache = resourcesFileCache
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
        self.remoteConfigRepository = remoteConfigRepository
    }
    
    var persistence: any Persistence<TranslationDataModel, TranslationCodable> {
        return cache.persistence
    }
    
    func getLatestTranslation(resourceId: String, languageId: String) -> TranslationDataModel? {
        
        do {
            return try cache.getLatestTranslation(resourceId: resourceId, languageId: languageId)
        }
        catch _ {
            return nil
        }
    }
    
    func getLatestTranslation(resourceId: String, languageCode: String) -> TranslationDataModel? {
        
        do {
            return try cache.getLatestTranslation(resourceId: resourceId, languageCode: languageCode)
        }
        catch _ {
            return nil
        }
    }
}

// MARK: - Fetching Translation Manifests and Related Files By Manifest Parser Type From Cache

extension TranslationsRepository {
    
    func getTranslationManifestsFromCache(translations: [TranslationDataModel], manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool) async throws -> [TranslationManifestFileDataModel] {
        
        var dataModels: [TranslationManifestFileDataModel] = Array()
        
        for translation in translations {
            
            let translationManifestFile = try await getTranslationManifestFromCache(
                translation: translation,
                manifestParserType: manifestParserType,
                includeRelatedFiles: includeRelatedFiles
            )
            
            dataModels.append(translationManifestFile)
        }
        
        return dataModels
    }
    
    func getTranslationManifestFromCache(translation: TranslationDataModel, manifestParserType: TranslationManifestParserType, includeRelatedFiles: Bool) async throws -> TranslationManifestFileDataModel {
        
        let manifestParser = TranslationManifestParser.getManifestParser(
            type: manifestParserType,
            infoPlist: infoPlist,
            resourcesFileCache: resourcesFileCache,
            remoteConfigRepository: remoteConfigRepository
        )
        
        let manifest = try await manifestParser.parse(manifestName: translation.manifestName)
        
        guard includeRelatedFiles else {
            
            return TranslationManifestFileDataModel(
                manifest: manifest,
                relatedFiles: [],
                translation: translation
            )
        }
        
        var relatedFiles: [FileCacheLocation] = Array()
        
        for relatedFile in manifest.relatedFiles {
            
            let fileCacheLocation = try getTranslationFileFromCache(
                translation: translation,
                fileName: relatedFile
            )
            
            relatedFiles.append(fileCacheLocation)
        }
        
        return TranslationManifestFileDataModel(manifest: manifest, relatedFiles: relatedFiles, translation: translation)
    }
    
    func getTranslationManifestFromCacheElseRemote(translation: TranslationDataModel, manifestParserType: TranslationManifestParserType, requestPriority: RequestPriority, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) async throws -> TranslationManifestFileDataModel {
        
        do {
            
            let cachedManifest = try await getTranslationManifestFromCache(
                translation: translation,
                manifestParserType: manifestParserType,
                includeRelatedFiles: includeRelatedFiles
            )
            
            return cachedManifest
        }
        catch _ {
            
            return try await getTranslationManifestFromRemote(
                translation: translation,
                manifestParserType: manifestParserType,
                requestPriority: requestPriority,
                includeRelatedFiles: includeRelatedFiles,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: shouldFallbackToLatestDownloadedTranslationIfRemoteFails
            )
        }
    }
}

// MARK: - Fetching Translation Manifests and Related Files By Manifest Parser Type From Remote

extension TranslationsRepository {
    
    func getTranslationManifestsFromRemote(translations: [TranslationDataModel], manifestParserType: TranslationManifestParserType, requestPriority: RequestPriority, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) async throws -> [TranslationManifestFileDataModel] {
           
        var translationManifests: [TranslationManifestFileDataModel] = Array()
        
        for translation in translations {
            
            let translationManifest = try await getTranslationManifestFromRemote(
                translation: translation,
                manifestParserType: manifestParserType,
                requestPriority: requestPriority,
                includeRelatedFiles: includeRelatedFiles,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: shouldFallbackToLatestDownloadedTranslationIfRemoteFails
            )
            
            translationManifests.append(translationManifest)
        }
        
        return orderTranslationManifests(translationManifests: translationManifests, by: translations)
    }
    
    private func orderTranslationManifests(translationManifests: [TranslationManifestFileDataModel], by translations: [TranslationDataModel]) -> [TranslationManifestFileDataModel] {
        
        var maintainTranslationDownloadOrder: [TranslationManifestFileDataModel] = Array()
        
        for translation in translations {
            
            let translationManifest: TranslationManifestFileDataModel?
            
            if let downloadedTranslationManifest = translationManifests.first(where: {$0.translation.id == translation.id}) {
                translationManifest = downloadedTranslationManifest
            }
            else if let downloadedTranslationManifest = translationManifests.first(where: {$0.translation.resourceDataModel?.id == translation.resourceDataModel?.id && $0.translation.languageDataModel?.id == translation.languageDataModel?.id}) {
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
    }
    
    func getTranslationManifestFromRemote(translation: TranslationDataModel, manifestParserType: TranslationManifestParserType, requestPriority: RequestPriority, includeRelatedFiles: Bool, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: Bool) async throws -> TranslationManifestFileDataModel {
        
        do {
            
            _ = try await getTranslationFileFromCacheElseRemote(
                translation: translation,
                fileName: translation.manifestName,
                requestPriority: requestPriority
            )
            
            let manifestParser = TranslationManifestParser.getManifestParser(
                type: manifestParserType,
                infoPlist: infoPlist,
                resourcesFileCache: resourcesFileCache,
                remoteConfigRepository: remoteConfigRepository
            )
            
            let manifest = try await manifestParser.parse(manifestName: translation.manifestName)
            
            guard includeRelatedFiles else {
                
                return TranslationManifestFileDataModel(
                    manifest: manifest,
                    relatedFiles: [],
                    translation: translation
                )
            }
            
            var relatedFiles: [FileCacheLocation] = Array()
            
            for relatedFile in manifest.relatedFiles {
                
                let file = try await getTranslationFileFromCacheElseRemote(
                    translation: translation,
                    fileName: relatedFile,
                    requestPriority: requestPriority
                )
                
                relatedFiles.append(file)
            }
            
            return TranslationManifestFileDataModel(
                manifest: manifest,
                relatedFiles: relatedFiles,
                translation: translation
            )
        }
        catch let error {
            
            guard !error.isUrlErrorCancelledCode else {
                throw error
            }
            
            let shouldFallbackToLatestDownloadedTranslation: Bool = includeRelatedFiles && shouldFallbackToLatestDownloadedTranslationIfRemoteFails
            
            let latestDownloadedTranslation: TranslationDataModel?
            
            if shouldFallbackToLatestDownloadedTranslation,
               let resourceId = translation.resourceDataModel?.id,
               let languageId = translation.languageDataModel?.id,
               let latestTrackedDownloadedTranslation = try trackDownloadedTranslationsRepository.getLatestDownloadedTranslation(resourceId: resourceId, languageId: languageId) {
                
                latestDownloadedTranslation = try persistence.getDataModel(id: latestTrackedDownloadedTranslation.translationId)
            }
            else {
                
                latestDownloadedTranslation = nil
            }
            
            if !error.isUrlErrorNotConnectedToInternetCode {
                
                do {
                    
                    _ = try await downloadAndCacheTranslationZipFiles(
                        translation: translation,
                        requestPriority: requestPriority
                    )
                    
                    return try await getTranslationManifestFromCache(
                        translation: translation,
                        manifestParserType: manifestParserType,
                        includeRelatedFiles: includeRelatedFiles
                    )
                }
                catch let error {
                    
                    if let latestDownloadedTranslation = latestDownloadedTranslation {
                     
                        return try await getTranslationManifestFromCache(
                            translation: latestDownloadedTranslation,
                            manifestParserType: manifestParserType,
                            includeRelatedFiles: includeRelatedFiles
                        )
                    }
                    
                    throw error
                }
            }
            else if let latestDownloadedTranslation = latestDownloadedTranslation {
             
                return try await getTranslationManifestFromCache(
                    translation: latestDownloadedTranslation,
                    manifestParserType: manifestParserType,
                    includeRelatedFiles: includeRelatedFiles
                )
            }
            
            throw error
        }
    }
}

// MARK: - Downloading and Cacheing Translation Files

extension TranslationsRepository {
    
    func downloadAndCacheTranslationFiles(translation: TranslationDataModel, requestPriority: RequestPriority) async throws -> TranslationFilesDataModel {
        
        do {
            
            _ = try await getTranslationFileFromCacheElseRemote(
                translation: translation,
                fileName: translation.manifestName,
                requestPriority: requestPriority
            )
            
            let manifestParser = TranslationManifestParser.getManifestParser(
                type: .manifestOnly,
                infoPlist: infoPlist,
                resourcesFileCache: resourcesFileCache,
                remoteConfigRepository: remoteConfigRepository
            )
            
            let manifest: Manifest = try await manifestParser.parse(manifestName: translation.manifestName)
            
            var downloadedFiles: [FileCacheLocation] = Array()
            
            for relatedFile in manifest.relatedFiles {
                
                let fileCacheLocation = try await getTranslationFileFromCacheElseRemote(
                    translation: translation,
                    fileName: relatedFile,
                    requestPriority: requestPriority
                )
                
                downloadedFiles.append(fileCacheLocation)
            }
            
            return try await didDownloadTranslationAndRelatedFiles(translation: translation, files: downloadedFiles)
        }
        catch let error {

            if !error.isUrlErrorNotConnectedToInternetCode {
                return try await downloadAndCacheTranslationZipFiles(translation: translation, requestPriority: requestPriority)
            }
            else {
                throw error
            }
        }
    }
    
    private func getTranslationFileFromCacheElseRemote(translation: TranslationDataModel, fileName: String, requestPriority: RequestPriority) async throws -> FileCacheLocation {
        
        do {
            
            return try getTranslationFileFromCache(
                translation: translation,
                fileName: fileName
            )
        }
        catch _ {
            
            return try await getTranslationFileFromRemote(
                translation: translation,
                fileName: fileName,
                requestPriority: requestPriority
            )
        }
    }
    
    private func getTranslationFileFromCache(translation: TranslationDataModel, fileName: String) throws -> FileCacheLocation {
        
        let fileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        let fileExists: Bool = try resourcesFileCache.getFileExists(location: fileCacheLocation)
        
        guard fileExists else {
            throw NSError.errorWithDescription(description: "Failed to get translation file.  File does not exist in the cache.")
        }
        
        return fileCacheLocation
    }
    
    private func getTranslationFileFromRemote(translation: TranslationDataModel, fileName: String, requestPriority: RequestPriority) async throws -> FileCacheLocation {
        
        let response: RequestDataResponse = try await api.getTranslationFile(
            fileName: fileName,
            requestPriority: requestPriority
        )
        
        return try resourcesFileCache.storeTranslationFile(
            translationId: translation.id,
            fileName: fileName,
            fileData: response.data
        )
    }
    
    private func downloadAndCacheTranslationZipFiles(translation: TranslationDataModel, requestPriority: RequestPriority) async throws -> TranslationFilesDataModel {
        
        let response: RequestDataResponse = try await api.getTranslationZipFile(
            translationId: translation.id,
            requestPriority: requestPriority
        )
        
        let files: [FileCacheLocation] = try resourcesFileCache.storeTranslationZipFile(
            translationId: translation.id,
            zipFileData: response.data
        )
        
        return try await didDownloadTranslationAndRelatedFiles(
            translation: translation,
            files: files
        )
    }
}

// MARK: - Completed Downloading Translation And Related Files

extension TranslationsRepository {
    
    private func didDownloadTranslationAndRelatedFiles(translation: TranslationDataModel, files: [FileCacheLocation]) async throws -> TranslationFilesDataModel {
        
        _ = try await trackDownloadedTranslationsRepository.trackTranslationDownloaded(
            translation: translation
        )
        
        return TranslationFilesDataModel(files: files, translation: translation)
    }
}

