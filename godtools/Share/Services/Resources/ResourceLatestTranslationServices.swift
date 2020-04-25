//
//  ResourceLatestTranslationServices.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceLatestTranslationServices {
        
    private var getTranslationZipDataOperation: OperationQueue?
    
    let translationsApi: TranslationsApiType
    let fileCache: ResourcesLatestTranslationsFileCache
    let godToolsResource: GodToolsResource
    let isFetchingManifestXmlData: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(translationsApi: TranslationsApiType, fileCache: ResourcesLatestTranslationsFileCache, godToolsResource: GodToolsResource) {
        
        self.translationsApi = translationsApi
        self.fileCache = fileCache
        self.godToolsResource = godToolsResource
    }
    
    func getManifestXmlData(forceDownload: Bool, complete: @escaping ((_ xmlData: Data?, _ error: Error?) -> Void)) {
                
        let translationZipContentsCacheLocation = ResourcesLatestTranslationsFileCacheLocation(godToolsResource: godToolsResource)
        let translationManifestFileName: String = godToolsResource.translationManifestFilename
        
        var contentsExist: Bool = false
        switch fileCache.contentsExist(location: translationZipContentsCacheLocation) {
        case .success(let exist):
            contentsExist = exist
        case .failure( _):
            break
        }
        
        var cachedXmlData: Data?
        if contentsExist {
            switch fileCache.getData(location: translationZipContentsCacheLocation, path: translationManifestFileName) {
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
            
            isFetchingManifestXmlData.accept(value: true)
            
            getTranslationZipDataOperation = translationsApi.getTranslationZipData(translationId: godToolsResource.translationId) { [weak self] (response: RequestResponse, result: RequestResult<Data, NoRequestResultType>) in
                
                switch result {
                
                case .success(let optionalZipData):
                   
                    var manifestXmlData: Data?
                    var cacheError: Error?
                    
                    if let zipData = optionalZipData, let fileCache = self?.fileCache {
                        
                        switch fileCache.cacheContents(location: translationZipContentsCacheLocation, zipData: zipData) {
                        case .success( _):
                            // successfully cached contents from zip file
                            break
                        case .failure(let error):
                            cacheError = error
                        }
                        
                        switch fileCache.getData(location: translationZipContentsCacheLocation, path: translationManifestFileName) {
                        case .success(let data):
                            manifestXmlData = data
                        case .failure(let error):
                            cacheError = error
                        }
                    }
                    
                    self?.isFetchingManifestXmlData.accept(value: false)
                    complete(manifestXmlData, cacheError)
                    
                case .failure( _, let error):
                    self?.isFetchingManifestXmlData.accept(value: false)
                    complete(nil, error)
                }
            }
        }
    }
    
    func cancelOperations() {
        getTranslationZipDataOperation?.cancelAllOperations()
    }
}
