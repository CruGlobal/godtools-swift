//
//  GetToolTranslationsFilesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsShared
import RequestOperation

final class GetToolTranslationsFilesUseCase {
            
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let languagesRepository: LanguagesRepository
    
    private var getToolTranslationsCancellable: AnyCancellable?
    private var didInitiateDownloadStarted: Bool = false
        
    init(resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, languagesRepository: LanguagesRepository) {

        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.languagesRepository = languagesRepository
    }
    
    func getToolTranslationsFilesPublisher(filter: GetToolTranslationsFilesFilter, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface, downloadStarted: (() -> Void)?) -> AnyPublisher<ToolTranslationsDomainModel, Error> {
                
        return AnyPublisher() {
            return try await self.asyncExecute(
                filter: filter,
                determineToolTranslationsToDownload: determineToolTranslationsToDownload,
                downloadStarted: downloadStarted
            )
        }
    }
    
    private func asyncExecute(filter: GetToolTranslationsFilesFilter, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface, downloadStarted: (() -> Void)?) async throws -> ToolTranslationsDomainModel {
        
        let requestPriority: RequestPriority = .high
        let manifestParserType: TranslationManifestParserType
        let includeRelatedFiles: Bool
        
        switch filter {
        case .downloadManifestAndRelatedFilesForRenderer:
            manifestParserType = .renderer
            includeRelatedFiles = true
        case .downloadManifestForTipsCount:
            manifestParserType = .manifestOnly
            includeRelatedFiles = false
        }
        
        let translationsToDownload: ToolTranslationsToDownload
        
        var translationOrder: [TranslationDataModel] = Array()
        
        do {
            
            translationsToDownload = try await determineToolTranslationsToDownload.determineToolTranslationsToDownload()
        }
        catch let determineToolTranslationsToDownloadError {
            
            switch determineToolTranslationsToDownloadError {
                
            case .failedToFetchResourceFromCache(let resourceNeeded):
                
                initiateDownloadStarted(downloadStarted: downloadStarted)
                
                translationsToDownload = try await downloadResourcesFromJsonFileCacheAndDetermineTranslationsToDownload(
                    requestPriority: requestPriority,
                    resourceNeeded: resourceNeeded,
                    determineToolTranslationsToDownload: determineToolTranslationsToDownload
                )
                
            case .error(let error):
                throw error
            }
        }
        
        let translations: [TranslationDataModel] = translationsToDownload.translations
        
        translationOrder = translationsToDownload.translations
        
        let fetchedTranslationManifests: [TranslationManifestFileDataModel]
        
        do {
            
            fetchedTranslationManifests = try await translationsRepository.getTranslationManifestsFromCache(
                translations: translations,
                manifestParserType: manifestParserType,
                includeRelatedFiles: includeRelatedFiles
            )
        }
        catch let error {
            
            initiateDownloadStarted(downloadStarted: downloadStarted)
            
            fetchedTranslationManifests = try await translationsRepository.getTranslationManifestsFromRemote(
                translations: translations,
                manifestParserType: manifestParserType,
                requestPriority: requestPriority,
                includeRelatedFiles: includeRelatedFiles,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: true
            )
        }
                
        let translationManifests: [TranslationManifestFileDataModel] = try await translationsRepository.getTranslationManifestsFromCache(
            translations: fetchedTranslationManifests.map({ $0.translation }),
            manifestParserType: manifestParserType,
            includeRelatedFiles: includeRelatedFiles
        )
        
        guard let resource = translationManifests.first?.translation.resourceDataModel else {
            throw NSError.errorWithDescription(description: "Failed to get resource on translation model.")
        }
        
        let languageManifets: [MobileContentRendererLanguageTranslationManifest] = translationManifests.compactMap({
            
            guard let languageDataModel = $0.translation.languageDataModel else {
                return nil
            }
            
            return MobileContentRendererLanguageTranslationManifest(
                manifest: $0.manifest,
                language: languageDataModel,
                translation: $0.translation
            )
        })
        
        let sortedLanguageManifests: [MobileContentRendererLanguageTranslationManifest] = self.sortLanguageTranslationManifestsByTranslationOrder(translationOrder: translationOrder, languageTranslationManifests: languageManifets)
        
        let domainModel = ToolTranslationsDomainModel(
            tool: resource,
            languageTranslationManifests: sortedLanguageManifests
        )
        
        return domainModel
    }
    
    private func initiateDownloadStarted(downloadStarted: (() -> Void)?) {
        
        guard !didInitiateDownloadStarted else {
            return
        }
        
        didInitiateDownloadStarted = true
        
        downloadStarted?()
    }
    
    private func sortLanguageTranslationManifestsByTranslationOrder(translationOrder: [TranslationDataModel], languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest]) -> [MobileContentRendererLanguageTranslationManifest] {
        
        var sortedLanguageTranslationManifests: [MobileContentRendererLanguageTranslationManifest] = Array()
        
        for translation in translationOrder {
            
            guard let languageManifest = languageTranslationManifests.first(where: {$0.translation.id == translation.id}) else {
                continue
            }
            
            sortedLanguageTranslationManifests.append(languageManifest)
        }
        
        return sortedLanguageTranslationManifests
    }
    
    private func downloadResourcesFromJsonFileCacheAndDetermineTranslationsToDownload(requestPriority: RequestPriority, resourceNeeded: DetermineToolTranslationsResourceNeeded, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface) async throws -> ToolTranslationsToDownload {
        
        _ = try await resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile()
        
        do {
            
            let downloadResult: ToolTranslationsToDownload = try await determineToolTranslationsToDownload.determineToolTranslationsToDownload()
            
            return downloadResult
        }
        catch let determineTranslationsError {
            
            switch determineTranslationsError {
            
            case .failedToFetchResourceFromCache(let resourceNeeded):
                
                return try await downloadResourcesFromRemoteAndDetermineTranslationsToDownload(
                    requestPriority: requestPriority,
                    resourceNeeded: resourceNeeded,
                    determineToolTranslationsToDownload: determineToolTranslationsToDownload
                )
                
            case .error(let error):
                throw error
            }
        }
    }
    
    private func downloadResourcesFromRemoteAndDetermineTranslationsToDownload(requestPriority: RequestPriority, resourceNeeded: DetermineToolTranslationsResourceNeeded, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface) async throws -> ToolTranslationsToDownload {
        
        _ = try await languagesRepository.syncLanguagesFromRemote(requestPriority: requestPriority)
        
        _ = try await syncResources(requestPriority: requestPriority, resourceNeeded: resourceNeeded)
        
        do {
            
            let downloadResult: ToolTranslationsToDownload = try await determineToolTranslationsToDownload.determineToolTranslationsToDownload()
            
            return downloadResult
        }
        catch let determineTranslationsError {
            
            switch determineTranslationsError {
            
            case .failedToFetchResourceFromCache( _):
                throw NSError.errorWithDescription(description: "Failed to fetch resources needed.")
                
            case .error(let error):
                throw error
            }
        }
    }
    
    private func syncResources(requestPriority: RequestPriority, resourceNeeded: DetermineToolTranslationsResourceNeeded) async throws {
        
        switch resourceNeeded {
        
        case .abbreviation(let value):
            _ = try await resourcesRepository
                .syncResourceAndLatestTranslations(
                    resourceAbbreviation: value,
                    requestPriority: requestPriority
                )
            
        case .id(let value):
            _ = try await resourcesRepository
                .syncResourceAndLatestTranslations(
                    resourceId: value,
                    requestPriority: requestPriority
                )
        }
    }
}
