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
    private let resourcesSync: InitialDataDownloaderResourcesSync
    @available(*, deprecated)
    private let languagesCache: RealmLanguagesCache
    @available(*, deprecated)
    private let resourcesCleanUp: ResourcesCleanUp
    
    private var cancellables = Set<AnyCancellable>()
                
    @available(*, deprecated)
    let resourcesCache: ResourcesCache
    
    // observables
    @available(*, deprecated)
    let cachedResourcesAvailable: ObservableValue<Bool> = ObservableValue(value: false)
    @available(*, deprecated)
    let resourcesUpdatedFromRemoteDatabase: SignalValue<InitialDataDownloaderError?> = SignalValue()
    @available(*, deprecated)
    let attachmentsDownload: ObservableValue<DownloadAttachmentsReceipt?> = ObservableValue(value: nil)
    @available(*, deprecated)
    let latestTranslationsDownload: ObservableValue<DownloadResourceTranslationsReceipts?> = ObservableValue(value: nil)
    
    required init(resourcesRepository: ResourcesRepository, resourcesSync: InitialDataDownloaderResourcesSync, resourcesCache: ResourcesCache, languagesCache: RealmLanguagesCache, resourcesCleanUp: ResourcesCleanUp) {
        
        self.resourcesRepository = resourcesRepository
        self.resourcesSync = resourcesSync
        self.languagesCache = languagesCache
        self.resourcesCleanUp = resourcesCleanUp
        self.resourcesCache = resourcesCache
                
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
            }, receiveValue: { [weak self] (result: RealmResourcesCacheSyncResult) in
                self?.cachedResourcesAvailable.accept(value: true)
                self?.resourcesUpdatedFromRemoteDatabase.accept(value: nil)
            })
            .store(in: &cancellables)
    }
}
