//
//  ToolLanguageDownloadCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class ToolLanguageDownloadCache {
    
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
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel, RealmToolLanguageDownload>? {
        return persistence as? RealmRepositorySyncPersistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel, RealmToolLanguageDownload>
    }
}
