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
    
    required init(resourcesRepository: ResourcesRepository, resourcesCache: ResourcesCache) {
        
        self.resourcesRepository = resourcesRepository
        self.resourcesCache = resourcesCache
        
        // TODO: This can be removed after we do some refactoring to remove the ObservableValues and SignalValues in this class which will be replaced by domain layer use cases. ~Levi
        if resourcesRepository.numberOfResources > 0 {
            cachedResourcesAvailable.accept(value: true)
        }
    }
    
    func downloadInitialData() {
        
        resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .sink(receiveCompletion: { [weak self] completed in
                self?.cachedResourcesAvailable.accept(value: true)
                self?.resourcesUpdatedFromRemoteDatabase.accept(value: nil)
            }, receiveValue: { (result: RealmResourcesCacheSyncResult) in
                
            })
            .store(in: &cancellables)
    }
}
