//
//  DownloadTranslationService.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DownloadTranslationService {
    
    private let translationsApi: TranslationsApiType
    private let translationsFileCache: ResourceTranslationsFileCache
    
    required init(translationsApi: TranslationsApiType, translationsFileCache: ResourceTranslationsFileCache) {
        
        self.translationsApi = translationsApi
        self.translationsFileCache = translationsFileCache
    }
    
    func downloadLatestTranslation(resourceId: String, languageId: String) {
        
    }
    
    func downloadTranslation(translationId: String, complete: @escaping ((_ error: DownloadTranslationError?) -> Void)) -> OperationQueue {
        
        let operation: RequestOperation = translationsApi.newTranslationZipDataOperation(translationId: translationId)
                
        operation.completionHandler { [weak self] (response: RequestResponse) in
            
            let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
                        
            switch result {
            case .success( _, _):
                
                if let zipData = response.data {
                    
                    self?.translationsFileCache.cacheTranslationZipData(translationId: translationId, zipData: zipData, complete: { (error: ResourceTranslationsFileCacheError?) in
                        
                        if let cacheError = error {
                            complete(.failedToCacheTranslation(error: cacheError))
                        }
                        else {
                            complete(nil)
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
        
        let queue = OperationQueue()
        
        queue.addOperations([operation], waitUntilFinished: false)
        
        return queue
    }
}
