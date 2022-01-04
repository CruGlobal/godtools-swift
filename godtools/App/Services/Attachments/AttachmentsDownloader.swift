//
//  AttachmentsDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class AttachmentsDownloader {
    
    private let session: URLSession
    
    let attachmentsFileCache: AttachmentsFileCache
    
    required init(attachmentsFileCache: AttachmentsFileCache, sharedSession: SharedSessionType) {
                    
        self.session = sharedSession.session
        self.attachmentsFileCache = attachmentsFileCache
    }
    
    func downloadAndCacheAttachments(attachmentFiles: [AttachmentFile]) -> DownloadAttachmentsReceipt? {
        
        guard !attachmentFiles.isEmpty else {
            return nil
        }
                        
        let queue = OperationQueue()
                
        let receipt = DownloadAttachmentsReceipt()
             
        var operations: [RequestOperation] = Array()
        var numberOfOperationsCompleted: Double = 0
        var totalOperationCount: Double = 0
        
        for attachmentFile in attachmentFiles {
                                    
            if !attachmentsFileCache.attachmentExists(location: attachmentFile.location) {
                                
                let operation = RequestOperation(session: session, urlRequest: URLRequest(url: attachmentFile.remoteFileUrl))
                
                operations.append(operation)
                
                operation.setCompletionHandler { [weak self] (response: RequestResponse) in
                    
                    self?.processDownloadedAttachment(attachmentFile: attachmentFile, response: response, complete: { (result: DownloadedAttachmentResult) in
                        
                        numberOfOperationsCompleted += 1
                        
                        receipt.handleAttachmentDownloaded(result: result)
                        receipt.setProgress(value: numberOfOperationsCompleted / totalOperationCount)
                        
                        if queue.operations.isEmpty {
                            receipt.complete()
                        }
                    })
                }
            }
            else {
                attachmentsFileCache.addAttachmentReferencesIfNeeded(attachmentFile: attachmentFile) { (error: Error?) in
                    
                }
            }
        }
        
        if !operations.isEmpty {
            numberOfOperationsCompleted = 0
            totalOperationCount = Double(operations.count)
            receipt.start(queue: queue)
            queue.addOperations(operations, waitUntilFinished: false)
            return receipt
        }
        else {
            return nil
        }
    }
    
    private func processDownloadedAttachment(attachmentFile: AttachmentFile, response: RequestResponse, complete: @escaping ((_ result: DownloadedAttachmentResult) -> Void)) {
        
        let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
        
        switch result {
        
        case .success( _, _):
            
            if let fileData = response.data {
                
                attachmentsFileCache.cacheAttachmentFile(attachmentFile: attachmentFile, fileData: fileData, complete: { (cacheError: Error?) in
                    
                    let downloadError: AttachmentsDownloaderError?
                    
                    if let cacheError = cacheError {
                        downloadError = .failedToCacheAttachment(error: cacheError)
                    }
                    else {
                        downloadError = nil
                    }
                    
                    complete(DownloadedAttachmentResult(attachmentFile: attachmentFile, downloadError: downloadError))
                })
            }
            else {
                let downloadError: AttachmentsDownloaderError = .noAttachmentData(missingAttachmentData: NoAttachmentData(remoteFileUrl: attachmentFile.remoteFileUrl))
                complete(DownloadedAttachmentResult(attachmentFile: attachmentFile, downloadError: downloadError))
            }
        
        case .failure(let downloadError):
            let downloadError: AttachmentsDownloaderError = .failedToCacheAttachment(error: downloadError)
            complete(DownloadedAttachmentResult(attachmentFile: attachmentFile, downloadError: downloadError))
        }
    }
}
