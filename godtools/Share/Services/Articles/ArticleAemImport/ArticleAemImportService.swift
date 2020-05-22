//
//  ArticleAemImportService.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ArticleAemImportService {
        
    private let aemImportApi: ArticleAemImportApi = ArticleAemImportApi()
    private let aemImportDataRealmCache: RealmArticleAemImportDataCache
    private let aemWebArchiver: WebArchiveQueue = WebArchiveQueue()
    private let maxAemImportJsonTreeLevels: Int = 10
    private let errorDomain: String = String(describing: ArticleAemImportService.self)
    
    private var downloadAemImportSrcsOperation: OperationQueue?
    private var archiveOperation: OperationQueue?
        
    let aemWebArchiveFileCache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    
    required init(realm: Realm) {
        self.aemImportDataRealmCache = RealmArticleAemImportDataCache(realm: realm)
    }
    
    func cancel() {
        downloadAemImportSrcsOperation?.cancelAllOperations()
        archiveOperation?.cancelAllOperations()
    }
    
    func getArticlesWithTags(godToolsResource: GodToolsResource, aemTags: [String]) -> [RealmArticleAemImportData] {
        return aemImportDataRealmCache.getArticlesWithTags(godToolsResource: godToolsResource, aemTags: aemTags)
    }
    
    func downloadToCacheAndWebArchive(godToolsResource: GodToolsResource, aemImportSrcs: [String], complete: @escaping (( _ error: ArticleAemImportServiceError?) -> Void)) {
                
        print("\n DOWNLOAD TO CACHE AND WEB ARCHIVE")
                
        var downloadedAemImportData: [ArticleAemImportData] = Array()
        
        downloadAemImportSrcsOperation = aemImportApi.downloadAemImportSrcs(godToolsResource: godToolsResource, aemImportSrcs: aemImportSrcs, maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels, didDownloadAemImport: { [weak self] (response: RequestResponse, result: Result<ArticleAemImportData, ArticleAemImportOperationError>) in
            
            switch result {
            
            case .success(let articleAemImportData):
                downloadedAemImportData.append(articleAemImportData)
                                    
            case .failure(let error):
                print("\n \(String(describing: ArticleAemImportService.self)) Failed to download aemImportSrc with error: \(error)")
            }
            
        }, complete: { [weak self] (error: ArticleAemImportApiError?) in

            if let apiError = error {
                
                complete(.apiError(error: apiError))
            }
            if downloadedAemImportData.count > 0 {
                            
                self?.deleteCachedAemImportData(godToolsResource: godToolsResource, complete: { [weak self] in
                    
                    self?.archiveAndCacheAemImportData(aemImportDataObjects: downloadedAemImportData, godToolsResource: godToolsResource, complete: { (error: ArticleAemImportServiceError?) in
                        
                        complete(error)
                    })
                })
            }
            else {
                complete(nil)
            }
        })
    }
    
    private func deleteCachedAemImportData(godToolsResource: GodToolsResource, complete: @escaping (() -> Void)) {
        
        // Delete WebArchives
        
        // Filename is not needed here because we are just deleting the directory.
        let webArchiveCacheLocation = ArticleAemWebArchiveFileCacheLocation(
            godToolsResource: godToolsResource,
            filename: ""
        )
        
        var webArchiveDirectoryUrl: URL?
                
        switch aemWebArchiveFileCache.getRootDirectory() {
        case .success(let rootDirectoryUrl):
            webArchiveDirectoryUrl = rootDirectoryUrl.appendingPathComponent(webArchiveCacheLocation.directory)
        case .failure( _):
            break
        }
        
        if let webArchiveDirectoryUrl = webArchiveDirectoryUrl {
            if let error = aemWebArchiveFileCache.removeItem(url: webArchiveDirectoryUrl) {
                print("\n \(String(describing: ArticleAemImportService.self)) Failed to delete webarchives with error: \(error)")
            }
        }
        
        // Delete Realm Objects
        DispatchQueue.main.async { [weak self] in
            
            if let error = self?.aemImportDataRealmCache.deleteAemImportDataObjects(godToolsResource: godToolsResource) {
                print("\n \(String(describing: ArticleAemImportService.self)) Failed to delete article aem data from realm with error: \(error)")
            }
            
            complete()
        }
    }
    
    private func archiveAndCacheAemImportData(aemImportDataObjects: [ArticleAemImportData], godToolsResource: GodToolsResource, complete: @escaping ((_ error: ArticleAemImportServiceError?) -> Void)) {
        
        archiveAemImportData(aemImportDataObjects: aemImportDataObjects, godToolsResource: godToolsResource, complete: { [weak self] (error: ArticleAemImportServiceError?) in
                
            if let error = error {
                
                complete(error)
            }
            else {
                
                self?.cacheAemImportData(aemImportDataObjects: aemImportDataObjects, complete: { (error: ArticleAemImportServiceError?) in
                    
                    complete(error)
                })
            }
        })
    }
    
    private func cacheAemImportData(aemImportDataObjects: [ArticleAemImportData], complete: @escaping ((_ error: ArticleAemImportServiceError?) -> Void)) {
        
        print("\n CACHE AEM IMPORT DATA TO REALM")
        
        DispatchQueue.main.async { [weak self] in
            
            self?.aemImportDataRealmCache.cache(articleAemImportDataObjects: aemImportDataObjects, complete: { (cacheError: Error?) in
                        
                if let cacheError = cacheError {
                    complete(.failedToCacheAemImportDataToRealm(error: cacheError))
                }
                else {
                    complete(nil)
                }
            })
        }
    }
    
    private func archiveAemImportData(aemImportDataObjects: [ArticleAemImportData], godToolsResource: GodToolsResource, complete: @escaping ((_ error: ArticleAemImportServiceError?) -> Void)) {
                
        print("\n ARCHIVE AEM IMPORT DATA")
        
        var urls: [URL] = Array()
        var webArchiveFilenames: [String] = Array()
        
        for aemImportData in aemImportDataObjects {
            if let url = URL(string: aemImportData.webUrl) {
                urls.append(url)
                webArchiveFilenames.append(aemImportData.webArchiveFilename)
            }
        }
           
        var webArchiveOperationErrors: [WebArchiveOperationError] = Array()
        var cacheWebArchivePlistDataErrors: [Error] = Array()
        
        archiveOperation = aemWebArchiver.archive(urls: urls, didArchivePlistData: { [weak self] (result: Result<WebArchiveOperationResult, WebArchiveOperationError>) in
            
            switch result {
            
            case .success(let operationResult):

                let webArchivePlistData: Data = operationResult.webArchivePlistData
                let url: URL = operationResult.url
                var cacheFilename: String?
                if let index = urls.firstIndex(of: url) {
                    cacheFilename = webArchiveFilenames[index]
                }
                
                guard let webArchiveFilename = cacheFilename else {
                    // TODO: Should handle error here. ~Levi
                    return
                }
                
                let cacheLocation = ArticleAemWebArchiveFileCacheLocation(
                    godToolsResource: godToolsResource,
                    filename: webArchiveFilename
                )

                if let cacheResult = self?.aemWebArchiveFileCache.cache(location: cacheLocation, data: webArchivePlistData) {
                    switch cacheResult {
                    case .success(let url):
                        print("\n \(String(describing: ArticleAemImportService.self)) Did cache web archive plist data at url: \(url.absoluteString)")
                    case .failure(let error):
                        print("\n \(String(describing: ArticleAemImportService.self)) Failed to cache aem webarchive with error: \(error)")
                        cacheWebArchivePlistDataErrors.append(error)
                    }
                }
                
            case .failure(let operationError):
                print("\n \(String(describing: ArticleAemImportService.self)) Failed to archive aemImportData with error: \(operationError)")
                webArchiveOperationErrors.append(operationError)
            }
            
        }, complete: { [weak self] in
            
            if webArchiveOperationErrors.count == aemImportDataObjects.count {
                complete(.webArchiveOperationsFailed(webArchiveOperationErrors: webArchiveOperationErrors))
            }
            else if cacheWebArchivePlistDataErrors.count == aemImportDataObjects.count {
                complete(.failedToCacheWebArchivePlistData(cacheWebArchivePlistDataErrors: cacheWebArchivePlistDataErrors))
            }
            else {
                complete(nil)
            }
        })
    }
}
