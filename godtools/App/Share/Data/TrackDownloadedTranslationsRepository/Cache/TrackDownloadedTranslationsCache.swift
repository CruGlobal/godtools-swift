//
//  TrackDownloadedTranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class TrackDownloadedTranslationsCache {
    
    private let persistence: any Persistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel>
        
    init(persistence: any Persistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel>) {
        
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, SwiftDownloadedTranslation>? {
        return persistence as? SwiftRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, SwiftDownloadedTranslation>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, RealmDownloadedTranslation>? {
        return persistence as? RealmRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, RealmDownloadedTranslation>
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
    
    @available(iOS 17.4, *)
    private func getSwiftLatestDownloadedTranslations(resourceId: String, languageId: String) throws -> [SwiftDownloadedTranslation]? {
        
        guard let swiftPersistence = getSwiftPersistence() else {
            return nil
        }
        
        let database: SwiftDatabase = swiftPersistence.database
        
        let filter = #Predicate<SwiftDownloadedTranslation> { downloadedTranslation in
            downloadedTranslation.resourceId == resourceId && downloadedTranslation.languageId == languageId
        }
        
        let query = SwiftDatabaseQuery(
            filter: filter,
            sortBy: getSortByLatestVersionDescriptor()
        )
        
        return try database
            .read
            .objects(context: database.openContext(), query: query)
    }
    
    private func getRealmLatestDownloadedTranslations(resourceId: String, languageId: String) throws -> [RealmDownloadedTranslation]? {
        
        guard let database = realmDatabase else {
            return nil
        }
        
        let realm = try database.openRealm()
        
        let resourceIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.resourceId)) == %@", resourceId)
        let languageIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.languageId)) == %@", languageId)
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [resourceIdPredicate, languageIdPredicate])
                
        let query = RealmDatabaseQuery(
            filter: filterPredicate,
            sortByKeyPath: getSortByLatestVersionKeyPath()
        )
        
        return database
            .read
            .objects(realm: realm, query: query)
    }
    
    func getLatestDownloadedTranslationsPublisher(resourceId: String, languageId: String) async throws -> [DownloadedTranslationDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftDownloadedTranslation> { downloadedTranslation in
                downloadedTranslation.resourceId == resourceId && downloadedTranslation.languageId == languageId
            }
            
            let query = SwiftDatabaseQuery(
                filter: filter,
                sortBy: getSortByLatestVersionDescriptor()
            )
            
            return try await swiftPersistence
                .getDataModelsAsync(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let resourceIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.resourceId)) == %@", resourceId)
            let languageIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.languageId)) == %@", languageId)
            let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [resourceIdPredicate, languageIdPredicate])
                    
            let query = RealmDatabaseQuery(
                filter: filterPredicate,
                sortByKeyPath: getSortByLatestVersionKeyPath()
            )
            
            return try await realmPersistence
                .getDataModelsAsync(getOption: .allObjects, query: query)
        }
        
        return Array()
    }
    
    func getLatestDownloadedTranslation(resourceId: String, languageId: String) throws -> DownloadedTranslationDataModel? {
        
        if #available(iOS 17.4, *), let latestTranslation = try getSwiftLatestDownloadedTranslations(resourceId: resourceId, languageId: languageId)?.first {
            return latestTranslation.toModel()
        }
        else if let latestTranslation = try getRealmLatestDownloadedTranslations(resourceId: resourceId, languageId: languageId)?.first {
            return latestTranslation.toModel()
        }
        
        return nil
    }
}

// MARK: - Track Downloads

extension TrackDownloadedTranslationsCache {
    
    func trackTranslationDownloaded(translation: TranslationDataModel) async throws -> [DownloadedTranslationDataModel] {
        
        guard let resourceId = translation.resourceDataModel?.id, let languageId = translation.languageDataModel?.id else {
            throw NSError.errorWithDescription(description: "Failed to get resourceId and languageId for tracked downloaded translation.")
        }
        
        let downloadedTranslation = DownloadedTranslationDataModel(
            id: translation.id,
            languageId: languageId,
            manifestAndRelatedFilesPersistedToDevice: true,
            resourceId: resourceId,
            translationId: translation.id,
            version: translation.version
        )
        
        _ = try await persistence.writeObjectsAsync(
            externalObjects: [downloadedTranslation],
            writeOption: nil,
            getOption: nil
        )
        
        return [downloadedTranslation]
    }
}

