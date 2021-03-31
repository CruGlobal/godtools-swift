//
//  ArticleAemImportDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ArticleAemImportDownloader {
        
    typealias AemUri = String
    
    private let session: URLSession
    private let realmCache: RealmArticleAemImportDataCache
    private let webArchiver: WebArchiveQueue
    private let webArchiveFileCache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    private let maxAemImportJsonTreeLevels: Int = 10
    private let errorDomain: String = String(describing: ArticleAemImportDownloader.self)
        
    required init(realmDatabase: RealmDatabase, sharedSession: SharedSessionType) {
        
        self.session = sharedSession.session
        self.realmCache = RealmArticleAemImportDataCache(realmDatabase: realmDatabase)
        self.webArchiver = WebArchiveQueue(sharedSession: sharedSession)
    }
    
    func getArticlesWithTags(aemTags: [String], completeOnMain: @escaping ((_ articleAemImportData: [ArticleAemImportData]) -> Void)) {
        
        realmCache.getArticlesWithTags(aemTags: aemTags, completeOnMain: completeOnMain)
    }
    
    func getWebArchiveUrl(location: ArticleAemWebArchiveFileCacheLocation) -> URL? {
        
        switch webArchiveFileCache.getFile(location: location) {
        case .success(let url):
            return url
        case .failure( _):
            return nil
        }
    }
    
    func articlesCached(translationZipFile: TranslationZipFileModel) -> Bool {
        
        return ArticlesCacheValidation(translationZipFile: translationZipFile).isCached
    }
    
    func articlesCacheExpired(translationZipFile: TranslationZipFileModel) -> Bool {
        
        return ArticlesCacheValidation(translationZipFile: translationZipFile).cacheExpired
    }
    
    func downloadAndCache(aemImportSrcs: [String]) -> ArticleAemImportDownloaderReceipt {
                        
        let queue = OperationQueue()
        
        let receipt = ArticleAemImportDownloaderReceipt()
        
        var operations: [ArticleAemImportOperation] = Array()
                
        var articleAemImportDataObjects: [ArticleAemImportData] = Array()
        var articleAemImportErrors: [ArticleAemImportOperationError] = Array()
                        
        for aemImportSrc in aemImportSrcs {
            
            let operation = ArticleAemImportOperation(
                session: session,
                aemImportSrc: aemImportSrc,
                maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels
            )
            
            operations.append(operation)
            
            operation.completionHandler { [weak self] (response: RequestResponse, result: Result<ArticleAemImportData, ArticleAemImportOperationError>) in
                
                switch result {
                    
                case .success(let articleAemImportData):
                    articleAemImportDataObjects.append(articleAemImportData)
                    
                case .failure(let aemImportOperationError):
                    articleAemImportErrors.append(aemImportOperationError)
                }
                                                
                if queue.operations.isEmpty {
                    
                    guard !receipt.isCancelled && !articleAemImportDataObjects.isEmpty else {
                        
                        self?.handleReceiptCancelled(receipt: receipt)
                        
                        return
                    }
                                                            
                    // Delete web archives and realm objects for resourceId, languageCode
                    
                    // TODO: No longer cacheing articles by resourceId and languageCode. Need to do this differently. ~Levi
                    /*
                    let deleteWebArchiveDirectoryError: Error? = self?.webArchiveFileCache.deleteWebArchiveDirectory(
                        resourceId: resourceId,
                        languageCode: languageCode
                    )*/
                    
                    self?.realmCache.deleteAemImportDataObjects() { [weak self] (deleteArticleAemImportDataObjectsError: Error?) in
                        
                        self?.realmCache.cache(articleAemImportDataObjects: articleAemImportDataObjects) { (cacheArticleAemImportDataObjectsError: Error?) in
                            
                            _ = self?.archiveAemImportData(articleAemImportDataObjects: articleAemImportDataObjects, complete: { (cacheWebArchivePlistDataErrors: [CacheArticleAemWebArchivePlistError], webArchiveQueueResult: WebArchiveQueueResult) in
                                
                                let result = ArticleAemImportDownloaderResult(
                                    articleAemImportDataObjects: articleAemImportDataObjects,
                                    articleAemImportErrors: articleAemImportErrors,
                                    deleteWebArchiveDirectoryError: nil,
                                    deleteArticleAemImportDataObjectsError: deleteArticleAemImportDataObjectsError,
                                    cacheArticleAemImportDataObjectsError: cacheArticleAemImportDataObjectsError,
                                    cacheWebArchivePlistDataErrors: cacheWebArchivePlistDataErrors,
                                    webArchiveQueueResult: webArchiveQueueResult,
                                    cancelled: false
                                )
                                
                                receipt.completeDownload(result: result)
                            })
                        }
                    }
                    
                }// queue.operations.isEmpty
            }
        }
        
        if !operations.isEmpty {
            receipt.startDownload(downloadAemImportsQueue: queue)
            queue.addOperations(operations, waitUntilFinished: false)
            return receipt
        }
        else {
            return receipt
        }
    }
    
    private func handleReceiptCancelled(receipt: ArticleAemImportDownloaderReceipt) {
        
        let result = ArticleAemImportDownloaderResult(
            articleAemImportDataObjects: [],
            articleAemImportErrors: [],
            deleteWebArchiveDirectoryError: nil,
            deleteArticleAemImportDataObjectsError: nil,
            cacheArticleAemImportDataObjectsError: nil,
            cacheWebArchivePlistDataErrors: [],
            webArchiveQueueResult: WebArchiveQueueResult(successfulArchives: [], failedArchives: [], totalAttemptedArchives: 0),
            cancelled: true
        )
        
        receipt.completeDownload(result: result)
    }
    
    private func archiveAemImportData(articleAemImportDataObjects: [ArticleAemImportData], complete: @escaping ((_ cacheWebArchivePlistDataErrors: [CacheArticleAemWebArchivePlistError], _ webArchiveQueueResult: WebArchiveQueueResult) -> Void)) -> OperationQueue {
                        
        var urls: [URL] = Array()
        var webArchiveFilenames: [String] = Array()
        
        for aemImportData in articleAemImportDataObjects {
            if let url = URL(string: aemImportData.webUrl) {
                urls.append(url)
                webArchiveFilenames.append(aemImportData.webArchiveFilename)
            }
        }
           
        var cacheWebArchivePlistDataErrors: [CacheArticleAemWebArchivePlistError] = Array()
        
        return webArchiver.archive(urls: urls, didArchivePlistData: { [weak self] (result: Result<WebArchiveOperationResult, WebArchiveOperationError>) in
            
            switch result {
            
            case .success(let operationResult):

                let webArchivePlistData: Data = operationResult.webArchivePlistData
                let url: URL = operationResult.url
                var cacheFilename: String?
                if let index = urls.firstIndex(of: url) {
                    cacheFilename = webArchiveFilenames[index]
                }
                
                guard let webArchiveFilename = cacheFilename else {
                    assertionFailure("webArchiveFilename should always exist.")
                    return
                }
                
                let cacheLocation = ArticleAemWebArchiveFileCacheLocation(filename: webArchiveFilename)

                if let cacheResult = self?.webArchiveFileCache.cache(location: cacheLocation, data: webArchivePlistData) {
                    switch cacheResult {
                    case .success(let url):
                        break
                    case .failure(let error):
                        let cachePlistError = CacheArticleAemWebArchivePlistError(
                            webArchiveFilename: webArchiveFilename,
                            url: url,
                            error: error
                        )
                        cacheWebArchivePlistDataErrors.append(cachePlistError)
                    }
                }
                
            case .failure( _):
                break
            }
            
            }, complete: { (webArchiveQueueResult: WebArchiveQueueResult) in
                
            complete(cacheWebArchivePlistDataErrors, webArchiveQueueResult)
        })
    }
}
