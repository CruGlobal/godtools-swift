//
//  GetToolTranslationsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolTranslationsUseCase {
    
    typealias TranslationId = String
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let languagesRepository: LanguagesRepository
    private let mobileContentParser: MobileContentParser
    
    private var getToolTranslationsCancellable: AnyCancellable?
        
    init(resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, languagesRepository: LanguagesRepository, mobileContentParser: MobileContentParser) {

        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.languagesRepository = languagesRepository
        self.mobileContentParser = mobileContentParser
    }
    
    func getToolTranslationsFromCache(determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType) -> AnyPublisher<ToolTranslationsDomainModel, ToolTranslationsDomainError> {
        
        return getToolTranslationsManifestsFromCache(determineToolTranslationsToDownload: determineToolTranslationsToDownload)
            .mapError { error in
                return .errorFetchingTranslationManifestsFromCache(error: error)
            }
            .flatMap({ result -> AnyPublisher<ToolTranslationsDomainModel, ToolTranslationsDomainError> in
                
                switch result {
                
                case .didGetToolTranslationsData(let toolTranslationsData):
                    
                    return self.parseToolTranslationsToGodToolsToolParserManifestObjects(toolTranslations: toolTranslationsData).publisher
                        .mapError { error in
                            return .errorParsingTranslationManifestData(error: error)
                        }
                        .eraseToAnyPublisher()
                    
                case .failedToFetchResourcesFromCache:
                    
                    return Fail(error: .failedToFetchResourcesFromCache)
                        .eraseToAnyPublisher()
                
                case .failedToFetchTranslationManifestsFromCache(let translationIds):
                    
                    return Fail(error: .failedToFetchTranslationFilesFromCache(translationIds: translationIds))
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    func getToolTranslationsFromRemote() {
        
    }
    
    func getToolTranslations(determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, downloadStarted: @escaping (() -> Void), downloadFinished: @escaping ((_ result: Result<ToolTranslations, Error>) -> Void)) {
        
        getToolTranslationsCancellable = getToolTranslationsManifestsFromCache(determineToolTranslationsToDownload: determineToolTranslationsToDownload)
            .flatMap({ result -> AnyPublisher<Bool, Error> in
                
                switch result {
                
                case .didGetToolTranslationsData(let toolTranslationsData):
                    
                    downloadFinished(self.parseToolTranslationsToGodToolsToolParserManifestObjects(toolTranslations: toolTranslationsData))
                    
                case .failedToFetchResourcesFromCache:
                    
                    downloadStarted()
                    
                    return self.downloadResourcesFromRemote()
                        .flatMap({ results -> AnyPublisher<GetToolTranslationsManifestsFromCacheResult, Error> in
                            
                            return self.getToolTranslationsManifestsFromCache(determineToolTranslationsToDownload: determineToolTranslationsToDownload)
                                .eraseToAnyPublisher()
                        })
                        .flatMap({ result  -> AnyPublisher<Bool, Error> in
                            
                            switch result {
                           
                            case .didGetToolTranslationsData(let toolTranslationsData):
                                downloadFinished(self.parseToolTranslationsToGodToolsToolParserManifestObjects(toolTranslations: toolTranslationsData))
                            
                            case .failedToFetchResourcesFromCache:
                                break
                            
                            case .failedToFetchTranslationManifestsFromCache(let translationIds):
                                break
                            }
                        })
                        .eraseToAnyPublisher()
                    
                
                case .failedToFetchTranslationManifestsFromCache(let translationIds):
                    
                    downloadStarted()
                    
                    return self.translationsRepository.downloadAnCacheTranslationFiles(translationIds: translationIds)
                        .flatMap({ results -> AnyPublisher<GetToolTranslationsManifestsFromCacheResult, Error> in
                                
                            return self.getToolTranslationsManifestsFromCache(determineToolTranslationsToDownload: determineToolTranslationsToDownload)
                                .eraseToAnyPublisher()
                        })
                        .flatMap({ result  -> AnyPublisher<Bool, Error> in
                            
                            switch result {
                            case .didGetToolTranslationsData(let toolTranslationsData):
                                
                                downloadFinished(self.parseToolTranslationsToGodToolsToolParserManifestObjects(toolTranslations: toolTranslationsData))
                                
                            case .failedToFetchResourcesFromCache:
                                break
                            case .failedToFetchTranslationManifestsFromCache(let translationIds):
                                break
                            }
                        })
                        .eraseToAnyPublisher()
                }
                
                return Just(true).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .sink(receiveCompletion: { completed in
                
            }, receiveValue: { (value: Bool) in
                
            })
    }
    
    private func getToolTranslationsManifestsFromCache(determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType) -> AnyPublisher<GetToolTranslationsManifestsFromCacheResult, Error> {
        
        var toolTranslationsData: [ToolTranslationData] = Array()
        var translationIdsNeededDownloading: [String] = Array()
        
        return determineToolTranslationsToDownload.determineToolTranslationsToDownload().publisher
            .mapError { error in
                return error as Error
            }
            .flatMap({ toolTranslationsToDownload -> AnyPublisher<GetToolTranslationsManifestsFromCacheResult, Error> in
                
                let resource: ResourceModel = toolTranslationsToDownload.resource
                let languages: [LanguageModel] = toolTranslationsToDownload.languages
                
                for language in languages {
                    
                    guard let translation = self.resourcesRepository.getResourceLanguageTranslation(resourceId: resource.id, languageId: language.id) else {
                        
                        return Just(.failedToFetchResourcesFromCache).setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                                        
                    guard let cachedManifest = self.translationsRepository.getTranslationManifestFromCache(manifestName: translation.manifestName) else {
                        
                        translationIdsNeededDownloading.append(translation.id)
                        
                        continue
                    }

                    let translationData = ToolTranslationData(
                        resource: resource,
                        language: language,
                        translation: translation,
                        manifestData: cachedManifest
                    )
                    
                    toolTranslationsData.append(translationData)
                }
                
                guard translationIdsNeededDownloading.isEmpty else {
                    return Just(.failedToFetchTranslationManifestsFromCache(translationIds: translationIdsNeededDownloading)).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                    
                return Just(.didGetToolTranslationsData(toolTranslationsData: toolTranslationsData)).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadResourcesFromRemote() -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        return resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFileIfNeeded()
            .flatMap({ results -> AnyPublisher<RealmResourcesCacheSyncResult, Error> in
                    
                return self.resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
        
    private func parseToolTranslationsToGodToolsToolParserManifestObjects(toolTranslations: [ToolTranslationData]) -> Result<ToolTranslationsDomainModel, Error> {
        
        guard let resource = toolTranslations.first?.resource else {
            return .failure(NSError.errorWithDescription(description: "Tool translations can't be empty."))
        }
        
        var languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest] = Array()
        
        for toolTranslation in toolTranslations {
            
            switch mobileContentParser.parse(translationManifestFileName: toolTranslation.translation.manifestName) {
            
            case .success(let manifest):
                
                let languageTranslationManifest = MobileContentRendererLanguageTranslationManifest(
                    manifest: manifest,
                    language: toolTranslation.language
                )
                
                languageTranslationManifests.append(languageTranslationManifest)
            
            case .failure(let error):
                return .failure(error)
            }
        }
        
        let toolTranslationsDomainModel = ToolTranslationsDomainModel(
            tool: resource,
            languageTranslationManifests: languageTranslationManifests
        )
        
        return .success(toolTranslationsDomainModel)
    }
    

    
    /*
    
    private func initiateDownloadStartedClosure(downloadStarted: @escaping (() -> Void)) {
        
        guard !didInitiateDownloadStartedClosure else {
            return
        }
        
        didInitiateDownloadStartedClosure = true
        downloadStarted()
    }
    
    func cancel() {
        
        removeDownloadInitialDataObservers()
        destroyDownloadTranslationsReceipt()
    }
    
    func getToolTranslations(determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, downloadStarted: @escaping (() -> Void), downloadFinished: @escaping ((_ result: Result<ToolTranslations, GetToolTranslationsError>) -> Void)) {
        
        let downloadResourcesNeeded: Bool
        let downloadTranslationsNeeded: [TranslationId]
        let fetchedToolTranslations: [ToolTranslationData]
        
        switch determineToolTranslationsToDownload.determineToolTranslationsToDownload() {
            
        case .success(let toolTranslationsToDownload):
            
            switch getToolTranslationsFromCache(resource: toolTranslationsToDownload.resource, languages: toolTranslationsToDownload.languages) {
            
            case .success(let toolTranslations):
                
                downloadResourcesNeeded = false
                downloadTranslationsNeeded = []
                fetchedToolTranslations = toolTranslations
            
            case .failure(let error):
                
                switch error {
                case .failedToFetchTranslationsFromCache(let translationIdsNeededDownloading):
                    downloadResourcesNeeded = false
                    downloadTranslationsNeeded = translationIdsNeededDownloading
                    fetchedToolTranslations = []
                }
            }
            
        case .failure(let error):
            
            switch error {
            
            case .failedToFetchResourceFromCache:
                downloadResourcesNeeded = true
                downloadTranslationsNeeded = []
                fetchedToolTranslations = []
            
            case .failedToFetchLanguageFromCache:
                downloadResourcesNeeded = true
                downloadTranslationsNeeded = []
                fetchedToolTranslations = []
            }
        }
        
        if downloadResourcesNeeded {
            
            initiateDownloadStartedClosure(downloadStarted: downloadStarted)
            
            downloadResourcesFromRemoteDatabase { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    
                    self?.getToolTranslations(
                        determineToolTranslationsToDownload: determineToolTranslationsToDownload,
                        downloadStarted: downloadStarted,
                        downloadFinished: downloadFinished
                    )
                }
            }
        }
        else if downloadTranslationsNeeded.count > 0 {
            
            initiateDownloadStartedClosure(downloadStarted: downloadStarted)
            
            downloadTranslationsFromRemoteDatabase(translationIds: downloadTranslationsNeeded) { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    
                    self?.getToolTranslations(
                        determineToolTranslationsToDownload: determineToolTranslationsToDownload,
                        downloadStarted: downloadStarted,
                        downloadFinished: downloadFinished
                    )
                }
            }
        }
        else if fetchedToolTranslations.count > 0 {
            
            let toolTranslations = ToolTranslations(
                tool: fetchedToolTranslations[0].resource,
                languageTranslationManifests: parseToolTranslationsToGodToolsToolParserManifestObjects(toolTranslations: fetchedToolTranslations)
            )
            
            downloadFinished(.success(toolTranslations))
        }
        else {
            
            downloadFinished(.failure(.failedToDownloadTranslations(translationDownloaderErrors: [])))
        }
    }
}

extension GetToolTranslationsUseCase {
    
    private func parseToolTranslationsToGodToolsToolParserManifestObjects(toolTranslations: [ToolTranslationData]) -> [MobileContentRendererLanguageTranslationManifest] {
        
        var languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest] = Array()
        
        for toolTranslation in toolTranslations {
            
            switch mobileContentParser.parse(translationManifestFileName: toolTranslation.manifestFileName) {
            
            case .success(let manifest):
                
                let languageTranslationManifest = MobileContentRendererLanguageTranslationManifest(
                    manifest: manifest,
                    language: toolTranslation.language
                )
                
                languageTranslationManifests.append(languageTranslationManifest)
            
            case .failure(let error):
                break
            }
        }
        
        return languageTranslationManifests
    }
}

extension GetToolTranslationsUseCase {
    
    private func downloadResourcesFromRemoteDatabase(completion: @escaping (() -> Void)) {
        
        removeDownloadInitialDataObservers()
        
        initialDataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.removeDownloadInitialDataObservers()
            completion()
        }
        
        initialDataDownloader.downloadInitialData()
    }
    
    private func removeDownloadInitialDataObservers() {
        initialDataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
    }
    
    private func downloadTranslationsFromRemoteDatabase(translationIds: [String], completion: @escaping (() -> Void)) {
                                       
        destroyDownloadTranslationsReceipt()
        
        downloadTranslationsReceipt = translationDownloader.downloadAndCacheTranslationManifests(translationIds: translationIds)
        
        downloadTranslationsReceipt?.completedSignal.addObserver(self, onObserve: { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.downloadTranslationsReceipt?.completedSignal.removeObserver(weakSelf)
            
            completion()
        })
    }
    
    private func destroyDownloadTranslationsReceipt() {
        
        guard let downloadTranslationsReceipt = self.downloadTranslationsReceipt else {
            return
        }
        
        downloadTranslationsReceipt.progressObserver.removeObserver(self)
        downloadTranslationsReceipt.translationDownloadedSignal.removeObserver(self)
        downloadTranslationsReceipt.completedSignal.removeObserver(self)
        downloadTranslationsReceipt.cancel()
        
        self.downloadTranslationsReceipt = nil
    }
}

extension GetToolTranslationsUseCase {
    
    private func getToolTranslationsFromCache(resource: ResourceModel, languages: [LanguageModel]) -> Result<[ToolTranslationData], GetToolTranslationsFromCacheError> {
        
        let resourceId: String = resource.id
        
        var toolTranslations: [ToolTranslationData] = Array()
        var translationIdsNeededDownloading: [String] = Array()
        
        for language in languages {
            
            guard let languageTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resourceId, languageId: language.id) else {
                continue
            }
            
            getTranslationManifest(
                resource: resource,
                language: language,
                languageTranslation: languageTranslation,
                toolTranslations: &toolTranslations,
                translationIdsNeededDownloading: &translationIdsNeededDownloading
            )
        }
        
        let shouldFallbackToEnglishLanguage: Bool = translationIdsNeededDownloading.isEmpty && toolTranslations.isEmpty
        
        if shouldFallbackToEnglishLanguage,
            let englishLanguage = languagesRepository.getLanguage(code: "en"),
            let englishLanguageTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resourceId, languageId: englishLanguage.id) {
            
            getTranslationManifest(
                resource: resource,
                language: englishLanguage,
                languageTranslation: englishLanguageTranslation,
                toolTranslations: &toolTranslations,
                translationIdsNeededDownloading: &translationIdsNeededDownloading
            )
        }
        
        guard translationIdsNeededDownloading.isEmpty else {
            return .failure(.failedToFetchTranslationsFromCache(translationIdsNeededDownloading: translationIdsNeededDownloading))
        }
        
        return .success(toolTranslations)
    }
    
    private func getTranslationManifest(resource: ResourceModel, language: LanguageModel, languageTranslation: TranslationModel, toolTranslations: inout [ToolTranslationData], translationIdsNeededDownloading: inout [String]) {
        
        let translationManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslation(translationId: languageTranslation.id)
        
        switch translationManifestResult {
            
        case .success(let translationManifestData):
            
            let toolTranslation = ToolTranslationData(
                resource: resource,
                language: language,
                translation: languageTranslation,
                manifestFileName: languageTranslation.manifestName,
                manifestData: translationManifestData.manifestXmlData
            )
            
            toolTranslations.append(toolTranslation)
            
        case .failure( _):
            translationIdsNeededDownloading.append(languageTranslation.id)
        }
    }
    
    private func fetchFirstSupportedLanguageForResource(resource: ResourceModel, languageCodes: [String]) -> LanguageModel? {
        for code in languageCodes {
            if let language = languagesRepository.getLanguage(code: code), resource.supportsLanguage(languageId: language.id) {
                return language
            }
        }
        
        return nil
    }*/
}

