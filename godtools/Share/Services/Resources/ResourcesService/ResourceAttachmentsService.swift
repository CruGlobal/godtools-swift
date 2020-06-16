//
//  ResourceAttachmentsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceAttachmentsService {
    
    private let session: URLSession
    private let resourcesCache: ResourcesCache
    
    private var currentQueue: OperationQueue?
    
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let progress: ObservableValue<Double> = ObservableValue(value: 0)
    let completed: Signal = Signal()
    
    required init(session: URLSession, resourcesCache: ResourcesCache) {
        
        self.session = session
        self.resourcesCache = resourcesCache
    }
    
    func downloadAndCacheAttachments(resource: RealmResource) {
        
        if currentQueue != nil {
            assertionFailure("ResourceAttachmentsDownloaderAndCache:  Download is already running, this process only needs to run once when reloading all resource attachments from the server.")
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
        
        var fileCacheLocations: [URL: SHA256FileLocation] = Dictionary()
        
        for attachmentId in resource.attachmentIds {
            
            guard let attachment = resourcesCache.realmResources.getAttachment(id: attachmentId) else {
                continue
            }
            
            guard let attachmentFileUrl = URL(string: attachment.file) else {
                continue
            }
            
            /*
            let fileCacheLocation = SHA256FileLocation(sha256: attachment.sha256, pathExtension: fileUrl.pathExtension)
            
            let fileExistsInCache: Bool
            switch resourcesFileCache.fileExists(location: fileCacheLocation) {
            case .success(let exists):
                fileExistsInCache = exists
            case .failure( _):
                fileExistsInCache = false
            }
            
            if !fileExistsInCache {
                
                let operation = RequestOperation(session: session, urlRequest: URLRequest(url: fileUrl))
                
                operations.append(operation)
                
                fileCacheLocations[fileUrl] = fileCacheLocation
                
                operation.completionHandler { [weak self] (response: RequestResponse) in
                    
                    let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
                    
                    switch result {
                    case .success( _, _):
                        
                        if let data = response.data, let fileUrl = response.urlRequest?.url, let location = fileCacheLocations[fileUrl] {
                            
                            DispatchQueue.main.async { [weak self] in
                                
                                let cacheError = self?.resourcesFileCache.cacheSHA256File(location: location, fileData: data)
                                
                                
                            }
                        }
                    case .failure(let error):
                        print("\n Failed to download attachment: \(error)")
                    }
                    
                    numberOfOperationsCompleted += 1
                    self?.progress.accept(value: numberOfOperationsCompleted / totalOperationCount)
                    
                    if queue.operations.isEmpty {
                        self?.handleDownloadAndCacheAttachmentsCompleted()
                    }
                }
            }*/
        }
        
        if !operations.isEmpty {
            numberOfOperationsCompleted = 0
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
