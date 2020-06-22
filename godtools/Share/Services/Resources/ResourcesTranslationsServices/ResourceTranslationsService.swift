//
//  ResourceTranslationsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourceTranslationsService {
    
    private let realmDatabase: RealmDatabase
    private let realmResourcesCache: RealmResourcesCache
    private let translationsApi: TranslationsApiType
    private let translationsFileCache: ResourceTranslationsFileCache
    private let resourceId: String
    
    private var currentQueue: OperationQueue?
    
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let progress: ObservableValue<Double> = ObservableValue(value: 0)
    let completed: Signal = Signal()
    
    required init(realmDatabase: RealmDatabase, realmResourcesCache: RealmResourcesCache, translationsApi: TranslationsApiType, translationsFileCache: ResourceTranslationsFileCache, resourceId: String) {
        
        self.realmDatabase = realmDatabase
        self.realmResourcesCache = realmResourcesCache
        self.translationsApi = translationsApi
        self.translationsFileCache = translationsFileCache
        self.resourceId = resourceId
    }
    
    func downloadAndCacheTranslations(resource: ResourceModel) {
                    
        if resource.id != resourceId {
            assertionFailure("ResourceTranslationsService: Incorrect resource.  Expected resource with id: \(resourceId)")
            return
        }
        
        if currentQueue != nil {
            assertionFailure("ResourceTranslationsService:  Download is already running, this process only needs to run once when reloading all resource translations from the server.")
            return
        }
        
        started.accept(value: true)
        
        let queue: OperationQueue = OperationQueue()
        let translationsApiRef: TranslationsApiType = translationsApi
        
        self.currentQueue = queue
        
        var numberOfOperationsCompleted: Double = 0
        var totalOperationCount: Double = 0
        var operations: [RequestOperation] = Array()
        var errors: [DownloadTranslationError] = Array()
        
        // only need to download translation zipfiles that haven't been cached
        filterCachedTranslationZipFilesFromTranslationIds(translationIds: resource.latestTranslationIds) { [weak self] (tranlationIds: [String]) in
            
            for translationId in tranlationIds {
                                
                let operation: RequestOperation = translationsApiRef.newTranslationZipDataOperation(translationId: translationId)
                
                operations.append(operation)
                
                operation.completionHandler { [weak self] (response: RequestResponse) in
                                        
                    self?.processDownloadedTranslation(translationId: translationId, response: response, complete: { [weak self] (error: DownloadTranslationError?) in
                                                
                        if let error = error {
                            errors.append(error)
                        }
                        
                        numberOfOperationsCompleted += 1
                        self?.progress.accept(value: numberOfOperationsCompleted / totalOperationCount)
                                                
                        if queue.operations.isEmpty {
                            self?.handleDownloadAndCacheTranslationsCompleted(errors: errors)
                        }
                    })
                }
            }
            
            if !operations.isEmpty {
                totalOperationCount = Double(operations.count)
                self?.progress.accept(value: 0)
                queue.addOperations(operations, waitUntilFinished: false)
            }
            else {
                self?.handleDownloadAndCacheTranslationsCompleted(errors: [])
            }
        }
    }
    
    private func processDownloadedTranslation(translationId: String, response: RequestResponse, complete: @escaping ((_ error: DownloadTranslationError?) -> Void)) {
        
        let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
        
        switch result {
        
        case .success( _, _):
            
            if let zipData = response.data {
                
                translationsFileCache.cacheTranslationZipData(translationId: translationId, zipData: zipData, complete: { (error: ResourceTranslationsFileCacheError?) in
                    
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
    
    private func handleDownloadAndCacheTranslationsCompleted(errors: [DownloadTranslationError]) {
        
        currentQueue = nil
        started.accept(value: false)
        progress.accept(value: 0)
        completed.accept()
    }
    
    private func filterCachedTranslationZipFilesFromTranslationIds(translationIds: [String], complete: @escaping ((_ translationIds: [String]) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            var translationIdsThatArentCached: [String] = Array()
            
            for translationId in translationIds {
                
                let isCached: Bool = realm.object(ofType: RealmTranslationZipFile.self, forPrimaryKey: translationId) != nil
                
                if !isCached {
                    translationIdsThatArentCached.append(translationId)
                }
            }
            
            DispatchQueue.main.async {
                complete(translationIdsThatArentCached)
            }
        }
    }
}
