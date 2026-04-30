//
//  UserToolSettingsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class UserToolSettingsRepository {
    
    private let cache: UserToolSettingsCache
    
    init(cache: UserToolSettingsCache) {
        self.cache = cache
    }
    
    func getUserToolSettings(toolId: String) -> UserToolSettingsDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: toolId)
        }
        catch _ {
            return nil
        }
    }
    
    func storeUserToolSettings(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) async throws {
        
        let dataModel = UserToolSettingsDataModel(
            id: toolId,
            createdAt: Date(),
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
        
        _ = try await cache.persistence.writeObjectsAsync(
            externalObjects: [dataModel],
            writeOption: nil,
            getOption: nil
        )
    }
}
