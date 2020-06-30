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
    private let attachmentsDownloader: AttachmentsDownloader
    private let languageSettingsCache: LanguageSettingsCacheType
    private let deviceLanguage: DeviceLanguageType
    private let favoritedResourceTranslationDownloader : FavoritedResourceTranslationDownloader
    
    private var downloadResourcesOperation: OperationQueue?
    
    private(set) var completedResult: Result<ResourcesDownloaderResult, ResourcesDownloaderError>?
    
    let resourcesCache: ResourcesCache
    let languagesCache: LanguagesCache
    let attachmentsFileCache: AttachmentsFileCache
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: Signal = Signal()
    
    required init(realmDatabase: RealmDatabase, initialDeviceResourcesLoader: InitialDeviceResourcesLoader, resourcesDownloader: ResourcesDownloader, attachmentsDownloader: AttachmentsDownloader, languageSettingsCache: LanguageSettingsCacheType, deviceLanguage: DeviceLanguageType, favoritedResourceTranslationDownloader: FavoritedResourceTranslationDownloader) {
        
        self.realmDatabase = realmDatabase
        self.initialDeviceResourcesLoader = initialDeviceResourcesLoader
        self.resourcesDownloader = resourcesDownloader
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
        resourcesDownloader.completed.removeObserver(self)
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

    func downloadInitialData() {
        
        if downloadResourcesOperation != nil {
            assertionFailure("InitialDataDownloader: resourcesDownloader is already running and only ever needs to run once on startup.")
            return
        }
        
        // completed downloading and caching resources
        resourcesDownloader.completed.addObserver(self) { [weak self] (result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>?) in
            DispatchQueue.main.async { [weak self] in
                
                guard let resourceDownloadResult = result else {
                    return
                }
                
                guard let dataDownloader = self else {
                    return
                }
                
                self?.downloadLatestAttachmentsIfNeeded(result: resourceDownloadResult)
                
                self?.choosePrimaryLanguageIfNeeded()
                
                self?.downloadLatestTranslationsForFavoritedResources()
                
                dataDownloader.completedResult = result
                dataDownloader.resourcesDownloader.completed.removeObserver(dataDownloader)
                dataDownloader.started.accept(value: false)
                dataDownloader.completed.accept()
                dataDownloader.downloadResourcesOperation = nil
            }
        }
        
        started.accept(value: true)
        
        initialDeviceResourcesLoader.loadAndCacheInitialDeviceResourcesIfNeeded(completeOnMain: { [weak self] in
            
            self?.downloadResourcesOperation = self?.resourcesDownloader.downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments()
        })
    }
    
    private func downloadLatestAttachmentsIfNeeded(result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) {
        switch result {
        case .success(let resourcesDownloaderResult):
            attachmentsDownloader.downloadAndCacheAttachments(from: resourcesDownloaderResult)
        case .failure( _):
            break
        }
    }
    
    private func downloadLatestTranslationsForFavoritedResources() {
        
        favoritedResourceTranslationDownloader.downloadAllDownloadedLanguagesTranslationsForAllFavoritedResources()
    }
    
    private func choosePrimaryLanguageIfNeeded() {
        
        let realm: Realm = realmDatabase.mainThreadRealm
        
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
