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
                    
    // observables
    @available(*, deprecated)
    let resourcesUpdatedFromRemoteDatabase: SignalValue<InitialDataDownloaderError?> = SignalValue()
    @available(*, deprecated)
    let attachmentsDownload: ObservableValue<DownloadAttachmentsReceipt?> = ObservableValue(value: nil)
    @available(*, deprecated)
    let latestTranslationsDownload: ObservableValue<DownloadResourceTranslationsReceipts?> = ObservableValue(value: nil)
    
    required init(resourcesRepository: ResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
    }
    
    func downloadInitialData() {
        
        resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .sink(receiveCompletion: { completed in

            }, receiveValue: { (result: RealmResourcesCacheSyncResult) in
                
            })
            .store(in: &cancellables)
    }
}
