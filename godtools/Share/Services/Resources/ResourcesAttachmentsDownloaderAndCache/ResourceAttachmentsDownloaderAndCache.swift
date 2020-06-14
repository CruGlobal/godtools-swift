//
//  ResourceAttachmentsDownloaderAndCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceAttachmentsDownloaderAndCache {
    
    private let session: URLSession
    private let resourcesFileCache: ResourcesSHA256FilesCache
    private let resourcesCache: ResourcesRealmCache
    
    private var currentQueue: OperationQueue?
    
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let progress: ObservableValue<Double> = ObservableValue(value: 0)
    let completed: Signal = Signal()
    
    required init(session: URLSession, resourcesFileCache: ResourcesSHA256FilesCache, resourcesCache: ResourcesRealmCache) {
        
        self.session = session
        self.resourcesFileCache = resourcesFileCache
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
        
        var totalOperationCount: Double = 0
        var operations: [RequestOperation] = Array()
        var fileCacheLocations: [URL: ResourceSHA256FileLocation] = Dictionary()
        
        for attachmentId in resource.attachmentIds {
            
            if let attachment = resourcesCache.getAttachment(id: attachmentId), let fileUrl = URL(string: attachment.file) {
                                                                        
                let fileCacheLocation: ResourceSHA256FileLocation = ResourceSHA256FileLocation(sha256: attachment.sha256, pathExtension: fileUrl.pathExtension)
                
                switch resourcesFileCache.fileExists(location: fileCacheLocation) {
                
                case .success(let fileExistsInFileCache):
                    
                    if !fileExistsInFileCache {
                        
                        let operation = RequestOperation(session: session, urlRequest: URLRequest(url: fileUrl))
                        
                        operations.append(operation)
                        fileCacheLocations[fileUrl] = fileCacheLocation
                        
                        operation.completionHandler { [weak self] (response: RequestResponse) in
                            
                            let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
                            
                            switch result {
                            case .success( _, _):
                                if let data = response.data, let fileUrl = response.urlRequest?.url, let location = fileCacheLocations[fileUrl] {
                                    DispatchQueue.main.async { [weak self] in
                                        let cacheError = self?.resourcesFileCache.cache(reference: attachment, location: location, data: data)
                                        
                                        if let error = cacheError {
                                            print("\n Failed to cache attachment file: \(error)")
                                        }
                                        else {
                                            print("  did cache attachment file at location: \(location.fileUrl?.absoluteString ?? "")")
                                        }
                                    }
                                }
                            case .failure(let error):
                                print("\n Failed to download attachment: \(error)")
                            }
                            
                            self?.progress.accept(value: Double(queue.operations.count) / totalOperationCount)
                            
                            if queue.operations.isEmpty {
                                self?.handleDownloadAndCacheAttachmentsCompleted()
                            }
                        }
                    }
                case .failure( _):
                    break
                }
            }
        }
        
        if !operations.isEmpty {
            print("\n Starting to download attachments for resource: \(resource.id)")
            print("   number of downloads: \(operations.count)")
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
        progress.accept(value: 1)
        completed.accept()
    }
}
