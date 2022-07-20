//
//  ResourcesSHA256FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift
import SwiftUI
import UIKit

class ResourcesSHA256FileCache {
    
    private static let rootDirectoryName: String = "godtools_resources_files"
    
    private let fileCache: FileCache
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.fileCache = FileCache(rootDirectory: ResourcesSHA256FileCache.rootDirectoryName)
        self.realmDatabase = realmDatabase
    }
    
    func getFileExists(location: FileCacheLocation) -> Result<Bool, Error> {
        return fileCache.getFileExists(location: location)
    }
    
    func getFileExistsPublisher(location: FileCacheLocation) -> AnyPublisher<Bool, Error> {
        return fileCache.getFileExistsPublisher(location: location)
    }
    
    func getFile(location: FileCacheLocation) -> Result<URL, Error> {
        return fileCache.getFile(location: location)
    }
    
    func getData(location: FileCacheLocation) -> Result<Data?, Error> {
        return fileCache.getData(location: location)
    }
    
    func getDataPublisher(location: FileCacheLocation) -> AnyPublisher<Data?, Error> {
        return fileCache.getDataPublisher(location: location)
    }
    
    func getUIImage(location: FileCacheLocation) -> Result<UIImage?, Error> {
        return fileCache.getUIImage(location: location)
    }
    
    func getImage(location: FileCacheLocation) -> Result<Image?, Error> {
        return fileCache.getImage(location: location)
    }
    
    func getTranslationManifest(manifestName: String) -> Result<Data?, Error> {
        
        let location = FileCacheLocation(relativeUrlString: manifestName)
        
        return fileCache.getData(location: location)
    }
    
    func getTranslationManifest(manifestName: String) -> AnyPublisher<Data?, Error> {
        
        let location = FileCacheLocation(relativeUrlString: manifestName)
        
        switch fileCache.getData(location: location) {
        case .success(let data):
            return Just(data).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func getTranslationManifest(translationId: String) -> Data? {
        
        guard let translation = realmDatabase.mainThreadRealm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
            return nil
        }
        
        let location = FileCacheLocation(relativeUrlString: translation.manifestName)
        
        switch fileCache.getData(location: location) {
        case .success(let data):
            return data
        case .failure( _):
            return nil
        }
    }
    
    // MARK: - Translation Files
    
    func storeTranslationFile(translationId: String, fileName: String, fileData: Data) -> AnyPublisher<FileCacheLocation, Error> {
        
        let location = FileCacheLocation(relativeUrlString: fileName)
        
        return Future() { [weak self] promise in
            
            self?.createStoredFileRelationshipsToTranslation(translationId: translationId, fileCacheLocations: [location]) { [weak self] (error: Error?) in
                
                guard let weakSelf = self else {
                    return
                }
                
                if let error = error {
                    
                    promise(.failure(error))
                }
                else {
                                        
                    switch weakSelf.fileCache.storeFile(location: location, data: fileData) {
                    
                    case .success( _):
                        promise(.success(location))
                    
                    case .failure(let fileCacheError):
                        promise(.failure(fileCacheError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func createStoredFileRelationshipsToTranslation(translationId: String, fileCacheLocations: [FileCacheLocation], completion: @escaping ((_ error: Error?) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            guard let realmTranslation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
                
                let error: Error = NSError.errorWithDescription(description: "Failed to create file relationships because a translation object does not exist in realm.")
                
                completion(error)
               
                return
            }
            
            let error: Error?
            
            do {
                
                try realm.write {

                    for location in fileCacheLocations {
                              
                        guard let filenameWithPathExtension = location.filenameWithPathExtension else {
                            continue
                        }
                        
                        if let existingRealmSHA256File = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: filenameWithPathExtension),
                           !existingRealmSHA256File.translations.contains(realmTranslation) {
                            
                            existingRealmSHA256File.translations.append(realmTranslation)
                        }
                        else {
                            
                            let newRealmSHA256File: RealmSHA256File = RealmSHA256File()
                            newRealmSHA256File.sha256WithPathExtension = filenameWithPathExtension
                            newRealmSHA256File.translations.append(realmTranslation)
                            
                            realm.add(newRealmSHA256File, update: .all)
                        }
                    }
                }
                
                error = nil
            }
            catch let writeError {
                
                error = writeError
            }
            
            completion(error)
        }
    }
    
    // MARK: - Deleting Outdated Files
    
    func deleteUnusedSHA256ResourceFiles(realm: Realm) -> [Error] {
        
        // TODO: Implement in GT-1448. ~Levi
        
        assertionFailure("Implement in GT-1448.")
        return []
        
        /*
        var errors: [Error] = Array()
        
        let query: String = "attachments.@count = 0 AND translations.@count = 0"
        let realmSHA256FilesToDelete: [RealmSHA256File] = Array(realm.objects(RealmSHA256File.self).filter(query))
           
        for file in realmSHA256FilesToDelete {
    
            let error: Error? = removeFile(location: file.location)
            
            if let error = error {
                errors.append(error)
            }
        }
        
        guard !realmSHA256FilesToDelete.isEmpty else {
            return errors
        }
        
        do {
            try realm.write {
                realm.delete(realmSHA256FilesToDelete)
            }
        }
        catch let error {
            errors.append(error)
        }
        
        return errors*/
    }
}
