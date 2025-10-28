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

class GetToolTranslationsFilesUseCase {
        
    private static let defaultRequestPriority: RequestPriority = .high
    
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
                
        let manifestParserType: TranslationManifestParserType
        let includeRelatedFiles: Bool
        
        var translationOrder: [TranslationDataModel] = Array()
        
        switch filter {
        case .downloadManifestAndRelatedFilesForRenderer:
            manifestParserType = .renderer
            includeRelatedFiles = true
        case .downloadManifestForTipsCount:
            manifestParserType = .manifestOnly
            includeRelatedFiles = false
        }
        
        return determineToolTranslationsToDownload.determineToolTranslationsToDownload().publisher
            .catch({ (error: DetermineToolTranslationsToDownloadError) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, Error> in
                
                self.initiateDownloadStarted(downloadStarted: downloadStarted)
                
                switch error {
                case .failedToFetchResourceFromCache(let resourceNeeded):
                    
                    return self.downloadResourcesFromJsonFileCacheAndDetermineTranslationsToDownloadPublisher(
                        resourceNeeded: resourceNeeded,
                        determineToolTranslationsToDownload: determineToolTranslationsToDownload
                    )
                    .eraseToAnyPublisher()
                }
            })
            .flatMap({ (result: DetermineToolTranslationsToDownloadResult) -> AnyPublisher<[TranslationManifestFileDataModel], Error> in
                   
                let translations: [TranslationDataModel] = result.translations
                
                translationOrder = result.translations
                
                return self.translationsRepository.getTranslationManifestsFromCache(translations: translations, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
                    .catch({ (error: Error) -> AnyPublisher<[TranslationManifestFileDataModel], Error> in
                        
                        self.initiateDownloadStarted(downloadStarted: downloadStarted)
                            
                        return self.translationsRepository.getTranslationManifestsFromRemote(translations: translations, manifestParserType: manifestParserType, requestPriority: Self.defaultRequestPriority, includeRelatedFiles: includeRelatedFiles, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: true)
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            })
            .flatMap({ (translationManifests: [TranslationManifestFileDataModel]) -> AnyPublisher<[TranslationManifestFileDataModel], Error> in
                    
                let translations: [TranslationDataModel] = translationManifests.map({ $0.translation })
                
                return self.translationsRepository.getTranslationManifestsFromCache(translations: translations, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (translationManifests: [TranslationManifestFileDataModel]) -> AnyPublisher<ToolTranslationsDomainModel, Error> in
                
                guard let resource = translationManifests.first?.translation.resourceDataModel else {
                    
                    let error = NSError.errorWithDescription(description: "Failed to get resource on translation model.")
                    
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
                
                let languageManifets: [MobileContentRendererLanguageTranslationManifest] = translationManifests.compactMap({
                    
                    guard let languageCodable = $0.translation.languageDataModel else {
                        return nil
                    }
                    
                    return MobileContentRendererLanguageTranslationManifest(
                        manifest: $0.manifest,
                        language: LanguageDataModel(interface: languageCodable),
                        translation: $0.translation
                    )
                })
                
                let sortedLanguageManifests: [MobileContentRendererLanguageTranslationManifest] = self.sortLanguageTranslationManifestsByTranslationOrder(translationOrder: translationOrder, languageTranslationManifests: languageManifets)
                
                let domainModel = ToolTranslationsDomainModel(
                    tool: resource,
                    languageTranslationManifests: sortedLanguageManifests
                )
                
                return Just(domainModel).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
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
    
    private func downloadResourcesFromJsonFileCacheAndDetermineTranslationsToDownloadPublisher(resourceNeeded: DetermineToolTranslationsResourceNeeded, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, Error> {
        
        return resourcesRepository
            .syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile()
            .flatMap({ (didSyncResources: RealmResourcesCacheSyncResult?) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, Error> in
                
                let determineResult: Result<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> = determineToolTranslationsToDownload.determineToolTranslationsToDownload()
                
                switch determineResult {
                
                case .success(let translationsResult):
                   
                    return Just(translationsResult)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
               
                case .failure(let determineTranslationsError):
                    
                    switch determineTranslationsError {
                    
                    case .failedToFetchResourceFromCache(let resourceNeeded):
                        
                        return self.downloadResourcesFromRemoteAndDetermineTranslationsToDownloadPublisher(
                            resourceNeeded: resourceNeeded,
                            determineToolTranslationsToDownload: determineToolTranslationsToDownload
                        )
                        .eraseToAnyPublisher()
                    }
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadResourcesFromRemoteAndDetermineTranslationsToDownloadPublisher(resourceNeeded: DetermineToolTranslationsResourceNeeded, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, Error> {
        
        return languagesRepository
            .syncLanguagesFromRemote(requestPriority: Self.defaultRequestPriority)
            .flatMap({ (languagesResponse: RepositorySyncResponse<LanguageDataModel>) -> AnyPublisher<Void, Error> in
                
                self.syncResourcesPublisher(resourceNeeded: resourceNeeded)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (didSyncResources: Void) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, Error> in
                
                let determineResult: Result<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> = determineToolTranslationsToDownload.determineToolTranslationsToDownload()
                
                switch determineResult {
                
                case .success(let translationsResult):
                   
                    return Just(translationsResult)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
               
                case .failure(let determineTranslationsError):
                    
                    switch determineTranslationsError {
                    
                    case .failedToFetchResourceFromCache( _):
                       
                        let error: Error = NSError.errorWithDescription(description: "Failed to fetch resources needed.")
                       
                        return Fail(error: error)
                            .eraseToAnyPublisher()
                    }
                    
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func syncResourcesPublisher(resourceNeeded: DetermineToolTranslationsResourceNeeded) -> AnyPublisher<Void, Error> {
        
        switch resourceNeeded {
        
        case .abbreviation(let value):
            return resourcesRepository
                .syncResourceAndLatestTranslationsPublisher(resourceAbbreviation: value, requestPriority: Self.defaultRequestPriority)
                .eraseToAnyPublisher()
            
        case .id(let value):
            return resourcesRepository
                .syncResourceAndLatestTranslationsPublisher(resourceId: value, requestPriority: Self.defaultRequestPriority)
                .eraseToAnyPublisher()
        }
    }
}
