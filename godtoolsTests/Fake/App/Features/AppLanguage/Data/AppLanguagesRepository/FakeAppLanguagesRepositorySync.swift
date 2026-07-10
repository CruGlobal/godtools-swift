//
//  FakeAppLanguagesRepositorySync.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RepositorySync

final class FakeAppLanguagesRepositorySync: AppLanguagesRepositorySyncInterface, Sendable {
    
    private let persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>
    private let appLanguages: [AppLanguageCodable]
    
    init(persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>, appLanguages: [AppLanguageCodable]) async throws {
        
        self.persistence = persistence
        self.appLanguages = appLanguages
        
        try await addAppLanguages(appLanguages: appLanguages)
    }
    
    func sync() async throws {
        
        guard appLanguages.isEmpty else {
            return
        }
        
        try await addAppLanguages(appLanguages: appLanguages)
    }
    
    private func addAppLanguages(appLanguages: [AppLanguageCodable]) async throws {
        
        try await persistence.writeObjects(externalObjects: appLanguages)
    }
}
