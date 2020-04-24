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
    
    private let articleAemImportApi: ArticleAemImportApi = ArticleAemImportApi()
    private let maxAemImportJsonTreeLevels: Int = 10
    
    private var downloadAemImportDataOperation: OperationQueue?
        
    let articleAemImportCache: RealmArticleAemImportDataCache
    let isDownloadingAemImportData: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(realm: Realm) {
        articleAemImportCache = RealmArticleAemImportDataCache(realm: realm)
    }
    
    func cancelDownload() {
        downloadAemImportDataOperation?.cancelAllOperations()
    }
    
    func download(aemImportSrcs: [String], complete: @escaping (() -> Void)) {
           
        // TODO: Need to invalidate cache at some point. ~Levi
        _ = articleAemImportCache.deleteAllData()
        
        if articleAemImportCache.dataExistsInCache {
            
            complete()
        }
        else {
            
            isDownloadingAemImportData.accept(value: true)
            
            var downloadedArticleAemImportData: [ArticleAemImportData] = Array()
            
            downloadAemImportDataOperation = articleAemImportApi.downloadAemImportSrcs(aemImportSrcs: aemImportSrcs, maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels, didDownloadAemImport: { (response: RequestResponse, result: Result<ArticleAemImportData, Error>) in
                
                switch result {
                case .success(let articleAemImportData):
                    downloadedArticleAemImportData.append(articleAemImportData)
                case .failure(let error):
                    print("\n \(String(describing: ArticleAemImportService.self)) Failed to download aemImportSrc with error: \(error)")
                }
                
            }, complete: { [weak self] in
                
                DispatchQueue.main.async { [weak self] in
                    for articleAemImportData in downloadedArticleAemImportData {
                        let cacheError: Error? = self?.articleAemImportCache.cache(articleAemImportData: articleAemImportData)
                        if let error = cacheError {
                            print("\n \(String(describing: ArticleAemImportService.self)) Failed to cache aemImportSrc with error: \(error)")
                        }
                    }
                    
                    self?.isDownloadingAemImportData.accept(value: false)
                    complete()
                }
            })
        }
    }
}
