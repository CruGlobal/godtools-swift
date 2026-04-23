//
//  UserToolSettingsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class UserToolSettingsRepository {
    
    private let cache: RealmUserToolSettingsCache
    
    init(cache: RealmUserToolSettingsCache) {
        self.cache = cache
    }
    
    func storeUserToolSettings(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) {
        
        let dataModel = UserToolSettingsDataModel(
            id: toolId,
            createdAt: Date(),
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
        
        cache.storeUserToolSettings(dataModel: dataModel)
    }
    
    func getUserToolSettings(toolId: String) -> UserToolSettingsDataModel? {
        
        return cache.getUserToolSettings(toolId: toolId)
    }
    
    func getUserToolSettingsPublisher(toolId: String) -> AnyPublisher<UserToolSettingsDataModel?, Never> {
        
        return cache.getUserToolSettingsPublisher(toolId: toolId)
    }
}
