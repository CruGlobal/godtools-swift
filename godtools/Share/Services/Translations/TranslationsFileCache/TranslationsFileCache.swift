//
//  TranslationsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class TranslationsFileCache {
    
    private let realmDatabase: RealmDatabase
    private let sha256FileCache: ResourcesSHA256FileCache
    
    required init(realmDatabase: RealmDatabase, sha256FileCache: ResourcesSHA256FileCache) {
        
        self.realmDatabase = realmDatabase
        self.sha256FileCache = sha256FileCache
    }
    
    func getImage(location: SHA256FileLocation) -> UIImage? {
        
        switch sha256FileCache.getImage(location: location) {
        case .success(let image):
            return image
        case .failure( _):
            return nil
        }
    }
    
    func getData(location: SHA256FileLocation) -> Result<Data?, Error> {
        return sha256FileCache.getData(location: location)
    }
    
    func getResourceLanguageTranslationManifest(resourceId: String, languageId: String, completeOnMain: @escaping ((_ result: Result<TranslationManifestData, TranslationsFileCacheError>) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let realmResource: RealmResource? = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId)
            let realmTranslation: RealmTranslation? = realmResource?.latestTranslations.filter("language.id = '\(languageId)'").first
            let translationManifestResult: Result<TranslationManifestData, TranslationsFileCacheError>
            
            if let result = self?.getTranslationManifest(realm: realm, translationId: realmTranslation?.id ?? "") {
                translationManifestResult = result
            }
            else {
                translationManifestResult = .failure(.translationDoesNotExistInCache)
            }
            
            DispatchQueue.main.async {
                completeOnMain(translationManifestResult)
            }
        }
    }
    
    func getTranslationManifest(translationId: String, completeOnMain: @escaping ((_ result: Result<TranslationManifestData, TranslationsFileCacheError>) -> Void)) {
                
        realmDatabase.background { [weak self] (realm: Realm) in
            
            guard let translationsFileCache = self else {
                return
            }
            
            let result: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifest(
                realm: realm,
                translationId: translationId
            )
            
            DispatchQueue.main.async {
                completeOnMain(result)
            }
        }
    }
    
    func getTranslationManifest(realm: Realm, translationId: String) -> Result<TranslationManifestData, TranslationsFileCacheError> {
                
        let translationZipFileModel: TranslationZipFileModel?
        let manifestData: Data?
        let fileCacheError: TranslationsFileCacheError?
        
        if let realmTranslationZipFile = realm.object(ofType: RealmTranslationZipFile.self, forPrimaryKey: translationId) {
            
            let translationZipFile = TranslationZipFileModel(realmTranslationZipFile: realmTranslationZipFile)
            let location: SHA256FileLocation = translationZipFile.manifestSHA256FileLocation
            
            translationZipFileModel = translationZipFile
            
            let result: Result<Data?, Error> = sha256FileCache.getData(location: location)
            
            switch result {
            case .success(let data):
                manifestData = data
                fileCacheError = nil
            case .failure(let getDataError):
                manifestData = nil
                fileCacheError = .getManifestDataError(error: getDataError)
            }
        }
        else {
            translationZipFileModel = nil
            manifestData = nil
            fileCacheError = nil
        }
        
        if let translationZipFile = translationZipFileModel, let manifestXml = manifestData {
            return .success(TranslationManifestData(translationZipFile: translationZipFile, manifestXml: manifestXml))
        }
        else if let fileCacheError = fileCacheError {
            return .failure(fileCacheError)
        }
        else {
            return .failure(.translationManifestDoesNotExistInFileCache)
        }
    }
    
    func cacheTranslationZipData(translationId: String, zipData: Data, complete: @escaping ((_ result: Result<TranslationManifestData, TranslationsFileCacheError>) -> Void)) {
                
        let sha256FileCache: SHA256FilesCache = self.sha256FileCache
        
        let result: Result<[SHA256FileLocation], Error> = sha256FileCache.decompressZipFileAndCacheSHA256FileContents(zipData: zipData)
            
        switch result {
        
        case .success(let cachedSHA256FileLocations):
                        
            realmDatabase.background { (realm: Realm) in
                
                guard let translation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
                    complete(.failure(.translationDoesNotExistInCache))
                    return
                }
                                
                // add translation references to realm sha256 files
                var realmSHA256Files: [RealmSHA256File] = Array()
                
                do {
                    try realm.write {

                        for location in cachedSHA256FileLocations {
                                                
                            if let existingRealmSHA256File = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: location.sha256WithPathExtension) {
                                
                                if !existingRealmSHA256File.translations.contains(translation) {
                                    existingRealmSHA256File.translations.append(translation)
                                }
                                realmSHA256Files.append(existingRealmSHA256File)
                            }
                            else {
                                let newRealmSHA256File: RealmSHA256File = RealmSHA256File()
                                newRealmSHA256File.sha256WithPathExtension = location.sha256WithPathExtension
                                newRealmSHA256File.translations.append(translation)
                                realm.add(newRealmSHA256File, update: .all)
                                realmSHA256Files.append(newRealmSHA256File)
                            }
                        } // end add translation references to realm sha256 files
                    }// end write
                }
                catch let error {
                    complete(.failure(.cacheError(error: error)))
                    return
                }
                
                // add realmTranslationZipFile to realm to track cached translation.zip files
                let realmTranslationZipFile = RealmTranslationZipFile()
                realmTranslationZipFile.translationId = translationId
                realmTranslationZipFile.resourceId = translation.resource?.id ?? ""
                realmTranslationZipFile.languageId = translation.language?.id ?? ""
                realmTranslationZipFile.languageCode = translation.language?.code ?? ""
                realmTranslationZipFile.translationManifestFilename = translation.manifestName
                realmTranslationZipFile.translationsVersion = translation.version
                realmTranslationZipFile.sha256Files.append(objectsIn: realmSHA256Files)
                                
                do {
                    try realm.write {
                        realm.add(realmTranslationZipFile, update: .all)
                    }
                }
                catch let error {
                    complete(.failure(.cacheError(error: error)))
                    return
                }
                
                let translationZipFile = TranslationZipFileModel(realmTranslationZipFile: realmTranslationZipFile)
                let manifestLocation = translationZipFile.manifestSHA256FileLocation
                let getManifestXmlResult: Result<Data?, Error> = sha256FileCache.getData(location: manifestLocation)
                var manifestXmlData: Data?
                
                switch getManifestXmlResult {
                
                case .success(let data):
                    manifestXmlData = data
                case .failure(let error):
                    complete(.failure(.getManifestDataError(error: error)))
                    return
                }
                
                if let manifestXmlData = manifestXmlData {
                    complete(.success(TranslationManifestData(translationZipFile: translationZipFile, manifestXml: manifestXmlData)))
                }
                else {
                    complete(.failure(.translationManifestDoesNotExistInFileCache))
                    return
                }
                
            }// end realm background
                        
        case .failure(let error):
            complete(.failure(.sha256FileCacheError(error: error)))
        }
    }
}
