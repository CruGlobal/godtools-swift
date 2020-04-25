//
//  GetResourceLatestTranslationServices.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class GetResourceLatestTranslationServices {
    
    private let translationsApi: TranslationsApiType
    
    private var getTranslationZipDataOperation: OperationQueue?
    
    let cache: ResourcesLatestTranslationsZipFileCache
    let isFetchingManifestXmlData: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(translationsApi: TranslationsApiType, cache: ResourcesLatestTranslationsZipFileCache) {
        
        self.translationsApi = translationsApi
        self.cache = cache
    }
    
    func getManifestXmlData(resource: DownloadedResource, language: Language, translation: Translation, forceDownload: Bool, complete: @escaping ((_ xmlData: Data?, _ error: Error?) -> Void)) {
        
        guard let manifestFilename = translation.manifestFilename else {
            
            let error = NSError(
                domain: String(describing: GetResourceLatestTranslationServices.self),
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Error fetching manifest xml data for resource.  Either the translation does not exist for the provided language or the translation does not provide a manifestFilename.\n  resource.remoteId: \(resource.remoteId)\n  language.code: \(language.code)\n  manifestFilename: \(translation.manifestFilename ?? "")"]
            )
            
            complete(nil, error)
            return
        }
        
        let translationZipContentsCacheLocation = ResourcesLatestTranslationsZipFileCacheLocation(resource: resource, language: language)
                
        var contentsExist: Bool = false
        switch cache.contentsExist(location: translationZipContentsCacheLocation) {
        case .success(let exist):
            contentsExist = exist
        case .failure( _):
            break
        }
        
        var cachedXmlData: Data?
        if contentsExist {
            switch cache.getManifestXmlData(location: translationZipContentsCacheLocation, manifestFileName: manifestFilename) {
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
            
            getTranslationZipDataOperation = translationsApi.getTranslationZipData(translationId: translation.remoteId) { [weak self] (response: RequestResponse, result: RequestResult<Data, NoRequestResultType>) in
                
                switch result {
                
                case .success(let optionalZipData):
                   
                    var manifestXmlData: Data?
                    var cacheError: Error?
                    
                    if let zipData = optionalZipData, let cache = self?.cache {
                        
                        switch cache.cacheContents(location: translationZipContentsCacheLocation, zipData: zipData) {
                        case .success( _):
                            // successfully cached contents from zip file
                            break
                        case .failure(let error):
                            cacheError = error
                        }
                        
                        switch cache.getManifestXmlData(location: translationZipContentsCacheLocation, manifestFileName: manifestFilename) {
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
    
    func cancelGetManifestXmlData() {
        getTranslationZipDataOperation?.cancelAllOperations()
    }
}
