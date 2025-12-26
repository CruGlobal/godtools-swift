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
import SwiftData

class TrackDownloadedTranslationsCache: SwiftElseRealmPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, RealmDownloadedTranslation> {
    
    private let realmDatabase: LegacyRealmDatabase
        
    init(realmDatabase: LegacyRealmDatabase, swiftPersistenceIsEnabled: Bool? = nil) {
        
        self.realmDatabase = realmDatabase
        
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmDownloadedTranslationDataModelMapping(),
            swiftPersistenceIsEnabled: swiftPersistenceIsEnabled
        )
    }
    
    @available(iOS 17.4, *)
    override func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any RepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel>)? {
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, SwiftDownloadedTranslation>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence(swiftDatabase: SwiftDatabase) -> SwiftRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, SwiftDownloadedTranslation>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: swiftDatabase,
            dataModelMapping: SwiftDownloadedTranslationDataModelMapping()
        )
    }
}

// MARK: - Sort Descriptors

extension TrackDownloadedTranslationsCache {
    
    @available(iOS 17.4, *)
    private func getSortByLatestVersionDescriptor() -> [Foundation.SortDescriptor<SwiftDownloadedTranslation>] {
        return [SortDescriptor(\SwiftDownloadedTranslation.version, order: .reverse)]
    }
    
    private func getSortByLatestVersionKeyPath() -> SortByKeyPath {
        return SortByKeyPath(
            keyPath: #keyPath(RealmDownloadedTranslation.version),
            ascending: false
        )
    }
}

// MARK: - Query

extension TrackDownloadedTranslationsCache {
    
    func getLatestDownloadedTranslations(resourceId: String, languageId: String) -> [DownloadedTranslationDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftDownloadedTranslation> { downloadedTranslation in
                downloadedTranslation.resourceId == resourceId && downloadedTranslation.languageId == languageId
            }
            
            let query = SwiftDatabaseQuery(
                filter: filter,
                sortBy: getSortByLatestVersionDescriptor()
            )
            
            return swiftPersistence
                .getObjects(query: query)
        }
        else {
            
            let resourceIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.resourceId)) == %@", resourceId)
            let languageIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.languageId)) == %@", languageId)
            let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [resourceIdPredicate, languageIdPredicate])
                    
            let query = RealmDatabaseQuery(
                filter: filterPredicate,
                sortByKeyPath: getSortByLatestVersionKeyPath()
            )
            
            return super.getRealmPersistence()
                .getObjects(query: query)
        }
    }
    
    func getLatestDownloadedTranslation(resourceId: String, languageId: String) -> DownloadedTranslationDataModel? {
        
        return getLatestDownloadedTranslations(resourceId: resourceId, languageId: languageId).first
    }
}

// MARK: - Track Downloads

extension TrackDownloadedTranslationsCache {
    
    func trackTranslationDownloaded(translation: TranslationDataModel) -> AnyPublisher<[DownloadedTranslationDataModel], Error> {
        
        guard let resourceId = translation.resourceDataModel?.id, let languageId = translation.languageDataModel?.id else {
            let error: Error = NSError.errorWithDescription(description: "Failed to get resourceId and languageId for tracked downloaded translation.")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let downloadedTranslation = DownloadedTranslationDataModel(
            id: translation.id,
            languageId: languageId,
            manifestAndRelatedFilesPersistedToDevice: true,
            resourceId: resourceId,
            translationId: translation.id,
            version: translation.version
        )
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            _ = swiftPersistence
                .writeObjects(externalObjects: [downloadedTranslation])
        }
        else {
            
            _ = super.getRealmPersistence()
                .writeObjects(externalObjects: [downloadedTranslation], deleteObjectsNotFoundInExternalObjects: false)
        }
        
        return Just([downloadedTranslation])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
