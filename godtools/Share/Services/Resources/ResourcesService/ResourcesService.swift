//
//  ResourcesService.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesService {
    
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    private let translationsApi: TranslationsApiType
        
    private var currentQueue: OperationQueue?
    
    let resourcesCache: ResourcesCache
    let attachmentsServices: ResourceAttachmentsServices
    let translationsServices: ResourceTranslationsServices
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: SignalValue<ResourcesServiceError?> = SignalValue()
    
    required init(languagesApi: LanguagesApiType, resourcesApi: ResourcesApiType, translationsApi: TranslationsApiType, resourcesCache: ResourcesCache, attachmentsServices: ResourceAttachmentsServices, translationsServices: ResourceTranslationsServices) {
        
        self.languagesApi = languagesApi
        self.resourcesApi = resourcesApi
        self.translationsApi = translationsApi
        self.resourcesCache = resourcesCache
        self.attachmentsServices = attachmentsServices
        self.translationsServices = translationsServices
    }

    func downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments() -> OperationQueue {
             
        if let queue = currentQueue {
            assertionFailure("ResourcesDownloaderAndCache:  Download is already running, this process only needs to run once when reloading all resource data from the server.")
            return queue
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
        var downloaderError: ResourcesServiceError?
        
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
            
            handleDownloaderAndCacheCompleted(error: downloaderError)
        }
        else {
            
            resourcesCache.realmCache.cacheResources(languages: languages, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments) { [weak self] (cacheError: Error?) in
                
                if let cacheError = cacheError {
                    self?.handleDownloaderAndCacheCompleted(error: .failedToCacheResources(error: cacheError))
                }
                else {
                    self?.handleDownloaderAndCacheCompleted(error: nil)
                }
            }
        }
    }
    
    private func handleDownloaderAndCacheCompleted(error: ResourcesServiceError?) {
                
        currentQueue = nil
        
        started.accept(value: false)
        
        completed.accept(value: error)
        
        DispatchQueue.main.async { [weak self] in
            
            let resources: [RealmResource] = self?.resourcesCache.realmCache.getResources() ?? []
            
            for resource in resources {
                
                self?.attachmentsServices.getResourceAttachmentsService(resourceId: resource.id).downloadAndCacheAttachments(resource: resource)
            }
            
            //self?.resourceAttachmentsDownloaderAndCacheContainer.downloadAndCacheResourcesAttachments(resources: resources)
            //self?.resourceTranslationsDownloaderAndCacheContainer.downloadAndCacheResourcesTranslations(resources: resources)
        }
    }
}
