//
//  InitialDataDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class InitialDataDownloader: NSObject {
    
    private let realmDatabase: RealmDatabase
    private let resourcesRepository: ResourcesRepository
    private let initialDeviceResourcesLoader: InitialDeviceResourcesLoader
    private let resourcesDownloader: ResourcesDownloader
    private let resourcesSync: InitialDataDownloaderResourcesSync
    private let languagesCache: RealmLanguagesCache
    private let resourcesCleanUp: ResourcesCleanUp
    private let attachmentsDownloader: AttachmentsDownloader
    private let languageSettingsCache: LanguageSettingsCacheType
    private let favoritedResourceTranslationDownloader : FavoritedResourceTranslationDownloader
    
    private var downloadAndCacheInitialData: AnyCancellable?
    private var downloadResourcesOperation: OperationQueue?
    
    private(set) var didComplete: Bool = false
        
    let resourcesCache: ResourcesCache
    let attachmentsFileCache: AttachmentsFileCache
    
    // observables
    @available(*, deprecated)
    let cachedResourcesAvailable: ObservableValue<Bool> = ObservableValue(value: false)
    @available(*, deprecated)
    let resourcesUpdatedFromRemoteDatabase: SignalValue<InitialDataDownloaderError?> = SignalValue()
    @available(*, deprecated)
    let attachmentsDownload: ObservableValue<DownloadAttachmentsReceipt?> = ObservableValue(value: nil)
    @available(*, deprecated)
    let latestTranslationsDownload: ObservableValue<DownloadResourceTranslationsReceipts?> = ObservableValue(value: nil)
    
    required init(realmDatabase: RealmDatabase, resourcesRepository: ResourcesRepository, initialDeviceResourcesLoader: InitialDeviceResourcesLoader, resourcesDownloader: ResourcesDownloader, resourcesSync: InitialDataDownloaderResourcesSync, resourcesCache: ResourcesCache, languagesCache: RealmLanguagesCache, resourcesCleanUp: ResourcesCleanUp, attachmentsDownloader: AttachmentsDownloader, languageSettingsCache: LanguageSettingsCacheType, favoritedResourceTranslationDownloader: FavoritedResourceTranslationDownloader) {
        
        self.realmDatabase = realmDatabase
        self.resourcesRepository = resourcesRepository
        self.initialDeviceResourcesLoader = initialDeviceResourcesLoader
        self.resourcesDownloader = resourcesDownloader
        self.resourcesSync = resourcesSync
        self.languagesCache = languagesCache
        self.resourcesCleanUp = resourcesCleanUp
        self.attachmentsDownloader = attachmentsDownloader
        self.languageSettingsCache = languageSettingsCache
        self.resourcesCache = resourcesCache
        self.attachmentsFileCache = attachmentsDownloader.attachmentsFileCache
        self.favoritedResourceTranslationDownloader = favoritedResourceTranslationDownloader
        
        super.init()
        
        if resourcesSync.resourcesAvailable {
            cachedResourcesAvailable.accept(value: true)
        }
    }
    
    deinit {

    }
    
    func downloadInitialData() {
        
        downloadAndCacheInitialData = resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .sink(receiveCompletion: { completed in
                print(completed)
            }, receiveValue: { (result: RealmResourcesCacheSyncResult) in
                print(result)
                self.cachedResourcesAvailable.accept(value: true)
                self.resourcesUpdatedFromRemoteDatabase.accept(value: nil)
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
    
    private func checkForParallelLanguageDeletedAndClearFromSettings(realm: Realm) {
        
        guard let settingsParallelLanguageId = languageSettingsCache.parallelLanguageId.value, !settingsParallelLanguageId.isEmpty else {
            return
        }
        
        let cachedParallelLanguage: RealmLanguage? = languagesCache.getLanguage(realm: realm, id: settingsParallelLanguageId)
        let parallelLanguageRemoved: Bool = cachedParallelLanguage == nil
        
        if parallelLanguageRemoved {
            languageSettingsCache.deleteParallelLanguageId()
        }
    }
}
