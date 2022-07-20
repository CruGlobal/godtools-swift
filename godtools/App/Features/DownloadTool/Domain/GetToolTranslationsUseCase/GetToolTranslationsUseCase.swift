//
//  GetToolTranslationsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolTranslationsUseCase: NSObject {
    
    typealias TranslationId = String
    
    private let initialDataDownloader: InitialDataDownloader
    private let translationsRepository: TranslationsRepository
    private let resourcesCache: ResourcesCache
    private let languagesRepository: LanguagesRepository
    private let mobileContentParser: MobileContentParser
    private let languageSettingsService: LanguageSettingsService
    
    private var didInitiateDownloadStartedClosure: Bool = false
    private var downloadTranslationsReceipt: DownloadTranslationsReceipt?
    
    private var downloadingTranslations: AnyCancellable?
    
    init(initialDataDownloader: InitialDataDownloader, translationsRepository: TranslationsRepository, resourcesCache: ResourcesCache, languagesRepository: LanguagesRepository, mobileContentParser: MobileContentParser, languageSettingsService: LanguageSettingsService) {
        
        self.initialDataDownloader = initialDataDownloader
        self.translationsRepository = translationsRepository
        self.resourcesCache = resourcesCache
        self.languagesRepository = languagesRepository
        self.mobileContentParser = mobileContentParser
        self.languageSettingsService = languageSettingsService
        
        super.init()
    }
    
    deinit {
        removeDownloadInitialDataObservers()
        destroyDownloadTranslationsReceipt()
    }
    
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
            
            // TODO: Implement in GT-1448. ~Levi
            
            downloadTranslationsFromRemoteDatabase(translationIds: downloadTranslationsNeeded)
            
            /*
            downloadTranslationsFromRemoteDatabase(translationIds: downloadTranslationsNeeded) { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    
                    self?.getToolTranslations(
                        determineToolTranslationsToDownload: determineToolTranslationsToDownload,
                        downloadStarted: downloadStarted,
                        downloadFinished: downloadFinished
                    )
                }
            }*/
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
        
        initialDataDownloader.didDownloadAndCacheResources.addObserver(self) { [weak self] (didDownloadAndCacheResources: Bool) in
            
            guard let weakSelf = self else {
                return
            }
            
            if didDownloadAndCacheResources {
                weakSelf.removeDownloadInitialDataObservers()
                completion()
            }
        }
        
        initialDataDownloader.downloadInitialData()
    }
    
    private func removeDownloadInitialDataObservers() {
        initialDataDownloader.didDownloadAndCacheResources.removeObserver(self)
    }
    
    private func downloadTranslationsFromRemoteDatabase(translationIds: [String]) {
           
        print("Implement...")
        
        downloadingTranslations = translationsRepository.downloadAnCacheTranslationFiles(translationIds: translationIds)
            .sink { error in
                print("ERROR: \(error)")
            } receiveValue: { (files: [TranslationFilesDataModel]) in
                
                print("did download and cache files: \(files)")
                
                for file in files {
                    
                    print("translationId: \(file.translationId)")
                    print("  manifest: \(file.manifestFileName)")
                    print("  fileCacheLocations: \(file.fileCacheLocations)")
                }
            }
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
        
        let translationId: String = languageTranslation.id
        
        // TODO: Uncomment code below after testing. GT-1448. ~Levi
        // for now just say translationIdsNeededDownloading
        translationIdsNeededDownloading.append(translationId)
        
        /*
        
        if let translation = translationsRepository.getTranslation(translationId: translationId),  let manifestData = translationsRepository.getTranslationManifest(translationId: translationId) {
            
            let toolTranslation = ToolTranslationData(
                resource: resource,
                language: language,
                translation: languageTranslation,
                manifestFileName: translation.manifestName,
                manifestData: manifestData
            )
            
            toolTranslations.append(toolTranslation)
        }
        else {
            
            translationIdsNeededDownloading.append(translationId)
        }*/
    }
    
    private func fetchFirstSupportedLanguageForResource(resource: ResourceModel, languageCodes: [String]) -> LanguageModel? {
        for code in languageCodes {
            if let language = languagesRepository.getLanguage(code: code), resource.supportsLanguage(languageId: language.id) {
                return language
            }
        }
        
        return nil
    }
}
