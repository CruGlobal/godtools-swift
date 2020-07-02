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
    let attachmentDownloaded: SignalValue<Result<AttachmentFile, AttachmentsDownloaderError>> = SignalValue()
    let completed: Signal = Signal()
    
    required init(attachmentsFileCache: AttachmentsFileCache, sharedSession: SharedSessionType) {
                    
        self.session = sharedSession.session
        self.attachmentsFileCache = attachmentsFileCache
    }
    
    func downloadAndCacheAttachments(from result: ResourcesCacheResult) {
        
        if currentQueue != nil {
            assertionFailure("ResourceAttachmentsDownloaderAndCache:  Download is already running, this process only needs to run once when reloading all resource attachments from the server.")
            return
        }
        
        if result.latestAttachmentFiles.isEmpty {
            return
        }
        
        started.accept(value: true)
                
        let queue: OperationQueue = OperationQueue()
        
        self.currentQueue = queue
        
        var numberOfAttachmentsDownloaded: Double = 0
        var totalNumberOfAttachmentsToDownload: Double = 0
        var attachmentDownloadOperations: [RequestOperation] = Array()
        
        for attachmentFile in result.latestAttachmentFiles {
                                    
            if !attachmentsFileCache.attachmentExists(location: attachmentFile.location) {
                                
                let attachmentOperation = RequestOperation(session: session, urlRequest: URLRequest(url: attachmentFile.remoteFileUrl))
                
                attachmentDownloadOperations.append(attachmentOperation)
                
                attachmentOperation.completionHandler { [weak self] (response: RequestResponse) in
                    
                    self?.processDownloadedAttachment(attachmentFile: attachmentFile, response: response, complete: { [weak self] (result: Result<AttachmentFile, AttachmentsDownloaderError>) in
                        
                        self?.attachmentDownloaded.accept(value: result)
                        
                        numberOfAttachmentsDownloaded += 1
                        self?.progress.accept(value: numberOfAttachmentsDownloaded / totalNumberOfAttachmentsToDownload)
                        
                        if queue.operations.isEmpty {
                            self?.handleDownloadAndCacheAttachmentsCompleted()
                        }
                    })
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
    
    private func processDownloadedAttachment(attachmentFile: AttachmentFile, response: RequestResponse, complete: @escaping ((_ result: Result<AttachmentFile, AttachmentsDownloaderError>) -> Void)) {
        
        let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
        
        switch result {
        
        case .success( _, _):
            
            if let fileData = response.data {
                
                attachmentsFileCache.cacheAttachmentFile(attachmentFile: attachmentFile, fileData: fileData, complete: { (cacheError: Error?) in
                    
                    if let cacheError = cacheError {
                        complete(.failure(.failedToCacheAttachment(error: cacheError)))
                    }
                    else {
                        complete(.success(attachmentFile))
                    }
                })
            }
            else {
                complete(.failure(.noAttachmentData(missingAttachmentData: NoAttachmentData(remoteFileUrl: attachmentFile.remoteFileUrl))))
            }
        
        case .failure(let downloadError):
            complete(.failure(.failedToDownloadAttachment(error: downloadError)))
        }
    }
    
    private func handleDownloadAndCacheAttachmentsCompleted() {
        currentQueue = nil
        started.accept(value: false)
        progress.accept(value: 0)
        completed.accept()
    }
}
