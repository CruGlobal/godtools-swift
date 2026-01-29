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
import RepositorySync

class TrackDownloadedTranslationsCache {
    
    private let persistence: any Persistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel>
        
    init(persistence: any Persistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel>) {
        
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, SwiftDownloadedTranslation>? {
        return persistence as? SwiftRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, SwiftDownloadedTranslation>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, RealmDownloadedTranslation>? {
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
    private func getSwiftLatestDownloadedTranslations(resourceId: String, languageId: String) -> [SwiftDownloadedTranslation]? {
        
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
        
        return database
            .read
            .objectsNonThrowing(context: database.openContext(), query: query)
    }
    
    private func getRealmLatestDownloadedTranslations(resourceId: String, languageId: String) -> [RealmDownloadedTranslation]? {
        
        guard let realmPersistence = getRealmPersistence(), let realm = realmPersistence.database.openRealmNonThrowing() else {
            return nil
        }
        
        let database: RealmDatabase = realmPersistence.database
        
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
    
    func getLatestDownloadedTranslationsPublisher(resourceId: String, languageId: String) -> AnyPublisher<[DownloadedTranslationDataModel], Error> {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftDownloadedTranslation> { downloadedTranslation in
                downloadedTranslation.resourceId == resourceId && downloadedTranslation.languageId == languageId
            }
            
            let query = SwiftDatabaseQuery(
                filter: filter,
                sortBy: getSortByLatestVersionDescriptor()
            )
            
            return swiftPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
                .eraseToAnyPublisher()
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let resourceIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.resourceId)) == %@", resourceId)
            let languageIdPredicate = NSPredicate(format: "\(#keyPath(RealmDownloadedTranslation.languageId)) == %@", languageId)
            let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [resourceIdPredicate, languageIdPredicate])
                    
            let query = RealmDatabaseQuery(
                filter: filterPredicate,
                sortByKeyPath: getSortByLatestVersionKeyPath()
            )
            
            return realmPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
                .eraseToAnyPublisher()
        }
        else {
            
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func getLatestDownloadedTranslation(resourceId: String, languageId: String) -> DownloadedTranslationDataModel? {
        
        if #available(iOS 17.4, *), let latestTranslation = getSwiftLatestDownloadedTranslations(resourceId: resourceId, languageId: languageId)?.first {
            return DownloadedTranslationDataModel(interface: latestTranslation)
        }
        else if let latestTranslation = getRealmLatestDownloadedTranslations(resourceId: resourceId, languageId: languageId)?.first {
            return DownloadedTranslationDataModel(interface: latestTranslation)
        }
        
        return nil
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
            
            return swiftPersistence
                .writeObjectsPublisher(externalObjects: [downloadedTranslation], writeOption: nil, getOption: nil)
                .map { _ in
                    return [downloadedTranslation]
                }
                .eraseToAnyPublisher()
        }
        else if let realmPersistence = getRealmPersistence() {
            
            return realmPersistence
                .writeObjectsPublisher(externalObjects: [downloadedTranslation], writeOption: nil, getOption: nil)
                .map { _ in
                    return [downloadedTranslation]
                }
                .eraseToAnyPublisher()
        }
        else {
            
            return Just([downloadedTranslation])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

