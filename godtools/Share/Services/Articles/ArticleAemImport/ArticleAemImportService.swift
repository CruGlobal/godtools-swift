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
    
    private let api: ArticleAemImportApi = ArticleAemImportApi()
    private let cache: RealmArticleAemImportDataCache
    private let maxAemImportJsonTreeLevels: Int = 10
    
    private var downloadOperation: OperationQueue?
        
    let isDownloadingAemImportData: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(realm: Realm) {
        cache = RealmArticleAemImportDataCache(realm: realm)
    }
    
    func cancelDownload() {
        downloadOperation?.cancelAllOperations()
    }
    
    func getArticlesWithTags(aemTags: [String]) -> [RealmArticleAemImportData] {
        return cache.getArticlesWithTags(aemTags: aemTags)
    }
    
    func download(aemImportSrcs: [String], complete: @escaping (() -> Void)) {
           
        guard !isDownloadingAemImportData.value else {
            return
        }
        
        // TODO: Need to invalidate cache at some point. ~Levi
        _ = cache.deleteAllData()
        
        if cache.dataExistsInCache {
            
            complete()
        }
        else {
            
            isDownloadingAemImportData.accept(value: true)
            
            var downloadedArticleAemImportData: [ArticleAemImportData] = Array()
            
            downloadOperation = api.downloadAemImportSrcs(aemImportSrcs: aemImportSrcs, maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels, didDownloadAemImport: { (response: RequestResponse, result: Result<ArticleAemImportData, Error>) in
                
                switch result {
                case .success(let articleAemImportData):
                    downloadedArticleAemImportData.append(articleAemImportData)
                case .failure(let error):
                    print("\n \(String(describing: ArticleAemImportService.self)) Failed to download aemImportSrc with error: \(error)")
                }
                
            }, complete: { [weak self] in
                
                DispatchQueue.main.async { [weak self] in
                        
                    // cache to realm
                    for articleAemImportData in downloadedArticleAemImportData {
                        if let cacheError = self?.cache.cache(articleAemImportData: articleAemImportData) {
                            print("\n \(String(describing: ArticleAemImportService.self)) Failed to cache aemImportSrc with error: \(cacheError)")
                        }
                    }
                    
                    self?.isDownloadingAemImportData.accept(value: false)
                    
                    complete()
                }
            })
        }
    }
//
//    private func cache(aemImportData: [ArticleAemImportData]) {
//
//        for articleAemImportData in aemImportData {
//            let cacheError: Error? = self?.cache.cache(articleAemImportData: articleAemImportData)
//            if let error = cacheError {
//                print("\n \(String(describing: ArticleAemImportService.self)) Failed to cache aemImportSrc with error: \(error)")
//            }
//            else if let url = URL(string: articleAemImportData.webUrl) {
//                self?.webArchiveQueue.archive(url: url, complete: { (result: Result<Data?, Error>) in
//                    switch result {
//                    case .success(let plistData):
//                        print("\n Did archive plist data")
//                        if let plistData = plistData {
//                            print("  cacheing plist data: \(plistData)")
//                            if let cacheResult = self?.webArchiveCache.cache(location: FileCacheLocation(directory: "test", filename: "plist_data", fileExtension: "webarchive"), data: plistData) {
//                                switch cacheResult {
//                                case .success(let url):
//                                    print("\n did cache at url: \(url)")
//                                case .failure(let error):
//                                    print("  failed to cache plist data with error: \(error)")
//                                }
//                            }
//                        }
//                    case .failure(let error):
//                        print("\n \(String(describing: ArticleAemImportService.self)) Failed to archive aemImportSrc with error: \(error)")
//                    }
//                })
//            }
//        }
//    }
}
