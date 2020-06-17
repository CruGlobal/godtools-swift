//
//  ResourceTranslationsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceTranslationsService {
    
    private let translationsApi: TranslationsApiType
    
    private var currentQueue: OperationQueue?
    
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let progress: ObservableValue<Double> = ObservableValue(value: 0)
    let completed: Signal = Signal()
    
    required init(translationsApi: TranslationsApiType) {
        
        self.translationsApi = translationsApi
    }
    
    func downloadAndCacheTranslations(resource: RealmResource) {
        
        if currentQueue != nil {
            assertionFailure("ResourceTranslationsDownloaderAndCache:  Download is already running, this process only needs to run once when reloading all resource translations from the server.")
            return
        }
        
        let queue: OperationQueue = OperationQueue()
        
        self.currentQueue = queue
        
        if resource.attachmentIds.isEmpty {
            handleDownloadAndCacheAttachmentsCompleted()
            return
        }
        
        var numberOfOperationsCompleted: Double = 0
        var totalOperationCount: Double = 0
        var operations: [RequestOperation] = Array()
        
        /*
        for translation in resource.latestTranslations {
            
            let operation: RequestOperation = translationsApi.newTranslationZipDataOperation(translationId: translation.id)
            
            operations.append(operation)
            
            operation.completionHandler { [weak self] (response: RequestResponse) in
                
                let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
                
                switch result {
                case .success( _, _):
                    if let zipData = response.data {
                        /*
                        DispatchQueue.main.async { [weak self] in
                            if let error = self?.resourcesFileCache.decompressTranslationZipFileAndCacheSHA256FileContents(translation: translation, zipData: zipData) {
                               print(error)
                            }
                        }*/
                    }
                case .failure(let error):
                    print("\n Failed to download translation zip data: \(error)")
                }
                
                numberOfOperationsCompleted += 1
                self?.progress.accept(value: numberOfOperationsCompleted / totalOperationCount)
                
                if queue.operations.isEmpty {
                    self?.handleDownloadAndCacheAttachmentsCompleted()
                }
            }
        }*/
        
        if !operations.isEmpty {
            totalOperationCount = Double(operations.count)
            started.accept(value: true)
            progress.accept(value: 0)
            queue.addOperations(operations, waitUntilFinished: false)
        }
        else {
            handleDownloadAndCacheAttachmentsCompleted()
        }
    }
    
    private func handleDownloadAndCacheAttachmentsCompleted() {
        currentQueue = nil
        started.accept(value: false)
        progress.accept(value: 0)
        completed.accept()
    }
}
