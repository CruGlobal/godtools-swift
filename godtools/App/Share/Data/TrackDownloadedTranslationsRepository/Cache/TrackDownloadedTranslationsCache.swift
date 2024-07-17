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
    
    private func getDownloadedTranslationsSortedByLatestVersion(resourceId: String, languageId: String) -> [DownloadedTranslationDataModel] {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let resourceIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.resourceId)) == %@", resourceId)
        let languageIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.languageId)) == %@", languageId)
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [resourceIdPredicate, languageIdPredicate])
                
        let latestTranslations: [DownloadedTranslationDataModel] = realm.objects(RealmDownloadedTranslation.self)
            .filter(filterPredicate)
            .sorted(byKeyPath: #keyPath(RealmDownloadedTranslation.version), ascending: false)
            .map({ DownloadedTranslationDataModel(model: $0) })
        
        return latestTranslations
    }
    
    func getLatestDownloadedTranslation(resourceId: String, languageId: String) -> DownloadedTranslationDataModel? {
        
        return getDownloadedTranslationsSortedByLatestVersion(resourceId: resourceId, languageId: languageId).first
    }
    
    func trackTranslationDownloaded(translation: TranslationModel) -> AnyPublisher<[DownloadedTranslationDataModel], Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmDownloadedTranslation] in
        
            let downloadedTranslation: RealmDownloadedTranslation = RealmDownloadedTranslation()
            
            guard let languageId = translation.language?.id, !languageId.isEmpty,
                  let resourceId = translation.resource?.id, !resourceId.isEmpty else {
                
                return []
            }
            
            downloadedTranslation.languageId = languageId
            downloadedTranslation.manifestAndRelatedFilesPersistedToDevice = true
            downloadedTranslation.resourceId = resourceId
            downloadedTranslation.translationId = translation.id
            downloadedTranslation.version = translation.version
            
            let objects: [RealmDownloadedTranslation] = [downloadedTranslation]
            
            return objects
            
        } mapInBackgroundClosure: { (objects: [RealmDownloadedTranslation]) -> [DownloadedTranslationDataModel] in
            return objects.map({DownloadedTranslationDataModel(model: $0)})
        }
        .eraseToAnyPublisher()
    }
}
