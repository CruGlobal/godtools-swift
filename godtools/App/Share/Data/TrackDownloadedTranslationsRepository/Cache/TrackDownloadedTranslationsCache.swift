//
//  TrackDownloadedTranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class TrackDownloadedTranslationsCache {
    
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getDownloadedTranslation(translationId: String) -> DownloadedTranslationDataModel? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmDownloadedTranslation = realm.object(ofType: RealmDownloadedTranslation.self, forPrimaryKey: translationId) else {
            
            return nil
        }
        
        return DownloadedTranslationDataModel(model: realmDownloadedTranslation)
    }
    
    func trackTranslationDownloaded(translationId: String) -> AnyPublisher<String, Error> {
        
        return Future() { promise in
                
            return self.realmDatabase.background { (realm: Realm) in
                
                let downloadedTranslation: RealmDownloadedTranslation = RealmDownloadedTranslation()
                
                downloadedTranslation.translationId = translationId
                downloadedTranslation.manifestAndRelatedFilesPersistedToDevice = true
                
                do {
                    
                    try realm.write {
                        realm.add(downloadedTranslation, update: .all)
                    }
                                        
                    promise(.success(translationId))
                }
                catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
