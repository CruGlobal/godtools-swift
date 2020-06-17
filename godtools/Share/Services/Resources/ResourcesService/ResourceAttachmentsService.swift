//
//  ResourceAttachmentsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourceAttachmentsService {
    
    typealias AttachmentId = String
    
    private let session: URLSession
    private let realmDatabase: RealmDatabase
    private let sha256FileCache: SHA256FilesCache
    
    private var bannerImageMemoryCache: [AttachmentId: UIImage] = Dictionary()
    private var currentQueue: OperationQueue?
    
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let progress: ObservableValue<Double> = ObservableValue(value: 0)
    let completed: Signal = Signal()
    
    required init(realmDatabase: RealmDatabase, sha256FileCache: SHA256FilesCache) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
            
        self.session = URLSession(configuration: configuration)
        self.realmDatabase = realmDatabase
        self.sha256FileCache = sha256FileCache
    }
    
    func downloadAndCacheAttachments(from result: RealmResourcesCacheResult) {
        
        if currentQueue != nil {
            assertionFailure("ResourceAttachmentsDownloaderAndCache:  Download is already running, this process only needs to run once when reloading all resource attachments from the server.")
            return
        }
                
        let queue: OperationQueue = OperationQueue()
        
        self.currentQueue = queue
        
        if result.attachmentFiles.isEmpty {
            handleDownloadAndCacheAttachmentsCompleted()
            return
        }
        
        var numberOfAttachmentsDownloaded: Double = 0
        var totalNumberOfAttachmentsToDownload: Double = 0
        var attachmentDownloadOperations: [RequestOperation] = Array()
        
        for attachmentFile in result.attachmentFiles {
                        
            let location: SHA256FileLocation = attachmentFile.location
            
            if !attachmentFileExists(location: location) {
                                
                let attachmentOperation = RequestOperation(session: session, urlRequest: URLRequest(url: attachmentFile.remoteFileUrl))
                
                attachmentDownloadOperations.append(attachmentOperation)
                
                attachmentOperation.completionHandler { [weak self] (response: RequestResponse) in
                    
                    let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
                    
                    switch result {
                    case .success( _, _):
                        
                        if let fileData = response.data {
                            
                            let cacheError: Error? = self?.cacheAttachmentFile(location: location, fileData: fileData)
                            
                            if let cacheError = cacheError {
                                print("\n Failed to cache attachment: \(cacheError)")
                            }
                            else {
                                self?.addAttachmentReferencesIfNeeded(
                                    location: location,
                                    attachmentIds: attachmentFile.relatedAttachmentIds
                                )
                            }
                        }
                    case .failure(let error):
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
                addAttachmentReferencesIfNeeded(
                    location: location,
                    attachmentIds: attachmentFile.relatedAttachmentIds
                )
            }
        }
        
        if !attachmentDownloadOperations.isEmpty {
            numberOfAttachmentsDownloaded = 0
            totalNumberOfAttachmentsToDownload = Double(attachmentDownloadOperations.count)
            started.accept(value: true)
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
    
    func getAttachmentBanner(attachmentId: String, complete: @escaping ((_ image: UIImage?) -> Void)) {
        
        if let image = bannerImageMemoryCache[attachmentId] {
            complete(image)
            return
        }
        
        let sha256FileCacheRef: SHA256FilesCache = sha256FileCache
        
        realmDatabase.background { (realm: Realm) in
            
            var image: UIImage?
            
            let attachment: RealmAttachment? = realm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId)
                
            if let attachment = attachment {
                
                let sha256FileLocation: SHA256FileLocation = attachment.sha256FileLocation
                                
                switch sha256FileCacheRef.getImage(location: sha256FileLocation) {
                case .success(let cachedImage):
                    image = cachedImage
                case .failure( _):
                    break
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                
                if let image = image {
                    self?.bannerImageMemoryCache[attachmentId] = image
                }
                
                complete(image)
            }
        }
    }
    
    func attachmentFileExists(location: SHA256FileLocation) -> Bool {
        
        switch sha256FileCache.fileExists(location: location) {
        case .success(let fileExists):
            return fileExists
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return false
        }
    }
    
    private func cacheAttachmentFile(location: SHA256FileLocation, fileData: Data) -> Error? {
        
        return sha256FileCache.cacheSHA256File(location: location, fileData: fileData)
    }
    
    private func addAttachmentReferencesIfNeeded(location: SHA256FileLocation, attachmentIds: [String]) {
            
        guard !attachmentIds.isEmpty else {
            return
        }
        
        realmDatabase.background { (realm: Realm) in
            
            var attachmentReferences: [RealmAttachment] = Array()
            
            for attachmentId in attachmentIds {
                if let realmAttachment = realm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId) {
                    attachmentReferences.append(realmAttachment)
                }
            }
            
            if let existingRealmSHA256File = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: location.sha256WithPathExtension) {
                
                do {
                    try realm.write {
                        for attachment in attachmentReferences {
                            if !existingRealmSHA256File.attachments.contains(attachment) {
                                existingRealmSHA256File.attachments.append(attachment)
                            }
                        }
                    }
                }
                catch let error {
                    assertionFailure(error.localizedDescription)
                }
            }
            else {
                
                let newRealmSHA256File: RealmSHA256File = RealmSHA256File()
                newRealmSHA256File.sha256WithPathExtension = location.sha256WithPathExtension
                newRealmSHA256File.attachments.append(objectsIn: attachmentReferences)
                do {
                    try realm.write {
                        realm.add(newRealmSHA256File, update: .all)
                    }
                }
                catch let error {
                    assertionFailure(error.localizedDescription)
                }
            }
        }
    }
}
