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
    
    func getTranslationManifest(translationId: String, completeOnMain: @escaping ((_ result: Result<TranslationManifest, TranslationsFileCacheError>) -> Void)) {
        
        let sha256FileCache: ResourcesSHA256FileCache = self.sha256FileCache
        
        realmDatabase.background { (realm: Realm) in
            
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
            
            DispatchQueue.main.async {
                
                if let translationZipFile = translationZipFileModel, let manifestXml = manifestData {
                    completeOnMain(.success(TranslationManifest(translationZipFile: translationZipFile, manifestXml: manifestXml)))
                }
                else if let fileCacheError = fileCacheError {
                    completeOnMain(.failure(fileCacheError))
                }
                else {
                    completeOnMain(.failure(.translationManifestDoesNotExistInFileCache))
                }
            }
        }
    }
    
    func cacheTranslationZipData(translationId: String, zipData: Data, complete: @escaping ((_ result: Result<TranslationManifest, TranslationsFileCacheError>) -> Void)) {
                
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
                
                for location in cachedSHA256FileLocations {
                                        
                    if let existingRealmSHA256File = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: location.sha256WithPathExtension) {
                        
                        do {
                            try realm.write {
                                if !existingRealmSHA256File.translations.contains(translation) {
                                    existingRealmSHA256File.translations.append(translation)
                                }
                                realmSHA256Files.append(existingRealmSHA256File)
                            }
                        }
                        catch let error {
                            complete(.failure(.cacheError(error: error)))
                            return
                        }
                    }
                    else {
                        let newRealmSHA256File: RealmSHA256File = RealmSHA256File()
                        newRealmSHA256File.sha256WithPathExtension = location.sha256WithPathExtension
                        newRealmSHA256File.translations.append(translation)
                        do {
                            try realm.write {
                                realm.add(newRealmSHA256File, update: .all)
                            }
                            realmSHA256Files.append(newRealmSHA256File)
                        }
                        catch let error {
                            complete(.failure(.cacheError(error: error)))
                            return
                        }
                    }
                } // end add translation references to realm sha256 files
                
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
                    complete(.success(TranslationManifest(translationZipFile: translationZipFile, manifestXml: manifestXmlData)))
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
