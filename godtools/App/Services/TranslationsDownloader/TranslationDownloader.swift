//
//  TranslationDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RequestOperation

// TODO: Remove in GT-1448. ~Levi
class TranslationDownloader: NSObject {
    
    typealias TranslationId = String
    
    private let realmDatabase: RealmDatabase
    private let resourcesCache: ResourcesCache
    private let translationsApi: MobileContentTranslationsApi
    private let translationsFileCache: TranslationsFileCache
            
    required init(realmDatabase: RealmDatabase, resourcesCache: ResourcesCache, translationsApi: MobileContentTranslationsApi, translationsFileCache: TranslationsFileCache) {
        
        self.realmDatabase = realmDatabase
        self.resourcesCache = resourcesCache
        self.translationsApi = translationsApi
        self.translationsFileCache = translationsFileCache
        
        super.init()
    }
    
    func fetchTranslationManifestAndDownloadIfNeeded(resourceId: String, languageId: String, cache: @escaping ((_ translationManifest: TranslationManifestData) -> Void), downloadStarted: @escaping (() -> Void), downloadComplete: @escaping ((_ result: Result<TranslationManifestData, TranslationDownloaderError>) -> Void)) {
        
        let translation: TranslationModel? = resourcesCache.getResourceLanguageTranslation(
            resourceId: resourceId,
            languageId: languageId
        )
        
        if let translation = translation {
            fetchTranslationManifestAndDownloadIfNeeded(
                translationId: translation.id,
                cache: cache,
                downloadStarted: downloadStarted,
                downloadComplete: downloadComplete
            )
        }
        else {
            downloadComplete(.failure(.noTranslationZipData(missingTranslationZipData: NoTranslationZipData(translationId: translation?.id ?? ""))))
        }
    }
    
    func fetchTranslationManifestAndDownloadIfNeeded(translationId: String, cache: @escaping ((_ translationManifest: TranslationManifestData) -> Void), downloadStarted: @escaping (() -> Void), downloadComplete: @escaping ((_ result: Result<TranslationManifestData, TranslationDownloaderError>) -> Void)) {
        
        let cachedResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslation(
            translationId: translationId
        )
                
        switch cachedResult {
        
        case .success(let manifestData):
            
            cache(manifestData)
        
        case .failure( _):
            
            downloadStarted()
            
            let receipt: DownloadTranslationsReceipt? = downloadAndCacheTranslationManifests(translationIds: [translationId])
            
            receipt?.translationDownloadedSignal.addObserver(self, onObserve: { [weak self] (translationResult: DownloadedTranslationResult) in
                
                guard let downloader = self else {
                    return
                }
                
                receipt?.translationDownloadedSignal.removeObserver(downloader)
                
                DispatchQueue.main.async {
                    
                    if let downloadError = translationResult.downloadError {
                        downloadComplete(.failure(downloadError))
                    }
                    else {
                        
                        let cachedResult: Result<TranslationManifestData, TranslationsFileCacheError> = downloader.translationsFileCache.getTranslation(
                            translationId: translationId
                        )
                                            
                        switch cachedResult {
                        case .success(let manifestData):
                            downloadComplete(.success(manifestData))
                        case .failure( _):
                            downloadComplete(.failure(.noTranslationZipData(missingTranslationZipData: NoTranslationZipData(translationId: translationId))))
                        }
                    }
                }
            })
        }
    }
    
    func downloadAndCacheTranslationManifests(translationIds: [String]) -> DownloadTranslationsReceipt? {
        
        return downloadAndCacheTranslationManifests(realm: realmDatabase.mainThreadRealm, translationIds: translationIds)
    }
    
    func downloadAndCacheTranslationManifests(realm: Realm, translationIds: [String]) -> DownloadTranslationsReceipt? {
        
        // TODO: This is getting replaced with TranslationsRepository. ~Levi
        
        return nil
        /*
        
        guard !translationIds.isEmpty else {
            return nil
        }
                
        let queue = OperationQueue()
        
        let receipt = DownloadTranslationsReceipt(translationIds: translationIds)
        
        var operations: [RequestOperation] = Array()
        var numberOfOperationsCompleted: Double = 0
        var totalOperationCount: Double = 0
        
        for translationId in translationIds {
            
            guard !translationId.isEmpty else {
                continue
            }
            
            guard !translationsFileCache.translationZipIsCached(realm: realm, translationId: translationId) else {
                continue
            }
            
            let operation: RequestOperation = translationsApi.newTranslationZipDataOperation(translationId: translationId)
                    
            operations.append(operation)
            
            operation.setCompletionHandler { [weak self] (response: RequestResponse) in
                
                self?.processDownloadedTranslation(translationId: translationId, response: response, complete: { (downloadError: TranslationDownloaderError?) in
                    
                    numberOfOperationsCompleted += 1
                    
                    let result = DownloadedTranslationResult(
                        translationId: translationId,
                        downloadError: downloadError
                    )
                    
                    receipt.handleTranslationDownloaded(result: result)
                    receipt.setProgress(value: numberOfOperationsCompleted / totalOperationCount)
                    
                    if queue.operations.isEmpty {
                        receipt.complete()
                    }
                })
            }
        }

        if !operations.isEmpty {
            numberOfOperationsCompleted = 0
            totalOperationCount = Double(operations.count)
            receipt.start(queue: queue)
            queue.addOperations(operations, waitUntilFinished: false)
            return receipt
        }
        else {
            return nil
        }*/
    }
    
    private func processDownloadedTranslation(translationId: String, response: RequestResponse, complete: @escaping ((_ downloadError: TranslationDownloaderError?) -> Void)) {
                      
        guard !translationId.isEmpty else {
            complete(.internalErrorTriedDownloadingAnEmptyTranslationId)
            return
        }
        
        let result: RequestResponseResult<NoHttpClientSuccessResponse, NoHttpClientErrorResponse> = response.getResult()
        
        switch result {
        
        case .success( _, _):
            
            if let zipData = response.data {
                
                translationsFileCache.cacheTranslationZipData(translationId: translationId, zipData: zipData, complete: { (result: Result<TranslationManifestData, TranslationsFileCacheError>) in
                    
                    switch result {
                    case .success(let translationManifest):
                        complete(nil)
                    case .failure(let fileCacheError):
                        complete(.failedToCacheTranslation(error: fileCacheError))
                    }
                })
            }
            else {
                complete(.noTranslationZipData(missingTranslationZipData: NoTranslationZipData(translationId: translationId)))
            }
       
        case .failure(let error):
            complete(.failedToDownloadTranslation(error: error))
        }
    }
}
