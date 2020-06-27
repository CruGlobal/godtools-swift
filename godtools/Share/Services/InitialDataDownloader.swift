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
    private let resourcesDownloader: ResourcesDownloader
    private let attachmentsDownloader: AttachmentsDownloader
    private let languageSettingsCache: LanguageSettingsCacheType
    private let deviceLanguage: DeviceLanguageType
    
    private var downloadResourcesOperation: OperationQueue?
    
    let resourcesCache: ResourcesCache
    let languagesCache: LanguagesCache
    let attachmentsFileCache: AttachmentsFileCache
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<Result<ResourcesDownloaderResult, ResourcesDownloaderError>?> = ObservableValue(value: nil)
    
    required init(realmDatabase: RealmDatabase, resourcesDownloader: ResourcesDownloader, attachmentsDownloader: AttachmentsDownloader, languageSettingsCache: LanguageSettingsCacheType, deviceLanguage: DeviceLanguageType) {
        
        self.realmDatabase = realmDatabase
        self.resourcesDownloader = resourcesDownloader
        self.attachmentsDownloader = attachmentsDownloader
        self.languageSettingsCache = languageSettingsCache
        self.deviceLanguage = deviceLanguage
        self.resourcesCache = ResourcesCache(realmDatabase: realmDatabase)
        self.languagesCache = LanguagesCache(realmDatabase: realmDatabase)
        self.attachmentsFileCache = attachmentsDownloader.attachmentsFileCache
        
        super.init()
    }
    
    deinit {
        resourcesDownloader.completed.removeObserver(self)
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

    func downloadData() {
        
        if downloadResourcesOperation != nil {
            assertionFailure("InitialDataDownloader: resourcesDownloader is already running and only ever needs to run once on startup.")
            return
        }
        
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
                
                dataDownloader.resourcesDownloader.completed.removeObserver(dataDownloader)
                dataDownloader.started.accept(value: false)
                dataDownloader.completed.accept(value: result)
                dataDownloader.downloadResourcesOperation = nil
            }
        }
        
        started.accept(value: true)
                
        downloadResourcesOperation = resourcesDownloader.downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments()
    }
    
    private func downloadLatestAttachmentsIfNeeded(result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) {
        switch result {
        case .success(let resourcesDownloaderResult):
            attachmentsDownloader.downloadAndCacheAttachments(from: resourcesDownloaderResult)
        case .failure( _):
            break
        }
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
