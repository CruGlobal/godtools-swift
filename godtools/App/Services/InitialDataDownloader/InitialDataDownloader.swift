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
    
    private let resourcesRepository: ResourcesRepository
    private let getAllFavoritedResourcesLatestTranslationFilesUseCase: GetAllFavoritedResourcesLatestTranslationFilesUseCase
    private let initialDeviceResourcesLoader: InitialDeviceResourcesLoader
    private let resourcesDownloader: ResourcesDownloader
    private let resourcesSync: InitialDataDownloaderResourcesSync
    private let languagesCache: RealmLanguagesCache
    private let resourcesCleanUp: ResourcesCleanUp
    private let attachmentsDownloader: AttachmentsDownloader
    
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
    
    required init(resourcesRepository: ResourcesRepository, getAllFavoritedResourcesLatestTranslationFilesUseCase: GetAllFavoritedResourcesLatestTranslationFilesUseCase, initialDeviceResourcesLoader: InitialDeviceResourcesLoader, resourcesDownloader: ResourcesDownloader, resourcesSync: InitialDataDownloaderResourcesSync, resourcesCache: ResourcesCache, languagesCache: RealmLanguagesCache, resourcesCleanUp: ResourcesCleanUp, attachmentsDownloader: AttachmentsDownloader) {
        
        self.resourcesRepository = resourcesRepository
        self.getAllFavoritedResourcesLatestTranslationFilesUseCase = getAllFavoritedResourcesLatestTranslationFilesUseCase
        self.initialDeviceResourcesLoader = initialDeviceResourcesLoader
        self.resourcesDownloader = resourcesDownloader
        self.resourcesSync = resourcesSync
        self.languagesCache = languagesCache
        self.resourcesCleanUp = resourcesCleanUp
        self.attachmentsDownloader = attachmentsDownloader
        self.resourcesCache = resourcesCache
        self.attachmentsFileCache = attachmentsDownloader.attachmentsFileCache
        
        super.init()
        
        if resourcesSync.resourcesAvailable {
            cachedResourcesAvailable.accept(value: true)
        }
    }
    
    deinit {

    }
    
//    func syncInitialData() -> AnyPublisher<Bool, URLResponseError> {
//
//        return resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
//            .flatMap({ syncResult -> AnyPublisher<Bool, URLResponseError> in
//
//                return self.getAl
//            })
//    }
    
    func downloadInitialData() {
        
        downloadAndCacheInitialData = resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .sink(receiveCompletion: { completed in
                print(completed)
            }, receiveValue: { [weak self] (result: RealmResourcesCacheSyncResult) in
                print(result)
                self?.cachedResourcesAvailable.accept(value: true)
                self?.resourcesUpdatedFromRemoteDatabase.accept(value: nil)
                
                self?.getAllFavoritedResourcesLatestTranslationFilesUseCase.getLatestTranslationFilesForAllFavoritedResources()
            })
    }
}
