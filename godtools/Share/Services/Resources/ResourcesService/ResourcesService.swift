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
    
    let realmResourcesCache: RealmResourcesCache
    let attachmentsService: ResourceAttachmentsService
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let completed: SignalValue<ResourcesServiceError?> = SignalValue()
    
    required init(languagesApi: LanguagesApiType, resourcesApi: ResourcesApiType, translationsApi: TranslationsApiType, realmResourcesCache: RealmResourcesCache, attachmentsService: ResourceAttachmentsService) {
        
        self.languagesApi = languagesApi
        self.resourcesApi = resourcesApi
        self.translationsApi = translationsApi
        self.realmResourcesCache = realmResourcesCache
        self.attachmentsService = attachmentsService
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
            
            handleDownloaderAndCacheCompleted(result: .failure(downloaderError))
        }
        else {
            
            realmResourcesCache.cacheResources(languages: languages, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments) { [weak self] (result: Result<RealmResourcesCacheResult, Error>) in
                
                switch result {
                case .success(let cacheResult):
                    self?.handleDownloaderAndCacheCompleted(result: .success(cacheResult))
                case .failure(let cacheError):
                    self?.handleDownloaderAndCacheCompleted(result: .failure(.failedToCacheResources(error: cacheError)))
                }
            }
        }
    }
    
    private func handleDownloaderAndCacheCompleted(result: Result<RealmResourcesCacheResult, ResourcesServiceError>) {
                
        let resourcesCacheResult: RealmResourcesCacheResult?
        let serviceError: ResourcesServiceError?
        
        switch result {
        case .success(let cacheResult):
            resourcesCacheResult = cacheResult
            serviceError = nil
        case .failure(let error):
            resourcesCacheResult = nil
            serviceError = error
        }
        
        currentQueue = nil
        
        started.accept(value: false)
        
        completed.accept(value: serviceError)
        
        if let resourcesCacheResult = resourcesCacheResult {
            
            attachmentsService.downloadAndCacheAttachments(from: resourcesCacheResult)
            
            // TODO: Download any new translations? ~Levi
        }
    }
}
