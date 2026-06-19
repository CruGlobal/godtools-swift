//
//  ToolLanguageDownloadCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift

final class ToolLanguageDownloadCache {
    
    enum DownloadState {
        case all
        case complete
        case incomplete
    }
    
    let persistence: any Persistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel>
    
    init(persistence: any Persistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel, SwiftToolLanguageDownload>? {
        return persistence as? SwiftRepositorySyncPersistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel, SwiftToolLanguageDownload>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel, RealmToolLanguageDownload>? {
        return persistence as? RealmRepositorySyncPersistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel, RealmToolLanguageDownload>
    }
}

// MARK: - Predicates

extension ToolLanguageDownloadCache {
 
    @available(iOS 17.4, *)
    private func getDownloadCompletePredicate() -> Predicate<SwiftToolLanguageDownload> {
     
        let filter = #Predicate<SwiftToolLanguageDownload> { object in
            object.downloadProgress >= 1
        }
        
        return filter
    }
    
    @available(iOS 17.4, *)
    private func getIncompleteDownloadPredicate() -> Predicate<SwiftToolLanguageDownload> {
     
        let filter = #Predicate<SwiftToolLanguageDownload> { object in
            object.downloadProgress < 1
        }
        
        return filter
    }
}

extension ToolLanguageDownloadCache {
    
    func getDownloads(state: DownloadState) async throws -> [ToolLanguageDownloadDataModel] {
        
        guard state != .all else {
            return try await persistence.getDataModels()
        }
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter: Predicate<SwiftToolLanguageDownload> = state == .complete ? getDownloadCompletePredicate() : getIncompleteDownloadPredicate()
            
            let query = SwiftDatabaseQuery<SwiftToolLanguageDownload>.filter(
                filter: filter
            )
            
            let context = swiftPersistence.database.openContext()
            
            let objects: [SwiftToolLanguageDownload] = try swiftPersistence.database.read.objects(context: context, query: query)
            
            return objects.map {
                $0.toModel()
            }
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let realm = try realmPersistence.database.openRealm()
            
            let results: Results<RealmToolLanguageDownload> = realm.objects(RealmToolLanguageDownload.self).where {
                
                if state == .complete {
                    $0.downloadProgress >= 1
                }
                else {
                    $0.downloadProgress < 1
                }
            }
            
            return results.map {
                $0.toModel()
            }
        }
        
        return Array()
    }
}
