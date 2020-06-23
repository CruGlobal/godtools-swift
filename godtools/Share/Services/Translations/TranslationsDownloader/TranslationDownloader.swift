//
//  TranslationDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslationDownloader {
    
    typealias TranslationId = String
    
    private let translationsApi: TranslationsApiType
        
    let translationsFileCache: TranslationsFileCache
    
    required init(translationsApi: TranslationsApiType, translationsFileCache: TranslationsFileCache) {
        
        self.translationsApi = translationsApi
        self.translationsFileCache = translationsFileCache
    }
    
    func downloadTranslation(translationId: String, complete: @escaping ((_ result: Result<TranslationManifest, TranslationDownloaderError>) -> Void)) -> OperationQueue {
        
        let operation: RequestOperation = translationsApi.newTranslationZipDataOperation(translationId: translationId)
                
        operation.completionHandler { [weak self] (response: RequestResponse) in
            
            self?.processDownloadedTranslation(
                translationId: translationId,
                response: response,
                complete: complete
            )
        }
        
        let queue = OperationQueue()
        
        queue.addOperations([operation], waitUntilFinished: false)
        
        return queue
    }
    
    func downloadTranslations(translationIds: [String]) -> DownloadTranslationsReceipt {
        
        let queue = OperationQueue()
        
        let receipt = DownloadTranslationsReceipt(translationIds: translationIds, queue: queue)
        
        var operations: [RequestOperation] = Array()
        var numberOfOperationsCompleted: Double = 0
        var totalOperationCount: Double = 0
        
        for translationId in translationIds {
            
            let operation: RequestOperation = translationsApi.newTranslationZipDataOperation(translationId: translationId)
                    
            operations.append(operation)
            
            operation.completionHandler { [weak self] (response: RequestResponse) in
                
                self?.processDownloadedTranslation(translationId: translationId, response: response, complete: { (result: Result<TranslationManifest, TranslationDownloaderError>) in
                    
                    receipt.progress.accept(value: numberOfOperationsCompleted / totalOperationCount)
                    receipt.translationDownloaded.accept(value: result)
                    
                    if queue.operations.isEmpty {
                        receipt.progress.accept(value: 1)
                    }
                })
            }
        }

        if !operations.isEmpty {
            numberOfOperationsCompleted = 0
            totalOperationCount = Double(operations.count)
            receipt.progress.accept(value: 0)
            queue.addOperations(operations, waitUntilFinished: false)
        }
        else {
            receipt.progress.accept(value: 1)
        }
        
        return receipt
    }
    
    private func processDownloadedTranslation(translationId: String, response: RequestResponse, complete: @escaping ((_ result: Result<TranslationManifest, TranslationDownloaderError>) -> Void)) {
        
        let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
        
        switch result {
        
        case .success( _, _):
            
            if let zipData = response.data {
                
                translationsFileCache.cacheTranslationZipData(translationId: translationId, zipData: zipData, complete: { (result: Result<TranslationManifest, TranslationsFileCacheError>) in
                    
                    switch result {
                    case .success(let translationManifest):
                        complete(.success(translationManifest))
                    case .failure(let fileCacheError):
                        complete(.failure(.failedToCacheTranslation(error: fileCacheError)))
                    }
                })
            }
            else {
                complete(.failure(.noTranslationZipData(missingTranslationZipData: NoTranslationZipData(translationId: translationId))))
            }
       
        case .failure(let error):
            complete(.failure(.failedToDownloadTranslation(error: error)))
        }
    }
}
