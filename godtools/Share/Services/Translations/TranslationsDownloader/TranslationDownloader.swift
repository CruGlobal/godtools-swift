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
        
        print("\n TranslationsDownloader: downloadTranslations -> \(translationIds)")
        
        let queue = OperationQueue()
        
        let receipt = DownloadTranslationsReceipt(translationIds: translationIds, queue: queue)
        
        var operations: [RequestOperation] = Array()
        var numberOfOperationsCompleted: Double = 0
        var totalOperationCount: Double = 0
        
        for translationId in translationIds {
            
            guard !translationId.isEmpty else {
                continue
            }
            
            guard !translationsFileCache.translationZipIsCached(realm: realm, translationId: translationId) else {
                print("   translationId already downloaded: \(translationId)")
                continue
            }
            
            let operation: RequestOperation = translationsApi.newTranslationZipDataOperation(translationId: translationId)
                    
            operations.append(operation)
            
            operation.completionHandler { [weak self] (response: RequestResponse) in
                
                self?.processDownloadedTranslation(translationId: translationId, response: response, complete: { (result: DownloadedTranslationResult) in
                    
                    receipt.translationDownloaded.accept(value: result)
                    receipt.progress.accept(value: numberOfOperationsCompleted / totalOperationCount)
                    
                    if queue.operations.isEmpty {
                        receipt.progress.accept(value: 1)
                        receipt.completed.accept()
                    }
                })
            }
        }

        if !operations.isEmpty {
            numberOfOperationsCompleted = 0
            totalOperationCount = Double(operations.count)
            receipt.progress.accept(value: 0)
            queue.addOperations(operations, waitUntilFinished: false)
            return receipt
        }
        else {
            return nil
        }
    }
    
    private func processDownloadedTranslation(translationId: String, response: RequestResponse, complete: @escaping ((_ result: DownloadedTranslationResult) -> Void)) {
               
        guard !translationId.isEmpty else {
            complete(DownloadedTranslationResult(translationId: translationId, result: .failure(.internalErrorTriedDownloadingAnEmptyTranslationId)))
            return
        }
        
        let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
        
        switch result {
        
        case .success( _, _):
            
            if let zipData = response.data {
                
                translationsFileCache.cacheTranslationZipData(translationId: translationId, zipData: zipData, complete: { (result: Result<TranslationManifestData, TranslationsFileCacheError>) in
                    
                    switch result {
                    case .success(let translationManifest):
                        complete(DownloadedTranslationResult(translationId: translationId, result: .success(translationManifest)))
                    case .failure(let fileCacheError):
                        complete(DownloadedTranslationResult(translationId: translationId, result: .failure(.failedToCacheTranslation(error: fileCacheError))))
                    }
                })
            }
            else {
                complete(DownloadedTranslationResult(translationId: translationId, result: .failure(.noTranslationZipData(missingTranslationZipData: NoTranslationZipData(translationId: translationId)))))
            }
       
        case .failure(let error):
            complete(DownloadedTranslationResult(translationId: translationId, result: .failure(.failedToDownloadTranslation(error: error))))
        }
    }
}
