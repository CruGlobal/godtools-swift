//
//  RealmToolLanguageDownloaderCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmToolLanguageDownloaderCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func updateDownloadProgress(languageId: String, downloadProgress: Double) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let object = realmDatabase.readObject(realm: realm, primaryKey: languageId) as? RealmToolLanguageDownload else {
            return
        }
        
        _ = realmDatabase.writeObjects(realm: realm, updatePolicy: .modified, writeClosure: { realm in
            
            object.downloadProgress = NSNumber(value: downloadProgress)
            
            return [object]
        })
    }
    
    func storeToolLanguageDownload(dataModel: ToolLanguageDownload) {
        
        let realmObject = RealmToolLanguageDownload()
        
        realmObject.mapFrom(dataModel: dataModel)
        
        _ = realmDatabase.writeObjects(realm: realmDatabase.openRealm(), updatePolicy: .modified) { (realm: Realm) in
            let objects: [RealmToolLanguageDownload] = [realmObject]
            return objects
        }
    }
}
