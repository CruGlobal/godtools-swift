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

class InitialDataDownloader {
    
    private let resourcesRepository: ResourcesRepository
    private let initialDeviceResourcesLoader: InitialDeviceResourcesLoader
    @available(*, deprecated)
    private let resourcesDownloader: ResourcesDownloader
    private let resourcesSync: InitialDataDownloaderResourcesSync
    @available(*, deprecated)
    private let languagesCache: RealmLanguagesCache
    @available(*, deprecated)
    private let resourcesCleanUp: ResourcesCleanUp
    @available(*, deprecated)
    private let attachmentsDownloader: AttachmentsDownloader
    
    private var cancellables = Set<AnyCancellable>()
                
    @available(*, deprecated)
    let resourcesCache: ResourcesCache
    @available(*, deprecated)
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
    
    required init(resourcesRepository: ResourcesRepository, initialDeviceResourcesLoader: InitialDeviceResourcesLoader, resourcesDownloader: ResourcesDownloader, resourcesSync: InitialDataDownloaderResourcesSync, resourcesCache: ResourcesCache, languagesCache: RealmLanguagesCache, resourcesCleanUp: ResourcesCleanUp, attachmentsDownloader: AttachmentsDownloader) {
        
        self.resourcesRepository = resourcesRepository
        self.initialDeviceResourcesLoader = initialDeviceResourcesLoader
        self.resourcesDownloader = resourcesDownloader
        self.resourcesSync = resourcesSync
        self.languagesCache = languagesCache
        self.resourcesCleanUp = resourcesCleanUp
        self.attachmentsDownloader = attachmentsDownloader
        self.resourcesCache = resourcesCache
        self.attachmentsFileCache = attachmentsDownloader.attachmentsFileCache
                
        if resourcesSync.resourcesAvailable {
            cachedResourcesAvailable.accept(value: true)
        }
    }
    
    func downloadInitialData() {
        
        resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .sink(receiveCompletion: { completed in
                print(completed)
            }, receiveValue: { [weak self] (result: RealmResourcesCacheSyncResult) in
                print(result)
                self?.cachedResourcesAvailable.accept(value: true)
                self?.resourcesUpdatedFromRemoteDatabase.accept(value: nil)
            })
            .store(in: &cancellables)
    }
}
