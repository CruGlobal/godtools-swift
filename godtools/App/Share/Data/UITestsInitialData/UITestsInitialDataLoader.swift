//
//  UITestsInitialDataLoader.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift

final class UITestsInitialDataLoader {
    
    private let realmDatabase: RealmDatabase
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    init(realmDatabase: RealmDatabase, resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.realmDatabase = realmDatabase
        self.resourcesFileCache = resourcesFileCache
    }
    
    func loadData() {
        
        do {
            let realm: Realm = try realmDatabase.openRealm()
            
            addInitialRealmObjects(realm: realm)
            
            loadTranslationManifests()
        }
        catch let error {
            assertionFailure("\n UITestsRealmDatabase: Failed to get realm with error.\n  error: \(error)")
        }
    }
}

// MARK: - Realm

extension UITestsInitialDataLoader {
        
    private func addInitialRealmObjects(realm: Realm) {
        
        let objects: [Object] = UITestsRealmObjects.getAllObjects()
        
        do {
            try realm.write {
                realm.add(objects, update: .all)
            }
        }
        catch let error {
            assertionFailure("\n UITestsInitialDataLoader: Failed to add realm objects with error.\n  error: \(error)")
        }
    }
}

// MARK: - Load Translation Manifests

extension UITestsInitialDataLoader {
    
    private func loadTranslationManifests() {
                
        if let tmtsManifestData = PreviewAssets.tmtsManifest.data, let tmtsTractData = PreviewAssets.tmtsTract.data {
            
            do {
                
                _ = try resourcesFileCache.storeTranslationFile(
                    translationId: UITestsRealmObjects.tmtsEnTranslation,
                    fileName: UITestsRealmObjects.tmtsManifest,
                    fileData: tmtsManifestData
                )
                
                _ =  try resourcesFileCache.storeTranslationZipFile(
                    translationId: UITestsRealmObjects.tmtsEnTranslation,
                    zipFileData: tmtsTractData
                )
            }
            catch let error {
                
                assertionFailure("\n UITestsRealmDatabase: Failed to get manifest with error.\n  error: \(error)")
            }
        }
    }
}
