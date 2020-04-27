//
//  ResourceLatestTranslationServices.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceLatestTranslationServices {
        
    private let translationsApi: TranslationsApiType
    
    private var getTranslationZipDataOperation: OperationQueue?
        
    let fileCache: ResourcesLatestTranslationsFileCache = ResourcesLatestTranslationsFileCache()
    
    required init(translationsApi: TranslationsApiType) {
        
        self.translationsApi = translationsApi
    }
    
    func cancel() {
        getTranslationZipDataOperation?.cancelAllOperations()
    }
    
    func getManifestXmlData(godToolsResource: GodToolsResource, forceDownload: Bool, complete: @escaping ((_ xmlData: Data?, _ error: Error?) -> Void)) {
                
        let cacheLocation = ResourcesLatestTranslationsFileCacheLocation(godToolsResource: godToolsResource)
        let translationManifestFileName: String = godToolsResource.translationManifestFilename
        
        var contentsExist: Bool = false
        switch fileCache.contentsExist(location: cacheLocation) {
        case .success(let exist):
            contentsExist = exist
        case .failure( _):
            break
        }
        
        var cachedXmlData: Data?
        if contentsExist {
            switch fileCache.getData(location: cacheLocation, path: translationManifestFileName) {
            case .success(let xmlData):
                cachedXmlData = xmlData
            case .failure( _):
                break
            }
        }

        if let cachedXmlData = cachedXmlData, !forceDownload {
            
            complete(cachedXmlData, nil)
        }
        else {
            
            let fileCacheRef = self.fileCache
                        
            downloadTranslationZipDataToCache(godToolsResource: godToolsResource) { [weak self] (error: Error?) in
                
                if let error = error {
                    complete(nil, error)
                }
                else {
                    
                    switch fileCacheRef.getData(location: cacheLocation, path: translationManifestFileName) {
                    case .success(let xmlData):
                        complete(xmlData, nil)
                    case .failure(let error):
                        complete(nil, error)
                    }
                }
            }
        }
    }
    
    private func downloadTranslationZipDataToCache(godToolsResource: GodToolsResource, complete: @escaping ((_ error: Error?) -> Void)) {
        
        getTranslationZipDataOperation = translationsApi.getTranslationZipData(translationId: godToolsResource.translationId, complete: { [weak self] (response: RequestResponse, result: RequestResult<Data, Error>) in
            
            switch result {
                
            case .success(let zipData):
                
                if let zipData = zipData, let fileCache = self?.fileCache {
                    
                    let cacheLocation = ResourcesLatestTranslationsFileCacheLocation(godToolsResource: godToolsResource)
                    
                    switch fileCache.cacheContents(location: cacheLocation, zipData: zipData) {
                    case .success( _):
                        complete(nil)
                    case .failure(let error):
                        complete(error)
                    }
                }
            
            case .failure( _, let error):
                complete(error)
            }
        })
    }
}
