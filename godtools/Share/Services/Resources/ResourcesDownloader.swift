//
//  ResourcesDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesDownloader {
    
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    
    private var currentQueue: OperationQueue?
            
    let resourcesCache: RealmResourcesCache
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: ObservableValue<Result<ResourcesDownloaderResult, ResourcesDownloaderError>?> = ObservableValue(value: nil)
    
    required init(languagesApi: LanguagesApiType, resourcesApi: ResourcesApiType, resourcesCache: RealmResourcesCache) {
        
        self.languagesApi = languagesApi
        self.resourcesApi = resourcesApi
        self.resourcesCache = resourcesCache
    }

    func downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments() -> OperationQueue? {
             
        if currentQueue != nil {
            assertionFailure("ResourcesDownloader: Download already started and only needs to run once at startup.")
            return nil
        }
        
        let queue = OperationQueue()
        
        self.currentQueue = queue
        
        started.accept(value: true)
                                
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
                    resourcesResult: resourcesResult
                )
            }
        }
        
        resourcesPlusLatestTranslationsAndAttachmentsOperation.completionHandler { [weak self] (response: RequestResponse) in
                
            resourcesResult = response.getResult()
            
            if queue.operations.isEmpty {
                
                self?.handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(
                    languagesResult: languagesResult,
                    resourcesResult: resourcesResult
                )
            }
        }
        
        queue.addOperations(
            operations,
            waitUntilFinished: false
        )
        
        return queue
    }
    
    private func handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(languagesResult: ResponseResult<LanguagesDataModel, NoClientApiErrorType>?, resourcesResult: ResponseResult<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoClientApiErrorType>?) {
        
        var languages: [LanguageModel] = Array()
        var resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel = ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
        var downloaderError: ResourcesDownloaderError?
        
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
            
            handleDownloaderAndCacheCompleted(result: .failure(downloaderError))
        }
        else {
            
            resourcesCache.cacheResources(languages: languages, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments) { [weak self] (result: Result<ResourcesDownloaderResult, Error>) in
                
                switch result {
                
                case .success(let cacheResult):
                    self?.handleDownloaderAndCacheCompleted(result: .success(cacheResult))
                
                case .failure(let cacheError):
                    self?.handleDownloaderAndCacheCompleted(result: .failure(.failedToCacheResources(error: cacheError)))
                }
            }
        }
    }
    
    private func handleDownloaderAndCacheCompleted(result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) {
        
        currentQueue = nil
        started.accept(value: false)
        completed.accept(value: result)
    }
}
