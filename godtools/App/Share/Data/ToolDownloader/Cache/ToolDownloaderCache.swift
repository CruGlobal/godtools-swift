//
//  ToolDownloaderCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift

final class ToolDownloaderCache: Sendable {

    let persistence: any Persistence<ToolDownloadDataModel, ToolDownloadDataModel>

    init(persistence: any Persistence<ToolDownloadDataModel, ToolDownloadDataModel>) {

        self.persistence = persistence
    }

    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<ToolDownloadDataModel, ToolDownloadDataModel, SwiftToolDownload>? {
        return persistence as? SwiftRepositorySyncPersistence<ToolDownloadDataModel, ToolDownloadDataModel, SwiftToolDownload>
    }

    private func getRealmPersistence() -> RealmRepositorySyncPersistence<ToolDownloadDataModel, ToolDownloadDataModel, RealmToolDownload>? {
        return persistence as? RealmRepositorySyncPersistence<ToolDownloadDataModel, ToolDownloadDataModel, RealmToolDownload>
    }
}
