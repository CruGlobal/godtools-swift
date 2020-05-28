//
//  ArticlesService.swift
//  godtools
//
//  Created by Levi Eggert on 5/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ArticlesService {
    
    private let resourceCacheValidation: ResourceCacheValidation = ResourceCacheValidation()
    
    private var getManifestXmlOperation: OperationQueue?
    
    let resourceLatestTranslationServices: ResourcesLatestTranslationServices
    let articleAemImportService: ArticleAemImportService
    
    required init(resourceLatestTranslationServices: ResourcesLatestTranslationServices, realm: Realm) {
        
        self.resourceLatestTranslationServices = resourceLatestTranslationServices
        self.articleAemImportService = ArticleAemImportService(realm: realm)
    }
    
    func cancel() {
        getManifestXmlOperation?.cancelAllOperations()
        articleAemImportService.cancel()
    }
    
    func downloadAndCacheArticleData(godToolsResource: GodToolsResource, forceDownload: Bool, complete: @escaping ((_ result: Result<ArticleManifestXmlParser, ArticlesServiceError>) -> Void)) {
                        
        let secondsInDay: TimeInterval = 86400
        let cacheExpirationSeconds: TimeInterval = secondsInDay * 7
        
        let manifestXmlData: Data? = resourceLatestTranslationServices.getCachedManifestXmlData(godToolsResource: godToolsResource)
        
        if !forceDownload, !resourceCacheValidation.cachedResourceIsInvalid(godToolsResource: godToolsResource, cacheExpirationSeconds: cacheExpirationSeconds), let manifestXmlData = manifestXmlData {
            complete(.success(ArticleManifestXmlParser(xmlData: manifestXmlData)))
            return
        }
        
        getManifestXmlOperation = resourceLatestTranslationServices.getManifestXmlData(godToolsResource: godToolsResource, forceDownload: forceDownload) { [weak self] (manifestXmlData: Data?, error: Error?) in
            
            if let manifestXmlData = manifestXmlData {
                
                let articleManifest = ArticleManifestXmlParser(xmlData: manifestXmlData)
                
                self?.articleAemImportService.downloadToCacheAndWebArchive(godToolsResource: godToolsResource, aemImportSrcs: articleManifest.aemImportSrcs, complete: { (error: ArticleAemImportServiceError?) in
                    
                    if let error = error {
                        complete(.failure(.aemImportServiceError(error: error)))
                    }
                    else {
                        self?.resourceCacheValidation.setResourceCached(godToolsResource: godToolsResource)
                        complete(.success(articleManifest))
                    }
                })
            }
            else if let error = error {
                complete(.failure(.fetchManifestError(error: error)))
            }
            else {
                let unknownError: Error = NSError(
                    domain: String(describing: ArticlesService.self),
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]
                )
                complete(.failure(.fetchManifestError(error: unknownError)))
            }
        }
    }
    
    func getCachedArticlesManifestXml(godToolsResource: GodToolsResource) -> ArticleManifestXmlParser? {
        
        if let data = resourceLatestTranslationServices.getCachedManifestXmlData(godToolsResource: godToolsResource) {
            
            return ArticleManifestXmlParser(xmlData: data)
        }
        
        return nil
    }
}
