//
//  AppLanguagesRepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine

final class AppLanguagesRepositorySync: AppLanguagesRepositorySyncInterface {
        
    private let api: AppLanguagesApi
    private let persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>
    private let syncInvalidator: SyncInvalidator
    
    init(api: AppLanguagesApi, persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>, syncInvalidator: SyncInvalidator) {
        
        self.api = api
        self.persistence = persistence
        self.syncInvalidator = syncInvalidator
    }
    
    func syncPublisher() -> AnyPublisher<Void, Error> {
        return AnyPublisher() {
            try await self.sync()
        }
    }
    
    private func sync() async throws {
        
        guard syncInvalidator.shouldSync else {
            return
        }
        
        let appLanguages: [AppLanguageCodable] = try await api.getAppLanguages()
        
        _ = try await persistence
            .writeObjectsAsync(
                externalObjects: appLanguages,
                writeOption: nil,
                getOption: nil
            )
        
        syncInvalidator.didSync()
    }
}
