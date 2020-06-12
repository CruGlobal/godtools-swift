//
//  ResourcesDownloaderAndCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesDownloaderAndCache: ResourcesDownloaderAndCacheType {
    
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    private let requestReceipts: RequestReceiptContainer<ResourcesDownloaderAndCacheError> = RequestReceiptContainer()
    
    let realmCache: ResourcesRealmCache
    
    required init(config: ConfigType, realmDatabase: RealmDatabase) {
        
        languagesApi = LanguagesApi(config: config)
        resourcesApi = ResourcesApi(config: config)
        realmCache = ResourcesRealmCache(mainThreadRealm: realmDatabase.mainThreadRealm)
    }
    
    var isDownloadingResources: Bool {
        return !requestReceipts.isEmpty
    }
    
    var currentRequestReceipt: RequestReceipt<ResourcesDownloaderAndCacheError>? {
        return requestReceipts.first
    }
    
    func downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments() -> RequestReceipt<ResourcesDownloaderAndCacheError> {
             
        let queue = OperationQueue()
        
        let receipt: RequestReceipt<ResourcesDownloaderAndCacheError> = RequestReceipt(queue: queue)
        
        requestReceipts.add(receipt: receipt)
        
        let languagesOperation: RequestOperation = languagesApi.newGetLanguagesOperation()
        let resourcesPlusLatestTranslationsAndAttachmentsOperation: RequestOperation = resourcesApi.newResourcesPlusLatestTranslationsAndAttachmentsOperation()
        
        let operations: [RequestOperation] = [languagesOperation, resourcesPlusLatestTranslationsAndAttachmentsOperation]
                
        var languagesResult: ResponseResult<LanguagesDataModel, NoClientApiErrorType>?
        var resourcesResult: ResponseResult<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoClientApiErrorType>?
                
        languagesOperation.completionHandler { [weak self] (response: RequestResponse) in
            
            languagesResult = response.getResult()
                        
            if queue.operations.isEmpty {
                
                self?.handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(
                    languagesResult: languagesResult,
                    resourcesResult: resourcesResult,
                    receipt: receipt
                )
            }
        }
        
        resourcesPlusLatestTranslationsAndAttachmentsOperation.completionHandler { [weak self] (response: RequestResponse) in
                
            resourcesResult = response.getResult()
            
            if queue.operations.isEmpty {
                
                self?.handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(
                    languagesResult: languagesResult,
                    resourcesResult: resourcesResult,
                    receipt: receipt
                )
            }
        }
        
        queue.addOperations(
            operations,
            waitUntilFinished: false
        )
        
        return receipt
    }
    
    private func handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(languagesResult: ResponseResult<LanguagesDataModel, NoClientApiErrorType>?, resourcesResult: ResponseResult<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoClientApiErrorType>?, receipt: RequestReceipt<ResourcesDownloaderAndCacheError>) {
        
        var languages: [LanguageModel] = Array()
        var resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel = ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
        var downloaderError: ResourcesDownloaderAndCacheError?
        
        if let languagesResult = languagesResult, let resourcesResult = resourcesResult {
            
            switch languagesResult {
            case .success(let languagesDataModel, let decodeError):
                if let decodeError = decodeError {
                    downloaderError = .failedToDecodeLanguages(error: decodeError)
                }
                else if let languagesData = languagesDataModel?.data, !languagesData.isEmpty {
                    languages = languagesData
                }
                else {
                    downloaderError = .internalErrorNoLanguages
                }
                
            case .failure(let error):
                downloaderError = .failedToGetLanguages(error: error)
            }
            
            switch resourcesResult {
            case .success(let resourcesPlusLatestTranslationsAndAttachmentsData, let decodeError):
                if let decodeError = decodeError {
                    downloaderError = .failedToDecodeResourcesPlusLatestTranslationsAndAttachments(error: decodeError)
                }
                else if let resourcesData = resourcesPlusLatestTranslationsAndAttachmentsData {
                    resourcesPlusLatestTranslationsAndAttachments = resourcesData
                }
                else {
                    downloaderError = .internalErrorNoResourcesPlusLatestTranslationsAndAttachments
                }
            case .failure(let error):
                downloaderError = .failedToGetResourcesPlusLatestTranslationsAndAttachments(error: error)
            }
        }
        else if languagesResult == nil {
            downloaderError = .internalErrorFailedToGetLanguagesResult
        }
        else if resourcesResult == nil {
            downloaderError = .internalErrorFailedToGetResourcesResult
        }
        
        if let downloaderError = downloaderError {
            
            handleDownloaderAndCacheCompleted(receipt: receipt, error: downloaderError)
        }
        else {
            
            realmCache.cacheResources(languages: languages, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments) { [weak self] (cacheError: ResourcesCacheError?) in
                
                if let cacheError = cacheError {
                    self?.handleDownloaderAndCacheCompleted(receipt: receipt, error: .failedToCacheResources(error: cacheError))
                }
                else {
                    self?.handleDownloaderAndCacheCompleted(receipt: receipt, error: nil)
                }
            }
        }
    }
    
    private func handleDownloaderAndCacheCompleted(receipt: RequestReceipt<ResourcesDownloaderAndCacheError>, error: ResourcesDownloaderAndCacheError?) {
                
        requestReceipts.remove(receipt: receipt)
        
        receipt.complete(value: error)
    }
}
