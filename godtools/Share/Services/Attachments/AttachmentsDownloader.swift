//
//  AttachmentsDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AttachmentsDownloader {
    
    private let session: URLSession

    private var currentQueue: OperationQueue?
    
    let attachmentsFileCache: AttachmentsFileCache
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let progress: ObservableValue<Double> = ObservableValue(value: 0)
    let completed: Signal = Signal()
    
    required init(attachmentsFileCache: AttachmentsFileCache) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
            
        self.session = URLSession(configuration: configuration)
        self.attachmentsFileCache = attachmentsFileCache
    }
    
    func downloadAndCacheAttachments(from result: ResourcesDownloaderResult) {
        
        if currentQueue != nil {
            assertionFailure("ResourceAttachmentsDownloaderAndCache:  Download is already running, this process only needs to run once when reloading all resource attachments from the server.")
            return
        }
        
        started.accept(value: true)
                
        let queue: OperationQueue = OperationQueue()
        
        self.currentQueue = queue
        
        if result.latestAttachmentFiles.isEmpty {
            handleDownloadAndCacheAttachmentsCompleted()
            return
        }
        
        var numberOfAttachmentsDownloaded: Double = 0
        var totalNumberOfAttachmentsToDownload: Double = 0
        var attachmentDownloadOperations: [RequestOperation] = Array()
        
        for attachmentFile in result.latestAttachmentFiles {
                                    
            if !attachmentsFileCache.attachmentExists(location: attachmentFile.location) {
                                
                let attachmentOperation = RequestOperation(session: session, urlRequest: URLRequest(url: attachmentFile.remoteFileUrl))
                
                attachmentDownloadOperations.append(attachmentOperation)
                
                attachmentOperation.completionHandler { [weak self] (response: RequestResponse) in
                    
                    let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
                    
                    switch result {
                    case .success( _, _):
                        if let fileData = response.data {
                            
                            self?.attachmentsFileCache.cacheAttachmentFile(attachmentFile: attachmentFile, fileData: fileData, complete: { (error: Error?) in
                                
                            })
                        }
                    case .failure(let error):
                        // TODO: Do we need error reporting for these? ~Levi
                        print("\n Failed to download attachment: \(error)")
                    }
                    
                    numberOfAttachmentsDownloaded += 1
                    self?.progress.accept(value: numberOfAttachmentsDownloaded / totalNumberOfAttachmentsToDownload)
                    
                    if queue.operations.isEmpty {
                        self?.handleDownloadAndCacheAttachmentsCompleted()
                    }
                }
            }
            else {
                attachmentsFileCache.addAttachmentReferencesIfNeeded(attachmentFile: attachmentFile) { (error: Error?) in
                    
                }
            }
        }
        
        if !attachmentDownloadOperations.isEmpty {
            numberOfAttachmentsDownloaded = 0
            totalNumberOfAttachmentsToDownload = Double(attachmentDownloadOperations.count)
            progress.accept(value: 0)
            queue.addOperations(attachmentDownloadOperations, waitUntilFinished: false)
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
