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
    private let languageSettingsService: LanguageSettingsService
    private let deviceLanguage: DeviceLanguageType
    
    private var downloadResourcesOperation: OperationQueue?
    
    let resourcesCache: RealmResourcesCache
    let attachmentsFileCache: AttachmentsFileCache
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<Result<ResourcesDownloaderResult, ResourcesDownloaderError>?> = ObservableValue(value: nil)
    
    required init(realmDatabase: RealmDatabase, resourcesDownloader: ResourcesDownloader, attachmentsDownloader: AttachmentsDownloader, languageSettingsService: LanguageSettingsService, deviceLanguage: DeviceLanguageType) {
        
        self.realmDatabase = realmDatabase
        self.resourcesDownloader = resourcesDownloader
        self.attachmentsDownloader = attachmentsDownloader
        self.languageSettingsService = languageSettingsService
        self.deviceLanguage = deviceLanguage
        self.resourcesCache = resourcesDownloader.resourcesCache
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
            
            guard let resourceDownloadResult = result else {
                return
            }
            
            self?.downloadLatestAttachmentsIfNeeded(result: resourceDownloadResult)
            
            self?.choosePrimaryLanguageIfNeeded { [weak self] in
                
                self?.handleDownloadDataCompleted(result: resourceDownloadResult)
            }
        }
        
        started.accept(value: true)
                
        downloadResourcesOperation = resourcesDownloader.downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments()
    }

    private func handleDownloadDataCompleted(result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) {
        
        resourcesDownloader.completed.removeObserver(self)
        started.accept(value: false)
        completed.accept(value: result)
        downloadResourcesOperation = nil
    }
    
    private func downloadLatestAttachmentsIfNeeded(result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) {
        switch result {
        case .success(let resourcesDownloaderResult):
            attachmentsDownloader.downloadAndCacheAttachments(from: resourcesDownloaderResult)
        case .failure( _):
            break
        }
    }
    
    private func choosePrimaryLanguageIfNeeded(complete: @escaping (() -> Void)) {
        
        let languageSettingsService: LanguageSettingsService = self.languageSettingsService
        let deviceLanguage: DeviceLanguageType = self.deviceLanguage
        
        guard languageSettingsService.primaryLanguage.value == nil else {
            complete()
            return
        }
        
        realmDatabase.background { (realm: Realm) in
            
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
                languageSettingsService.languageSettingsCache.cachePrimaryLanguageId(languageId: primaryLanguage.id)
            }
            
            complete()
        }// end realmDatabase.background
    }
}
