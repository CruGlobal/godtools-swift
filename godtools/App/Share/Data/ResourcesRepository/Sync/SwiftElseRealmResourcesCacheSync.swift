//
//  SwiftElseRealmResourcesCacheSync.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class SwiftElseRealmResourcesCacheSync: ResourcesCacheSyncInterface {
    
    private let realmDatabase: RealmDatabase
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
    
    init(realmDatabase: RealmDatabase, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository) {
        
        self.realmDatabase = realmDatabase
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
    }
    
    func syncResources(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable, shouldRemoveDataThatNoLongerExists: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
        
        if #available(iOS 17, *), let swiftDatabase = TempSharedSwiftDatabase.shared.swiftDatabase {
            
            return SwiftResourcesCacheSync(
                swiftDatabase: swiftDatabase,
                trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository
            )
            .syncResources(
                resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                shouldRemoveDataThatNoLongerExists: shouldRemoveDataThatNoLongerExists
            )
            .eraseToAnyPublisher()
        }
        else {
            
            return RealmResourcesCacheSync(
                realmDatabase: realmDatabase,
                trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository
            )
            .syncResources(
                resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                shouldRemoveDataThatNoLongerExists: shouldRemoveDataThatNoLongerExists
            )
            .eraseToAnyPublisher()
        }
    }
}
