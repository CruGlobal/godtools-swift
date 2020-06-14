//
//  ResourcesSHA256FilesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesSHA256FilesCache {
    
    private let fileManager: FileManager = FileManager.default
    private let rootDirectory: String = "resources_files"
    private let mainThreadRealm: Realm
    private let errorDomain: String
    
    required init(realmDatabase: RealmDatabase) {
        
        mainThreadRealm = realmDatabase.mainThreadRealm
        errorDomain = "\(type(of: self))"
        
        switch createRootDirectoryIfNotExists() {
        case .success( _):
            break
        case .failure(let error):
            assertionFailure("\(errorDomain): Failed to create root directory: \(rootDirectory) with error: \(error)")
        }
    }
    
    private func getUserDocumentsDirectory() -> Result<URL, Error> {
        
        do {
            let documentsDirectory: URL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            return .success(documentsDirectory)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    private func getRootDirectory() -> Result<URL, Error> {
    
        switch getUserDocumentsDirectory() {
        case .success(let documentsDirectory):
            return .success(documentsDirectory.appendingPathComponent(rootDirectory))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createRootDirectoryIfNotExists() -> Result<URL, Error> {
        
        switch getRootDirectory() {
        
        case .success(let directoryUrl):
            
            if !fileManager.fileExists(atPath: directoryUrl.path) {
                
                do {
                    try fileManager.createDirectory(
                        at: directoryUrl,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    return .success(directoryUrl)
                }
                catch let error {
                    return .failure(error)
                }
            }
            else {
                return .success(directoryUrl)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getFile(location: ResourceSHA256FileLocation) -> Result<URL, Error> {
        
        guard let fileUrl = location.fileUrl else {
            return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "File url can't be null."]))
        }
        
        switch getRootDirectory() {
        case .success(let rootDirectory):
            return .success(rootDirectory.appendingPathComponent(fileUrl.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fileExists(location: ResourceSHA256FileLocation) -> Result<Bool, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.fileExists(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getData(location: ResourceSHA256FileLocation) -> Result<Data?, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.contents(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getImage(location: ResourceSHA256FileLocation) -> Result<UIImage?, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            if let data = fileManager.contents(atPath: url.path) {
                return .success(UIImage(data: data))
            }
            return .success(nil)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getImage(attachmentId: String) -> Result<UIImage?, Error> {
        if let attachment = mainThreadRealm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId) {
            return getImage(sha256: attachment.sha256)
        }
        return .success(nil)
    }
    
    func getImage(sha256: String) -> Result<UIImage?, Error> {
        if let realmResourceFile = mainThreadRealm.object(ofType: RealmResourceSHA256File.self, forPrimaryKey: sha256) {
            return getImage(location: realmResourceFile.location)
        }
        return .success(nil)
    }
    
    func cache(reference: Object, location: ResourceSHA256FileLocation, data: Data) -> Error? {
        
        switch fileExists(location: location) {
            
        case .success(let fileExists):
            
            if fileExists {
                return addFileObjectReference(reference: reference, location: location)
            }
            else {
                switch getFile(location: location) {
                case .success(let url):
                    if fileManager.createFile(atPath: url.path, contents: data, attributes: nil) {
                        return addFileObjectReference(reference: reference, location: location)
                    }
                    else {
                        return NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create file at url: \(url.absoluteString)"])
                    }
                case.failure(let error):
                    return error
                }
            }
            
        case .failure(let error):
            return error
        }
    }
    
    private func addFileObjectReference(reference: Object, location: ResourceSHA256FileLocation) -> Error? {
        
        let realmResourceFile: RealmResourceSHA256File
        
        if let existingRealmFile = mainThreadRealm.object(ofType: RealmResourceSHA256File.self, forPrimaryKey: location.sha256) {
            realmResourceFile = existingRealmFile
        }
        else {
            realmResourceFile = RealmResourceSHA256File()
            realmResourceFile.sha256 = location.sha256
            realmResourceFile.pathExtension = location.pathExtension
        }
        
        do {
            try mainThreadRealm.write {
                
                if let attachment = reference as? RealmAttachment {
                    realmResourceFile.attachments.append(attachment)
                }
                else if let translation = reference as? RealmTranslation {
                    realmResourceFile.translations.append(translation)
                }
                else {
                    assertionFailure("ResourcesSHA256FilesCache does not support RealmObject \(type(of: reference)) as RealmResourceSHA256File reference.")
                }
                
                mainThreadRealm.add(realmResourceFile)
            }
            return nil
        }
        catch let error {
            return error
        }
    }
}
