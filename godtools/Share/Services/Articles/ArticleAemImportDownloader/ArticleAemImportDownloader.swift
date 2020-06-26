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
        
    typealias TranslationId = String
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let realmCache: RealmArticleAemImportDataCache
    private let webArchiver: WebArchiveQueue = WebArchiveQueue()
    private let webArchiveFileCache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    private let maxAemImportJsonTreeLevels: Int = 10
    private let errorDomain: String = String(describing: ArticleAemImportDownloader.self)
    
    private var currentDownloadReceipts: [TranslationId: ArticleAemImportDownloaderReceipt] = Dictionary()
    
    required init(realmDatabase: RealmDatabase) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
            
        session = URLSession(configuration: configuration)
        
        self.realmCache = RealmArticleAemImportDataCache(realmDatabase: realmDatabase)
    }
    
    func getArticlesWithTags(translationManifest: TranslationManifestData, aemTags: [String], completeOnMain: @escaping ((_ articleAemImportData: [ArticleAemImportData]) -> Void)) {
        
        let resourceId: String = translationManifest.translationZipFile.resourceId
        let languageCode: String = translationManifest.translationZipFile.languageCode
        
        realmCache.getArticlesWithTags(resourceId: resourceId, languageCode: languageCode, aemTags: aemTags, completeOnMain: completeOnMain)
    }
    
    func getWebArchiveUrl(location: ArticleAemWebArchiveFileCacheLocation) -> URL? {
        
        switch webArchiveFileCache.getFile(location: location) {
        case .success(let url):
            return url
        case .failure( _):
            return nil
        }
    }
    
    func getDownloadReceipt(translationManifest: TranslationManifestData) -> ArticleAemImportDownloaderReceipt {
        
        let translationId: String = translationManifest.translationZipFile.translationId
        
        if let receipt = currentDownloadReceipts[translationId] {
            return receipt
        }
        else {
            let receipt = ArticleAemImportDownloaderReceipt()
            currentDownloadReceipts[translationId] = receipt
            return receipt
        }
    }
    
    func articlesCached(translationManifest: TranslationManifestData) -> Bool {
        
        return ArticlesCacheValidation(translationManifest: translationManifest).isCached
    }
    
    func articlesCacheExpired(translationManifest: TranslationManifestData) -> Bool {
        
        return ArticlesCacheValidation(translationManifest: translationManifest).cacheExpired
    }
    
    func downloadAndCache(translationManifest: TranslationManifestData, aemImportSrcs: [String]) -> ArticleAemImportDownloaderReceipt? {
                
        print("\n DOWNLOAD TO CACHE AND WEB ARCHIVE")
        
        let queue = OperationQueue()
        
        let receipt = getDownloadReceipt(translationManifest: translationManifest)
        
        var operations: [ArticleAemImportOperation] = Array()
        
        let resourceId: String = translationManifest.translationZipFile.resourceId
        let languageCode: String = translationManifest.translationZipFile.languageCode
        
        var articleAemImportDataObjects: [ArticleAemImportData] = Array()
        var articleAemImportErrors: [ArticleAemImportOperationError] = Array()
                        
        for aemImportSrc in aemImportSrcs {
            
            let operation = ArticleAemImportOperation(
                session: session,
                resourceId: resourceId,
                languageCode: languageCode,
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
                        
                        self?.handleReceiptCancelled(receipt: receipt, translationManifest: translationManifest)
                        
                        return
                    }
                    
                    let cacheValidation = ArticlesCacheValidation(translationManifest: translationManifest)
                    
                    print("\n HANDLE DOWNLOAD COMPLETED")
                    
                    // Delete web archives and realm objects for resourceId, languageCode
                    print("  DELETE WEB ARCHIVES")
                    let deleteWebArchiveDirectoryError: Error? = self?.webArchiveFileCache.deleteWebArchiveDirectory(
                        resourceId: resourceId,
                        languageCode: languageCode
                    )
                    
                    print("  DELETE REALM AEM OBJECTS")
                    self?.realmCache.deleteAemImportDataObjects(resourceId: resourceId, languageCode: languageCode) { [weak self] (deleteArticleAemImportDataObjectsError: Error?) in
                        
                        print("  CACHEING NEW REALM OBJECTS")
                        self?.realmCache.cache(articleAemImportDataObjects: articleAemImportDataObjects) { (cacheArticleAemImportDataObjectsError: Error?) in
                            
                            print("  CACHE NEW WEB ARCHIVES")
                            _ = self?.archiveAemImportData(resourceId: resourceId, languageCode: languageCode, articleAemImportDataObjects: articleAemImportDataObjects, complete: { (cacheWebArchivePlistDataErrors: [CacheArticleAemWebArchivePlistError], webArchiveQueueResult: WebArchiveQueueResult) in
                                
                                let result = ArticleAemImportDownloaderResult(
                                    resourceId: resourceId,
                                    languageCode: languageCode,
                                    articleAemImportDataObjects: articleAemImportDataObjects,
                                    articleAemImportErrors: articleAemImportErrors,
                                    deleteWebArchiveDirectoryError: deleteWebArchiveDirectoryError,
                                    deleteArticleAemImportDataObjectsError: deleteArticleAemImportDataObjectsError,
                                    cacheArticleAemImportDataObjectsError: cacheArticleAemImportDataObjectsError,
                                    cacheWebArchivePlistDataErrors: cacheWebArchivePlistDataErrors,
                                    webArchiveQueueResult: webArchiveQueueResult,
                                    cancelled: false
                                )
                                
                                if result.downloadError == nil {
                                    cacheValidation.setCached()
                                }
                                
                                receipt.completeDownload(result: result)
                            })
                        }
                    }
                    
                }// queue.operations.isEmpty
            }
        }
        
        if !operations.isEmpty {
            receipt.startDownload(downloadAemImportsQueue: queue)
            currentDownloadReceipts[translationManifest.translationZipFile.translationId] = receipt
            queue.addOperations(operations, waitUntilFinished: false)
            return receipt
        }
        else {
            return nil
        }
    }
    
    private func handleReceiptCancelled(receipt: ArticleAemImportDownloaderReceipt, translationManifest: TranslationManifestData) {
        
        let result = ArticleAemImportDownloaderResult(
            resourceId: translationManifest.translationZipFile.resourceId,
            languageCode: translationManifest.translationZipFile.languageCode,
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
    
    private func archiveAemImportData(resourceId: String, languageCode: String, articleAemImportDataObjects: [ArticleAemImportData], complete: @escaping ((_ cacheWebArchivePlistDataErrors: [CacheArticleAemWebArchivePlistError], _ webArchiveQueueResult: WebArchiveQueueResult) -> Void)) -> OperationQueue {
                
        print("\n ARCHIVE AEM IMPORT DATA")
        
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
                
                let cacheLocation = ArticleAemWebArchiveFileCacheLocation(
                    resourceId: resourceId,
                    languageCode: languageCode,
                    filename: webArchiveFilename
                )

                if let cacheResult = self?.webArchiveFileCache.cache(location: cacheLocation, data: webArchivePlistData) {
                    switch cacheResult {
                    case .success(let url):
                        break
                    case .failure(let error):
                        let cachePlistError = CacheArticleAemWebArchivePlistError(
                            resourceId: resourceId,
                            languageCode: languageCode,
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
