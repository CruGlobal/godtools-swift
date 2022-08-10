//
//  ResourcesDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class ResourcesDownloader {
    
    private let languagesApi: MobileContentLanguagesApi
    private let resourcesApi: ResourcesApi
        
    required init(languagesApi: MobileContentLanguagesApi, resourcesApi: ResourcesApi) {
        
        self.languagesApi = languagesApi
        self.resourcesApi = resourcesApi
    }

    func downloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachments(complete: @escaping ((_ result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) -> Void)) -> OperationQueue? {
             
        let queue = OperationQueue()
                                        
        let languagesOperation: RequestOperation = languagesApi.getLanguagesOperation()
        let resourcesPlusLatestTranslationsAndAttachmentsOperation: RequestOperation = resourcesApi.newResourcesPlusLatestTranslationsAndAttachmentsOperation()
        
        let operations: [RequestOperation] = [languagesOperation, resourcesPlusLatestTranslationsAndAttachmentsOperation]
                
        var languagesResult: RequestResponseResult<LanguagesDataModel, NoHttpClientErrorResponse>?
        var resourcesResult: RequestResponseResult<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoHttpClientErrorResponse>?
                
        languagesOperation.setCompletionHandler { [weak self] (response: RequestResponse) in
            
            languagesResult = response.getResult()
                        
            if queue.operations.isEmpty {
                
                self?.handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(
                    languagesResult: languagesResult,
                    resourcesResult: resourcesResult,
                    complete: complete
                )
            }
        }
        
        resourcesPlusLatestTranslationsAndAttachmentsOperation.setCompletionHandler { [weak self] (response: RequestResponse) in
                
            resourcesResult = response.getResult()
            
            if queue.operations.isEmpty {
                
                self?.handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(
                    languagesResult: languagesResult,
                    resourcesResult: resourcesResult,
                    complete: complete
                )
            }
        }
        
        queue.addOperations(
            operations,
            waitUntilFinished: false
        )
        
        return queue
    }
    
    private func handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(languagesResult: RequestResponseResult<LanguagesDataModel, NoHttpClientErrorResponse>?, resourcesResult: RequestResponseResult<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoHttpClientErrorResponse>?, complete: @escaping ((_ result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>) -> Void)) {
        
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
            complete(.failure(downloaderError))
        }
        else {
            complete(.success(ResourcesDownloaderResult(languages: languages, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)))
        }
    }
}
