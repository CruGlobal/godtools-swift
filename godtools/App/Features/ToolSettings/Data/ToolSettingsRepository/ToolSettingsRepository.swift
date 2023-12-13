//
//  ToolSettingsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolSettingsRepository {
    
    private static let sharedToolSettingsId: String = "shared_tool_settings_id"
    
    private let cache: RealmToolSettingsCache
    
    init(cache: RealmToolSettingsCache) {
        
        self.cache = cache
    }
    
    func getToolSettingsPublisher() -> AnyPublisher<ToolSettingsDataModel?, Never> {
        
        if let cachedToolSettings = cache.getToolSettings(id: ToolSettingsRepository.sharedToolSettingsId) {
            
            return Just(ToolSettingsDataModel(realmToolSettings: cachedToolSettings))
                .eraseToAnyPublisher()
        }
        
        return Just(nil)
            .eraseToAnyPublisher()
    }
    
    func getToolSettingsChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return cache.getToolSettingsChangedPublisher()
            .eraseToAnyPublisher()
    }
    
    func storePrimaryLanguagePublisher(languageId: String) -> AnyPublisher<Void, Never> {
        
        switch cache.storePrimaryLanguage(id: ToolSettingsRepository.sharedToolSettingsId, languageId: languageId) {
        case .success( _):
            break
        case .failure( _):
            break
        }
        
        return Just(())
            .eraseToAnyPublisher()
    }
    
    func storeParallelLanguagePublisher(languageId: String) -> AnyPublisher<Void, Never> {
        
        switch cache.storeParallelLanguage(id: ToolSettingsRepository.sharedToolSettingsId, languageId: languageId) {
        case .success( _):
            break
        case .failure( _):
            break
        }
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
