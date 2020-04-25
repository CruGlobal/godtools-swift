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
    private let aemWebArchiver = WebArchiveQueue()
    private let aemWebArchiveFileCache: ArticleAemWebArchiveFileCache = ArticleAemWebArchiveFileCache()
    private let godToolsResource: GodToolsResource
    private let maxAemImportJsonTreeLevels: Int = 10
    
    private var downloadOperation: OperationQueue?
    private var archiveOperation: OperationQueue?
        
    let isDownloadingAemImportData: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(realm: Realm, godToolsResource: GodToolsResource) {
        aemImportDataRealmCache = RealmArticleAemImportDataCache(realm: realm)
        self.godToolsResource = godToolsResource
    }
    
    func cancelDownload() {
        downloadOperation?.cancelAllOperations()
        archiveOperation?.cancelAllOperations()
    }
    
    func getArticlesWithTags(aemTags: [String]) -> [RealmArticleAemImportData] {
        return aemImportDataRealmCache.getArticlesWithTags(aemTags: aemTags)
    }
    
    func download(aemImportSrcs: [String], complete: @escaping (() -> Void)) {
           
        guard !isDownloadingAemImportData.value else {
            return
        }
        
        // TODO: Need to invalidate cache at some point. ~Levi
        _ = aemImportDataRealmCache.deleteAllData()
        
        if aemImportDataRealmCache.dataExistsInCache {
            
            complete()
        }
        else {
            
            isDownloadingAemImportData.accept(value: true)
            
            var downloadedArticleAemImportData: [ArticleAemImportData] = Array()
            
            downloadOperation = aemImportApi.downloadAemImportSrcs(aemImportSrcs: aemImportSrcs, maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels, didDownloadAemImport: { (response: RequestResponse, result: Result<ArticleAemImportData, Error>) in
                
                switch result {
                case .success(let articleAemImportData):
                    downloadedArticleAemImportData.append(articleAemImportData)
                case .failure(let error):
                    print("\n \(String(describing: ArticleAemImportService.self)) Failed to download aemImportSrc with error: \(error)")
                }
                
            }, complete: { [weak self] in
                
                DispatchQueue.main.async { [weak self] in
                        
                    print("\n CACHE ARTICLE AEM IMPORT DATA TO REALM")
                    // cache articleAemImportData to realm
                    self?.aemImportDataRealmCache.cache(articleAemImportDataObjects: downloadedArticleAemImportData, complete: { [weak self] (error: Error?) in
                        
                        print("\n DID CACHE TO REALM")
                        
                        let articleAemImportUrls: [URL] = downloadedArticleAemImportData.compactMap {
                            URL(string: $0.webUrl)
                        }
                        
                        // archive articleAemImportData urls
                        print("\n ARCHIVE AEM IMPORT URLS")
                        self?.archiveAemImportUrls(urls: articleAemImportUrls, complete: { [weak self] in
                            
                            print("\n DID ARCHIVE AEM IMPORT URLS")
                            
                            DispatchQueue.main.async { [weak self] in
                                
                                self?.isDownloadingAemImportData.accept(value: false)
                                
                                complete()
                            }
                        })
                    })
                }
            })
        }
    }
    
    private func archiveAemImportUrls(urls: [URL], complete: @escaping (() -> Void)) {
        
        let godToolsResource: GodToolsResource = self.godToolsResource
        
        archiveOperation = aemWebArchiver.archive(urls: urls, didArchivePlistData: { [weak self] (result: Result<WebArchiveOperationResult, Error>) in
            
            switch result {
            case .success(let operationResult):
                
                print("  did archive aem import plist data")
                
                print("    godtools resource: \(godToolsResource)")
                print("    url: \(operationResult.url)")
                print("    plist data: \(operationResult.webArchivePlistData)")
                
                print("  ensure plist data exists")
                guard let plistData = operationResult.webArchivePlistData else {
                    return
                }
                
                let cacheLocation = ArticleAemWebArchiveFileCacheLocation(godToolsResource: godToolsResource, aemImportUrl: operationResult.url)
                
                if let cacheResult = self?.aemWebArchiveFileCache.cache(location: cacheLocation, data: plistData) {
                    switch cacheResult {
                    case .success(let url):
                        print("\n \(String(describing: ArticleAemImportService.self)) Did cache aem webarchive at url: \(url.absoluteString)")
                    case .failure(let error):
                        print("\n \(String(describing: ArticleAemImportService.self)) Failed to cache aem webarchive with error: \(error)")
                    }
                }
            case .failure(let error):
                break
            }
            
        }, complete: { [weak self] in
            
            
            print("\n FINISHED ARCHIVING")
            
            complete()
        })
    }
}
