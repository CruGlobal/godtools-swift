//
//  DownloadedLanguagesCache.swift
//  godtools
//
//  Created by Rachael Skeath on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class DownloadedLanguagesCache {
    
    let persistence: any Persistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel>
    
    init(persistence: any Persistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, SwiftDownloadedLanguage>? {
        return persistence as? SwiftRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, SwiftDownloadedLanguage>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, RealmDownloadedLanguage>? {
        return persistence as? RealmRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, RealmDownloadedLanguage>
    }
}

// MARK: - Predicates

extension DownloadedLanguagesCache {
    
    @available(iOS 17.4, *)
    private func getDownloadCompletePredicate(downloadComplete: Bool) -> Predicate<SwiftDownloadedLanguage> {
     
        let filter = #Predicate<SwiftDownloadedLanguage> { object in
            object.downloadComplete == downloadComplete
        }
        
        return filter
    }
    
    private func getDownloadCompleteNSPredicate(downloadComplete: Bool) -> NSPredicate {
        
        return NSPredicate(format: "\(#keyPath(RealmDownloadedLanguage.downloadComplete)) == %@", NSNumber(value: downloadComplete))
    }
}

extension DownloadedLanguagesCache {
    
    func getDownloadedLanguagesByDownloadComplete(downloadComplete: Bool) async throws -> [DownloadedLanguageDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = SwiftDatabaseQuery<SwiftDownloadedLanguage>.filter(
                filter: getDownloadCompletePredicate(downloadComplete: downloadComplete)
            )
            
            return try await swiftPersistence.getDataModelsAsync(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = RealmDatabaseQuery.filter(
                filter: getDownloadCompleteNSPredicate(downloadComplete: downloadComplete)
            )
            
            return try await realmPersistence.getDataModelsAsync(getOption: .allObjects, query: query)
        }
        
        return Array()
    }
    
    func deleteDownloadedLanguage(languageId: String) throws {
            
        if #available(iOS 17.4, *), let database = swiftDatabase {
            
            let context: ModelContext = database.openContext()
            
            let objectToDelete: SwiftDownloadedLanguage? = try database.read.object(context: context, id: languageId)
            
            if let objectToDelete = objectToDelete {
                
                try database.write.context(
                    context: context,
                    writeObjects: WriteSwiftObjects(
                        deleteObjects: [objectToDelete],
                        insertObjects: nil
                    )
                )
            }
        }
        else if let realmDatabase = realmDatabase {
            
            let realm: Realm = try realmDatabase.openRealm()
            
            let objectToDelete: RealmDownloadedLanguage? = realmDatabase.read.object(realm: realm, id: languageId)
            
            if let objectToDelete = objectToDelete {
                
                try realmDatabase.write.realm(realm: realm, writeClosure: { realm in
                    
                    return WriteRealmObjects(
                        deleteObjects: [objectToDelete],
                        addObjects: []
                    )
                }, updatePolicy: .all)
            }
        }
    }
}
