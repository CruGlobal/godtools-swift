//
//  ResourceTranslationsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourceTranslationsFileCache {
    
    private let realmDatabase: RealmDatabase
    private let sha256FileCache: ResourcesSHA256FileCache
    
    required init(realmDatabase: RealmDatabase, sha256FileCache: ResourcesSHA256FileCache) {
        
        self.realmDatabase = realmDatabase
        self.sha256FileCache = sha256FileCache
    }
    
    func getTranslationZipFile(translationId: String, completeOnMain: @escaping ((_ translationZipFile: TranslationZipFileModel?) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            var translationZipFile: TranslationZipFileModel?
            
            if let realmTranslationZipFile = realm.object(ofType: RealmTranslationZipFile.self, forPrimaryKey: translationId) {
                translationZipFile = TranslationZipFileModel(realmTranslationZipFile: realmTranslationZipFile)
            }
                
            DispatchQueue.main.async {
                completeOnMain(translationZipFile)
            }
        }
    }
    
    func cacheTranslationZipData(translationId: String, zipData: Data, complete: @escaping ((_ error: ResourceTranslationsFileCacheError?) -> Void)) {
                
        let result: Result<[SHA256FileLocation], Error> = sha256FileCache.decompressZipFileAndCacheSHA256FileContents(zipData: zipData)
            
        switch result {
        
        case .success(let cachedSHA256FileLocations):
                        
            realmDatabase.background { (realm: Realm) in
                
                guard let translation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
                    complete(.translationDoesNotExistInCache)
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
                            complete(.cacheError(error: error))
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
                            complete(.cacheError(error: error))
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
                    complete(.cacheError(error: error))
                    return
                }
                
                complete(nil)
            }// end realm background
                        
        case .failure(let error):
            complete(.sha256FileCacheError(error: error))
        }
    }
}
