//
//  RealmToolLanguageDownloaderCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmToolLanguageDownloaderCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getToolLanguageDownloadElseNew(languageId: String) -> RealmToolLanguageDownload {
               
        let existingObject: RealmToolLanguageDownload? = realmDatabase.readObject(primaryKey: languageId)
        
        if let existingObject = existingObject {
            
            return existingObject
        }
        else {
            
            let dataModel = ToolLanguageDownload(
                languageId: languageId,
                downloadErrorDescription: nil,
                downloadErrorHttpStatusCode: nil,
                downloadProgress: 0,
                downloadStartedAt: Date()
            )
            
            let newObject: RealmToolLanguageDownload = RealmToolLanguageDownload()
            newObject.mapFrom(dataModel: dataModel)
            
            storeToolLanguageDownload(realmObject: newObject)
            
            return newObject
        }
    }
    
    func updateDownloadProgressPublisher(languageId: String, downloadProgress: Double) -> AnyPublisher<[ToolLanguageDownload], Error> {
        
        return realmDatabase.writeObjectsPublisher(updatePolicy: .modified, writeClosure: { (realm: Realm) in
            
            var realmObjects: [RealmToolLanguageDownload] = Array()
            
            if let object = realm.object(ofType: RealmToolLanguageDownload.self, forPrimaryKey: languageId) {
                object.downloadProgress = downloadProgress
                realmObjects = [object]
            }
            
            return realmObjects
        },
        mapInBackgroundClosure: { (realmObjects: [RealmToolLanguageDownload]) in
            
            let downloads: [ToolLanguageDownload] = realmObjects.map {
                ToolLanguageDownload(realmToolLanguageDownload: $0)
            }
            
            return downloads
        })
        .eraseToAnyPublisher()
    }
    
    func storeToolLanguageDownload(dataModel: ToolLanguageDownload) {
        
        let realmObject = RealmToolLanguageDownload()
        
        realmObject.mapFrom(dataModel: dataModel)
        
        storeToolLanguageDownload(realmObject: realmObject)
    }
    
    private func storeToolLanguageDownload(realmObject: RealmToolLanguageDownload) {
        
        _ = realmDatabase.writeObjects(realm: realmDatabase.openRealm(), updatePolicy: .modified) { (realm: Realm) in
            let objects: [RealmToolLanguageDownload] = [realmObject]
            return objects
        }
    }
}
