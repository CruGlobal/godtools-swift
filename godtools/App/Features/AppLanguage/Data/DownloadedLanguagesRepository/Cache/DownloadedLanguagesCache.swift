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
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, SwiftDownloadedLanguage>? {
        return persistence as? SwiftRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, SwiftDownloadedLanguage>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, RealmDownloadedLanguage>? {
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
            
            return try await swiftPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = RealmDatabaseQuery.filter(
                filter: getDownloadCompleteNSPredicate(downloadComplete: downloadComplete)
            )
            
            return try await realmPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        
        return Array()
    }
    
    func deleteDownloadedLanguage(languageId: String) async throws {
            
        _ = try await persistence.deleteObjectsByIds(ids: [languageId], getOption: nil)
    }
}
