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
    private let resourcesCleanUp: ResourcesCleanUp
    private let attachmentsDownloader: AttachmentsDownloader
    private let languageSettingsCache: LanguageSettingsCacheType
    private let deviceLanguage: DeviceLanguageType
    private let favoritedResourceTranslationDownloader : FavoritedResourceTranslationDownloader
    
    private var downloadResourcesOperation: OperationQueue?
    
    private(set) var didComplete: Bool = false
        
    let resourcesCache: ResourcesCache
    let languagesCache: LanguagesCache
    let attachmentsFileCache: AttachmentsFileCache
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: Signal = Signal()
    
    required init(realmDatabase: RealmDatabase, initialDeviceResourcesLoader: InitialDeviceResourcesLoader, resourcesDownloader: ResourcesDownloader, realmResourcesCache: RealmResourcesCache, resourcesCleanUp: ResourcesCleanUp, attachmentsDownloader: AttachmentsDownloader, languageSettingsCache: LanguageSettingsCacheType, deviceLanguage: DeviceLanguageType, favoritedResourceTranslationDownloader: FavoritedResourceTranslationDownloader) {
        
        self.realmDatabase = realmDatabase
        self.initialDeviceResourcesLoader = initialDeviceResourcesLoader
        self.resourcesDownloader = resourcesDownloader
        self.realmResourcesCache = realmResourcesCache
        self.resourcesCleanUp = resourcesCleanUp
        self.attachmentsDownloader = attachmentsDownloader
        self.languageSettingsCache = languageSettingsCache
        self.deviceLanguage = deviceLanguage
        self.resourcesCache = ResourcesCache(realmDatabase: realmDatabase)
        self.languagesCache = LanguagesCache(realmDatabase: realmDatabase)
        self.attachmentsFileCache = attachmentsDownloader.attachmentsFileCache
        self.favoritedResourceTranslationDownloader = favoritedResourceTranslationDownloader
        
        super.init()
    }
    
    deinit {

    }
    
    var initialDeviceResourcesCompleted: Signal {
        return initialDeviceResourcesLoader.completed
    }

    var attachmentsDownloaderStarted: ObservableValue<Bool> {
        return attachmentsDownloader.started
    }
    
    var attachmentsDownloaderProgress: ObservableValue<Double> {
        return attachmentsDownloader.progress
    }
    
    var attachmentDownloaded: SignalValue<Result<AttachmentFile, AttachmentsDownloaderError>> {
        return attachmentsDownloader.attachmentDownloaded
    }
    
    var attachmentsDownloaderCompleted: Signal {
        return attachmentsDownloader.completed
    }
    
    var resourcesExistInDatabase: Bool {
        return !realmDatabase.isEmpty
    }

    func downloadInitialData() {
        
        if downloadResourcesOperation != nil || started.value {
            assertionFailure("InitialDataDownloader: resourcesDownloader is already running and only ever needs to run once on startup.")
            return
        }
        
        started.accept(value: true)
        
        let realmDatabase: RealmDatabase = self.realmDatabase
        let realmResourcesCache: RealmResourcesCache = self.realmResourcesCache
        
        initialDeviceResourcesLoader.loadAndCacheInitialDeviceResourcesIfNeeded(completeOnMain: { [weak self] in
            
            self?.downloadResourcesOperation = self?.resourcesDownloader.downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments(complete: { [weak self] (result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) in
                
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
                        self?.resourcesCleanUp.bulkDeleteResourcesIfNeeded(realm: realm, cacheResult: resourcesCacheResult)
                        self?.attachmentsDownloader.downloadAndCacheAttachments(from: resourcesCacheResult)
                        self?.favoritedResourceTranslationDownloader.downloadAllDownloadedLanguagesTranslationsForAllFavoritedResources()
                        self?.choosePrimaryLanguageIfNeeded(realm: realm)
                        
                    case .failure(let cacheError):
                        self?.handleDownloadInitialDataCompleted(error: .failedToCacheResources(error: cacheError))
                        return
                    }
                    
                    self?.handleDownloadInitialDataCompleted(error: nil)
                }
            })
        })
    }
    
    private func handleDownloadInitialDataCompleted(error: InitialDataDownloaderError?) {
        
        didComplete = true
        started.accept(value: false)
        completed.accept()
        downloadResourcesOperation = nil
    }
    
    private func choosePrimaryLanguageIfNeeded(realm: Realm) {
                
        let cachedPrimaryLanguageId: String = languageSettingsCache.primaryLanguageId.value ?? ""
        let primaryLanguageIsCached: Bool = !cachedPrimaryLanguageId.isEmpty
        
        if primaryLanguageIsCached {
            return
        }
                
        let realmLanguages: Results<RealmLanguage> = realm.objects(RealmLanguage.self)
        let preferredDeviceLanguageCodes: [String] = deviceLanguage.possibleLocaleCodes(locale: Locale.current)
        
        var deviceLanguage: RealmLanguage?
        
        for languageCode in preferredDeviceLanguageCodes {
            if let language = realmLanguages.filter("code = '\(languageCode)'").first {
                deviceLanguage = language
                break
            }
        }
        
        let primaryLanguage: RealmLanguage?
        
        if let deviceLanguage = deviceLanguage {
            primaryLanguage = deviceLanguage
        }
        else if let englishLanguage = realmLanguages.filter("code = 'en'").first {
            primaryLanguage = englishLanguage
        }
        else {
            primaryLanguage = nil
        }
        
        if let primaryLanguage = primaryLanguage {
            languageSettingsCache.cachePrimaryLanguageId(languageId: primaryLanguage.id)
        }
    }
}
