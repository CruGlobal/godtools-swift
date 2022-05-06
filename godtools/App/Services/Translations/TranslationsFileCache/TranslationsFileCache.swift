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
    private let resourcesCache: ResourcesCache
    private let sha256FileCache: ResourcesSHA256FileCache
    
    required init(realmDatabase: RealmDatabase, resourcesCache: ResourcesCache, sha256FileCache: ResourcesSHA256FileCache) {
        
        self.realmDatabase = realmDatabase
        self.resourcesCache = resourcesCache
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
    
    // MARK: - Get Translation Manifest By Resource and Language
    
    func getResourceLanguageTranslationManifestOnMainThread(resourceId: String, languageId: String) -> Result<TranslationManifestData, TranslationsFileCacheError> {
        
        return getResourceLanguageTranslationManifest(realm: realmDatabase.mainThreadRealm, resourceId: resourceId, languageId: languageId)
    }
    
    func getResourceLanguageTranslationManifest(resourceId: String, languageId: String, completeOnMain: @escaping ((_ result: Result<TranslationManifestData, TranslationsFileCacheError>) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            let translationManifestResult: Result<TranslationManifestData, TranslationsFileCacheError>
            
            if let result = self?.getResourceLanguageTranslationManifest(realm: realm, resourceId: resourceId, languageId: languageId) {
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
    
    func getResourceLanguageTranslationManifest(realm: Realm, resourceId: String, languageId: String) -> Result<TranslationManifestData, TranslationsFileCacheError> {
        
        let translation: TranslationModel? = resourcesCache.getResourceLanguageTranslation(resourceId: resourceId, languageId: languageId)
        
        return getTranslationManifest(realm: realm, translationId: translation?.id ?? "")
    }
    
    // MARK: - Get Translation Manifest By Translation Id
    
    func getTranslationManifestOnMainThread(translationId: String) -> Result<TranslationManifestData, TranslationsFileCacheError> {
        
        return getTranslationManifest(realm: realmDatabase.mainThreadRealm, translationId: translationId)
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
        
        if let translationZipFile = translationZipFileModel, let manifestXmlData = manifestData {
            return .success(TranslationManifestData(translationZipFile: translationZipFile, manifestXmlData: manifestXmlData))
        }
        else if let fileCacheError = fileCacheError {
            return .failure(fileCacheError)
        }
        else {
            return .failure(.translationManifestDoesNotExistInFileCache)
        }
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
