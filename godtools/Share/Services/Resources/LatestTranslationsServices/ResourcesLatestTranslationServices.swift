//
//  ResourcesLatestTranslationServices.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesLatestTranslationServices {
        
    private let translationsApi: TranslationsApiType
            
    let fileCache: ResourcesLatestTranslationsFileCache = ResourcesLatestTranslationsFileCache()
    
    required init(translationsApi: TranslationsApiType) {
        
        self.translationsApi = translationsApi
    }

    func getManifestXmlData(godToolsResource: GodToolsResource, forceDownload: Bool, complete: @escaping ((_ xmlData: Data?, _ error: ResourcesLatestTranslationServicesError?) -> Void)) -> OperationQueue? {
                
        if let cachedXmlData = getCachedManifestXmlData(godToolsResource: godToolsResource), !forceDownload {
            
            complete(cachedXmlData, nil)
            
            return nil
        }
        else {
            
            let fileCacheRef = self.fileCache
            let cacheLocation = ResourcesLatestTranslationsFileCacheLocation(godToolsResource: godToolsResource)
                        
            return downloadTranslationZipDataToCache(godToolsResource: godToolsResource) { (error: ResourcesLatestTranslationServicesError?) in
                
                if let error = error {
                    complete(nil, error)
                }
                else {
                    
                    switch fileCacheRef.getData(location: cacheLocation, path: godToolsResource.translationManifestFilename) {
                    case .success(let xmlData):
                        complete(xmlData, nil)
                    case .failure(let error):
                        complete(nil, .failedToGetCachedTranslationData(error: error))
                    }
                }
            }
        }
    }
    
    func getCachedManifestXmlData(godToolsResource: GodToolsResource) -> Data? {
        
        let cacheLocation = ResourcesLatestTranslationsFileCacheLocation(godToolsResource: godToolsResource)
        let translationManifestFileName: String = godToolsResource.translationManifestFilename
        
        return fileCache.getCachedManifestXmlData(
            cacheLocation: cacheLocation,
            translationManifestFileName: translationManifestFileName
        )
    }
    
    private func downloadTranslationZipDataToCache(godToolsResource: GodToolsResource, complete: @escaping ((_ error: ResourcesLatestTranslationServicesError?) -> Void)) -> OperationQueue {
        
        return translationsApi.getTranslationZipData(translationId: godToolsResource.translationId, complete: { [weak self] (result: Result<Data?, ResponseError<NoClientApiErrorType>>) in
            
            switch result {
                
            case .success(let zipData):
                
                if let zipData = zipData, let fileCache = self?.fileCache {
                    
                    let cacheLocation = ResourcesLatestTranslationsFileCacheLocation(godToolsResource: godToolsResource)
                    
                    switch fileCache.cacheContents(location: cacheLocation, zipData: zipData) {
                    case .success( _):
                        complete(nil)
                    case .failure(let error):
                        complete(.failedToCacheTranslationData(error: error))
                    }
                }
            
            case .failure(let error):
                complete(.apiError(error: error))
            }
        })
    }
}
