//
//  TranslationsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

class TranslationsFileCache {
        
    private let realmDatabase: RealmDatabase
    private let sha256FileCache: ResourcesSHA256FileCache
    
    required init(realmDatabase: RealmDatabase, sha256FileCache: ResourcesSHA256FileCache) {
        
        self.realmDatabase = realmDatabase
        self.sha256FileCache = sha256FileCache
    }
    
    func getFile(location: SHA256FileLocation) -> Result<URL, Error> {
        return sha256FileCache.getFile(location: location)
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
        
    func getTranslation(translationId: String) -> Result<TranslationManifestData, TranslationsFileCacheError> {
        
        return getTranslations(translationIds: [translationId])[0]
    }
    
    func getTranslations(translationIds: [String]) -> [Result<TranslationManifestData, TranslationsFileCacheError>] {
        
        let realm: Realm = realmDatabase.mainThreadRealm
        
        var results: [Result<TranslationManifestData, TranslationsFileCacheError>] = Array()
        
        for translationId in translationIds {
            
            let translationZipFileModel: TranslationZipFileModel?
            let manifestData: Data?
            let fileCacheError: TranslationsFileCacheError?
            let result: Result<TranslationManifestData, TranslationsFileCacheError>
            
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
            
            if let translationZipFile = translationZipFileModel, let manifestXmlData = manifestData {
                result = .success(TranslationManifestData(translationZipFile: translationZipFile, manifestXmlData: manifestXmlData))
            }
            else if let fileCacheError = fileCacheError {
                result = .failure(fileCacheError)
            }
            else {
                result = .failure(.translationManifestDoesNotExistInFileCache)
            }
            
            results.append(result)
        }
        
        return results
    }
    
    // MARK: - Caching Translation ZipFile Data
    
    func translationZipIsCached(translationId: String) -> Bool {
        return translationZipIsCached(realm: realmDatabase.mainThreadRealm, translationId: translationId)
    }
    
    func translationZipIsCached(realm: Realm, translationId: String) -> Bool {
        if let _ = realm.object(ofType: RealmTranslationZipFile.self, forPrimaryKey: translationId) {
            return true
        }
        
        return false
    }
    
    func cacheTranslationZipData(translationId: String, zipData: Data, complete: @escaping ((_ result: Result<TranslationManifestData, TranslationsFileCacheError>) -> Void)) {
              
        realmDatabase.background { [weak self] (realm: Realm) in
            
            guard let translationsFileCache = self else {
                return
            }
            
            let result: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.cacheTranslationZipData(
                realm: realm,
                translationId: translationId,
                zipData: zipData
            )
            
            complete(result)
        }
    }
    
    func cacheTranslationZipData(realm: Realm, translationId: String, zipData: Data) -> Result<TranslationManifestData, TranslationsFileCacheError> {
        
        let sha256FileCache: SHA256FilesCache = self.sha256FileCache
        
        let result: Result<[SHA256FileLocation], Error> = sha256FileCache.decompressZipFileAndCacheSHA256FileContents(zipData: zipData)
            
        switch result {
        
        case .success(let cachedSHA256FileLocations):
                        
            guard let translation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
                return .failure(.translationDoesNotExistInCache)
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
                return .failure(.cacheError(error: error))
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
                return .failure(.cacheError(error: error))
            }
            
            let translationZipFile = TranslationZipFileModel(realmTranslationZipFile: realmTranslationZipFile)
            let manifestLocation = translationZipFile.manifestSHA256FileLocation
            let getManifestXmlResult: Result<Data?, Error> = sha256FileCache.getData(location: manifestLocation)
            var manifestXmlData: Data?
            
            switch getManifestXmlResult {
            
            case .success(let data):
                manifestXmlData = data
            case .failure(let error):
                return .failure(.getManifestDataError(error: error))
            }
            
            if let manifestXmlData = manifestXmlData {
                return .success(TranslationManifestData(translationZipFile: translationZipFile, manifestXmlData: manifestXmlData))
            }
            else {
                return .failure(.translationManifestDoesNotExistInFileCache)
            }
                        
        case .failure(let error):
            return .failure(.sha256FileCacheError(error: error))
        }
    }
    
    // MARK: - Deleting Translation ZipFiles
    
    func bulkDeleteTranslationZipFiles(realm: Realm, resourceIds: [String], languageIds: [String], translationIds: [String]) -> Error? {
                
        var translationZipFilesToDelete: [RealmTranslationZipFile] = Array()
        
        for resourceId in resourceIds {
            translationZipFilesToDelete.append(contentsOf: Array(realm.objects(RealmTranslationZipFile.self).filter("resourceId = '\(resourceId)'")))
        }
        
        for languageId in languageIds {
            translationZipFilesToDelete.append(contentsOf: Array(realm.objects(RealmTranslationZipFile.self).filter("languageId = '\(languageId)'")))
        }
        
        for translationId in translationIds {
            if let translationZipFile = realm.object(ofType: RealmTranslationZipFile.self, forPrimaryKey: translationId) {
                translationZipFilesToDelete.append(translationZipFile)
            }
        }
                
        guard !translationZipFilesToDelete.isEmpty else {
            return nil
        }
        
        do {
            try realm.write {
                realm.delete(translationZipFilesToDelete)
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
    
    func deleteUnusedTranslationZipFiles(realm: Realm) -> Error? {
        
        var translationZipFilesToDelete: [RealmTranslationZipFile] = Array()
        
        let translationZipFiles: [RealmTranslationZipFile] = Array(realm.objects(RealmTranslationZipFile.self))
        
        for translationZipFile in translationZipFiles {
            
            if realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationZipFile.translationId) == nil {
                translationZipFilesToDelete.append(translationZipFile)
            }
            else if realm.object(ofType: RealmLanguage.self, forPrimaryKey: translationZipFile.languageId) == nil {
                translationZipFilesToDelete.append(translationZipFile)
            }
            else if realm.object(ofType: RealmResource.self, forPrimaryKey: translationZipFile.resourceId) == nil {
                translationZipFilesToDelete.append(translationZipFile)
            }
        }
        
        guard !translationZipFilesToDelete.isEmpty else {
            return nil
        }
                
        do {
            try realm.write {
                realm.delete(translationZipFilesToDelete)
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
}
