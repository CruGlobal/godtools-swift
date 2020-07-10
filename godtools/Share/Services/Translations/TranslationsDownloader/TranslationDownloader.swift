//
//  TranslationDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class TranslationDownloader {
    
    typealias TranslationId = String
    
    private let realmDatabase: RealmDatabase
    private let translationsApi: TranslationsApiType
        
    let translationsFileCache: TranslationsFileCache
    
    required init(realmDatabase: RealmDatabase, translationsApi: TranslationsApiType, translationsFileCache: TranslationsFileCache) {
        
        self.realmDatabase = realmDatabase
        self.translationsApi = translationsApi
        self.translationsFileCache = translationsFileCache
    }
    
    func downloadTranslations(translationIds: [String]) -> DownloadTranslationsReceipt? {
        
        return downloadTranslations(realm: realmDatabase.mainThreadRealm, translationIds: translationIds)
    }
    
    func downloadTranslations(realm: Realm, translationIds: [String]) -> DownloadTranslationsReceipt? {
        
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
            
            operation.completionHandler { [weak self] (response: RequestResponse) in
                
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
        }
    }
    
    private func processDownloadedTranslation(translationId: String, response: RequestResponse, complete: @escaping ((_ downloadError: TranslationDownloaderError?) -> Void)) {
                      
        guard !translationId.isEmpty else {
            complete(.internalErrorTriedDownloadingAnEmptyTranslationId)
            return
        }
        
        let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
        
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
