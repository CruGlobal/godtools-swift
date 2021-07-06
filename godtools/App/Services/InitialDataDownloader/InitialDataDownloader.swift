//
//  InitialDataDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class InitialDataDownloader: NSObject {
    
    private let realmDatabase: RealmDatabase
    private let initialDeviceResourcesLoader: InitialDeviceResourcesLoader
    private let resourcesDownloader: ResourcesDownloader
    private let realmResourcesCache: RealmResourcesCache
    private let languagesCache: RealmLanguagesCache
    private let resourcesCleanUp: ResourcesCleanUp
    private let attachmentsDownloader: AttachmentsDownloader
    private let languageSettingsCache: LanguageSettingsCacheType
    private let favoritedResourceTranslationDownloader : FavoritedResourceTranslationDownloader
    
    private var downloadResourcesOperation: OperationQueue?
    
    private(set) var didComplete: Bool = false
        
    let resourcesCache: ResourcesCache
    let attachmentsFileCache: AttachmentsFileCache
    
    // observables
    let cachedResourcesAvailable: ObservableValue<Bool> = ObservableValue(value: false)
    let resourcesUpdatedFromRemoteDatabase: SignalValue<InitialDataDownloaderError?> = SignalValue()
    let attachmentsDownload: ObservableValue<DownloadAttachmentsReceipt?> = ObservableValue(value: nil)
    let latestTranslationsDownload: ObservableValue<DownloadResourceTranslationsReceipts?> = ObservableValue(value: nil)
    
    required init(realmDatabase: RealmDatabase, initialDeviceResourcesLoader: InitialDeviceResourcesLoader, resourcesDownloader: ResourcesDownloader, realmResourcesCache: RealmResourcesCache, resourcesCache: ResourcesCache, languagesCache: RealmLanguagesCache, resourcesCleanUp: ResourcesCleanUp, attachmentsDownloader: AttachmentsDownloader, languageSettingsCache: LanguageSettingsCacheType, favoritedResourceTranslationDownloader: FavoritedResourceTranslationDownloader) {
        
        self.realmDatabase = realmDatabase
        self.initialDeviceResourcesLoader = initialDeviceResourcesLoader
        self.resourcesDownloader = resourcesDownloader
        self.realmResourcesCache = realmResourcesCache
        self.languagesCache = languagesCache
        self.resourcesCleanUp = resourcesCleanUp
        self.attachmentsDownloader = attachmentsDownloader
        self.languageSettingsCache = languageSettingsCache
        self.resourcesCache = resourcesCache
        self.attachmentsFileCache = attachmentsDownloader.attachmentsFileCache
        self.favoritedResourceTranslationDownloader = favoritedResourceTranslationDownloader
        
        super.init()
        
        if realmResourcesCache.resourcesAvailable {
            cachedResourcesAvailable.accept(value: true)
        }
    }
    
    deinit {

    }
    
    func downloadInitialData() {
        
        if downloadResourcesOperation != nil {
            return
        }
                        
        let realmDatabase: RealmDatabase = self.realmDatabase
        let realmResourcesCache: RealmResourcesCache = self.realmResourcesCache
        let cachedResourcesAvailableAlreadySetToTrue: Bool = cachedResourcesAvailable.value
        
        initialDeviceResourcesLoader.loadAndCacheInitialDeviceResourcesIfNeeded(completeOnMain: { [weak self] in
            
            if realmResourcesCache.resourcesAvailable && !cachedResourcesAvailableAlreadySetToTrue {
                self?.cachedResourcesAvailable.accept(value: true)
            }
                        
            self?.downloadResourcesOperation = self?.resourcesDownloader.downloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachments(complete: { [weak self] (result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) in
                
                let resourcesDownloaderResult: ResourcesDownloaderResult?
                let resourcesDownloadError: ResourcesDownloaderError?
                
                switch result {
                
                case .success(let downloadResult):
                    resourcesDownloaderResult = downloadResult
                    resourcesDownloadError = nil
                    
                case .failure(let downloadError):
                    resourcesDownloaderResult = nil
                    resourcesDownloadError = downloadError
                }
                
                if let resourcesDownloadError = resourcesDownloadError {
                    self?.handleDownloadInitialDataCompleted(error: .failedToDownloadResources(error: resourcesDownloadError))
                    return
                }
                
                guard let downloaderResult = resourcesDownloaderResult else {
                    self?.handleDownloadInitialDataCompleted(error: .failedToGetResourcesDownloaderResult)
                    return
                }
                
                realmDatabase.background { [weak self] (realm: Realm) in
                                        
                    let cacheResult: Result<ResourcesCacheResult, Error> = realmResourcesCache.cacheResources(realm: realm, downloaderResult: downloaderResult)
                    
                    switch cacheResult {
                    
                    case .success(let resourcesCacheResult):
                        
                        self?.initialDeviceResourcesLoader.choosePrimaryLanguageIfNeeded(realm: realm)
                        
                        self?.initialDeviceResourcesLoader.chooseParallelLanguageIfNeeded(realm: realm)
                        
                        self?.handleDownloadInitialDataCompleted(error: nil)
                        
                        self?.downloadLatestAttachments(resourcesCacheResult: resourcesCacheResult)
                        
                        self?.downloadLatestTranslations(realm: realm)
                        
                        self?.resourcesCleanUp.bulkDeleteResourcesIfNeeded(realm: realm, cacheResult: resourcesCacheResult)
                        
                    case .failure(let cacheError):
                        self?.handleDownloadInitialDataCompleted(error: .failedToCacheResources(error: cacheError))
                        return
                    }
                }
            })
        })
    }
    
    private func handleDownloadInitialDataCompleted(error: InitialDataDownloaderError?) {
        
        didComplete = true
        downloadResourcesOperation = nil
        
        resourcesUpdatedFromRemoteDatabase.accept(value: error)
    }
    
    private func downloadLatestAttachments(resourcesCacheResult: ResourcesCacheResult) {
        
        let downloadAttachmentsReceipt: DownloadAttachmentsReceipt? = attachmentsDownloader.downloadAndCacheAttachments(
            attachmentFiles: resourcesCacheResult.latestAttachmentFiles
        )
        
        attachmentsDownload.accept(value: downloadAttachmentsReceipt)
    }
    
    private func downloadLatestTranslations(realm: Realm) {
        
        let downloadTranslationsReceipts: DownloadResourceTranslationsReceipts = favoritedResourceTranslationDownloader.downloadAllDownloadedLanguagesTranslationsForAllFavoritedResources(realm: realm)
        
        latestTranslationsDownload.accept(value: downloadTranslationsReceipts)
    }
}

// MARK: - Languages

extension InitialDataDownloader {
    
    func getStoredLanguage(id: String) -> LanguageModel? {
        
        if let cachedLanguage = languagesCache.getLanguage(id: id) {
            return LanguageModel(model: cachedLanguage)
        }
        
        return nil
    }
    
    func getStoredLanguage(code: String) -> LanguageModel? {
        
        if let cachedLanguage = languagesCache.getLanguage(code: code) {
            return LanguageModel(model: cachedLanguage)
        }
        
        return nil
    }
    
    func getStoredLanguages() -> [LanguageModel] {
        
        return languagesCache.getLanguages().map({LanguageModel(model: $0)})
    }
    
    func fetchFirstSupportedLanguageForResource(resource: ResourceModel, codes: [String]) -> LanguageModel? {
        for code in codes {
            if let language = getStoredLanguage(code: code), resource.supportsLanguage(languageId: language.id) {
                return language
            }
        }
        
        return nil
    }
}
