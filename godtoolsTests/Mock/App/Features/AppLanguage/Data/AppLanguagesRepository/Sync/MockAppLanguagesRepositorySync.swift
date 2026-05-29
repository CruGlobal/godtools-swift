//
//  MockAppLanguagesRepositorySync.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RepositorySync

final class MockAppLanguagesRepositorySync: AppLanguagesRepositorySyncInterface {
    
    private let testsDiContainer: TestsDiContainer
    private let appLanguages: [AppLanguageCodable]
    
    init(testsDiContainer: TestsDiContainer, appLanguages: [AppLanguageCodable]) async throws {
        
        self.testsDiContainer = testsDiContainer
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
        
        try await testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesPersistence()
            .writeObjects(externalObjects: appLanguages)
    }
}
