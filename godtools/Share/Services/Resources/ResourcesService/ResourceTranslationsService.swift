//
//  ResourceTranslationsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourceTranslationsService {
    
    private let realmDatabase: RealmDatabase
    private let realmResourcesCache: RealmResourcesCache
    private let translationsApi: TranslationsApiType
    private let sha256FileCache: SHA256FilesCache
    private let resourceId: String
    
    private var currentQueue: OperationQueue?
    
    let started: ObservableValue<Bool> = ObservableValue(value: false)
    let progress: ObservableValue<Double> = ObservableValue(value: 0)
    let completed: Signal = Signal()
    
    required init(realmDatabase: RealmDatabase, realmResourcesCache: RealmResourcesCache, translationsApi: TranslationsApiType, sha256FileCache: SHA256FilesCache, resourceId: String) {
        
        self.realmDatabase = realmDatabase
        self.realmResourcesCache = realmResourcesCache
        self.translationsApi = translationsApi
        self.sha256FileCache = sha256FileCache
        self.resourceId = resourceId
    }
    
    func downloadAndCacheTranslations(resource: ResourceModel) {
        
        print("\n DOWNLOAD TRANSLATIONS FOR RESOURCE")
        print("  resourceId: \(resourceId)")
        
        if resource.id != resourceId {
            assertionFailure("ResourceTranslationsService: Incorrect resource.  Expected resource with id: \(resourceId)")
            return
        }
        
        if currentQueue != nil {
            assertionFailure("ResourceTranslationsService:  Download is already running, this process only needs to run once when reloading all resource translations from the server.")
            return
        }
        
        started.accept(value: true)
        
        let queue: OperationQueue = OperationQueue()
        let translationsApiRef: TranslationsApiType = translationsApi
        
        self.currentQueue = queue
        
        var numberOfOperationsCompleted: Double = 0
        var totalOperationCount: Double = 0
        var operations: [RequestOperation] = Array()
        
        // only need to download translation zipfiles that haven't been cached
        filterCachedTranslationZipFilesFromTranslationIds(translationIds: resource.latestTranslationIds) { [weak self] (tranlationIds: [String]) in
            
            for translationId in tranlationIds {
                
                print("\n preparing to download translation id: \(translationId)")
                
                let operation: RequestOperation = translationsApiRef.newTranslationZipDataOperation(translationId: translationId)
                
                operations.append(operation)
                
                operation.completionHandler { [weak self] (response: RequestResponse) in
                    
                    let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
                    
                    switch result {
                    case .success( _, _):
                        
                        if let zipData = response.data {
                            
                            let cacheError = self?.cacheTranslationZipData(
                                translationId: translationId,
                                zipData: zipData
                            )
                            
                            if let cacheError = cacheError {
                                // TODO: Handle cache error. ~Levi
                                print("\n Failed to cache translation zip data: \(cacheError)")
                            }
                        }
                        else {
                            // no data, handle? ~Levi
                        }
                    case .failure(let error):
                        print("\n Failed to download translation zip data: \(error)")
                    }
                    
                    numberOfOperationsCompleted += 1
                    self?.progress.accept(value: numberOfOperationsCompleted / totalOperationCount)
                    
                    if queue.operations.isEmpty {
                        self?.handleDownloadAndCacheAttachmentsCompleted()
                    }
                }
            }
            
            if !operations.isEmpty {
                totalOperationCount = Double(operations.count)
                self?.progress.accept(value: 0)
                queue.addOperations(operations, waitUntilFinished: false)
            }
            else {
                self?.handleDownloadAndCacheAttachmentsCompleted()
            }
        }
    }
    
    private func handleDownloadAndCacheAttachmentsCompleted() {
        currentQueue = nil
        started.accept(value: false)
        progress.accept(value: 0)
        completed.accept()
    }
    
    private func filterCachedTranslationZipFilesFromTranslationIds(translationIds: [String], complete: @escaping ((_ translationIds: [String]) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            var translationIdsThatArentCached: [String] = Array()
            
            for translationId in translationIds {
                
                let isCached: Bool = realm.object(ofType: RealmTranslationZipFile.self, forPrimaryKey: translationId) != nil
                
                if !isCached {
                    translationIdsThatArentCached.append(translationId)
                }
            }
            
            DispatchQueue.main.async {
                complete(translationIdsThatArentCached)
            }
        }
    }
    
    private func cacheTranslationZipData(translationId: String, zipData: Data) -> Error? {
        
        // TODO: Should complete block with error. ~Levi
        
        let result: Result<[SHA256FileLocation], Error> = sha256FileCache.decompressZipFileAndCacheSHA256FileContents(zipData: zipData)
            
        switch result {
        
        case .success(let cachedSHA256FileLocations):
                        
            realmDatabase.background { (realm: Realm) in
                
                guard let translation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
                    // TODO: Translation should always exist, but if not report internal error. ~Levi
                    return
                }
                
                // successfully cached zip file
                
                // add translation references to realm sha256 files
                var realmSHA256Files: [RealmSHA256File] = Array()
                
                for location in cachedSHA256FileLocations {
                    
                    print("    location: \(location.sha256WithPathExtension)")
                    
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
                            // TODO: Handle error? ~Levi
                            assertionFailure(error.localizedDescription)
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
                            // TODO: Handle error? ~Levi
                            assertionFailure(error.localizedDescription)
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
                
                print("  RealmTranslationZipFile")
                print("     realmTranslationZipFile.translationId: \(realmTranslationZipFile.translationId)")
                print("     realmTranslationZipFile.resourceId: \(realmTranslationZipFile.resourceId)")
                print("     realmTranslationZipFile.languageId: \(realmTranslationZipFile.languageId)")
                print("     realmTranslationZipFile.languageCode: \(realmTranslationZipFile.languageCode)")
                print("     realmTranslationZipFile.translationManifestFilename: \(realmTranslationZipFile.translationManifestFilename)")
                print("     realmTranslationZipFile.translationsVersion: \(realmTranslationZipFile.translationsVersion)")
                print("     realmTranslationZipFile.sha256Files.count: \(realmTranslationZipFile.sha256Files.count)")
                
                do {
                    try realm.write {
                        realm.add(realmTranslationZipFile, update: .all)
                    }
                }
                catch let realmCacheError {
                    print("\n Failed to add realm translation zip file to realm: \(realmCacheError)")
                }
            }// end realm background
            
            return nil
            
        case .failure(let cacheError):
            return cacheError
        }
    }
}
