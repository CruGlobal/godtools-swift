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
    
    let realmPersistence: RealmRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, RealmDownloadedLanguage>
    
    init(realmPersistence: RealmRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, RealmDownloadedLanguage>) {
                
        self.realmPersistence = realmPersistence
    }
}

// MARK: - Predicates

extension DownloadedLanguagesCache {
    
    private func getDownloadCompleteNSPredicate() -> NSPredicate {
        
        return NSPredicate(format: "\(#keyPath(RealmDownloadedLanguage.downloadComplete)) == %@", NSNumber(value: true))
    }
}

extension DownloadedLanguagesCache {
    
    func getCompletedDownloads() async throws -> [DownloadedLanguageDataModel] {
        
        let query = RealmDatabaseQuery.filter(
            filter: getDownloadCompleteNSPredicate()
        )
        
        return try await realmPersistence
            .newActorRead()
            .getDataModels(query: query)
    }
}
