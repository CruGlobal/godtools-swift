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
    
    func getSharedToolSettings() -> ToolSettingsDataModel? {
        
        guard let realmToolSettings = cache.getToolSettings(id: ToolSettingsRepository.sharedToolSettingsId) else {
            return nil
        }
        
        return ToolSettingsDataModel(realmToolSettings: realmToolSettings)
    }
    
    func getSharedToolSettingsPublisher() -> AnyPublisher<ToolSettingsDataModel?, Never> {
        
        if let cachedToolSettings = cache.getToolSettings(id: ToolSettingsRepository.sharedToolSettingsId) {
            
            return Just(ToolSettingsDataModel(realmToolSettings: cachedToolSettings))
                .eraseToAnyPublisher()
        }
        
        return Just(nil)
            .eraseToAnyPublisher()
    }
    
    func getToolSettingsChangedPublisher() -> AnyPublisher<ToolSettingsDataModel?, Never> {
        
        return cache.getToolSettingsChangedPublisher()
            .flatMap({ (changed: Void) -> AnyPublisher<ToolSettingsDataModel?, Never> in
                
                return self.getSharedToolSettingsPublisher()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func storePrimaryLanguagePublisher(languageId: String) -> AnyPublisher<Void, Never> {
        
        return cache.storePrimaryLanguagePublisher(id: ToolSettingsRepository.sharedToolSettingsId, languageId: languageId)
            .catch { _ in
                return Just(())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func storeParallelLanguagePublisher(languageId: String) -> AnyPublisher<Void, Never> {
        
        return cache.storeParallelLanguagePublisher(id: ToolSettingsRepository.sharedToolSettingsId, languageId: languageId)
            .catch { _ in
                return Just(())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deletePrimaryLanguagePublisher() -> AnyPublisher<Void, Never> {
        
        return cache.deletePrimaryLanguagePublisher(id: ToolSettingsRepository.sharedToolSettingsId)
            .catch { _ in
                return Just(())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteParallelLanguagePublisher() -> AnyPublisher<Void, Never> {
        
        return cache.deleteParallelLanguagePublisher(id: ToolSettingsRepository.sharedToolSettingsId)
            .catch { _ in
                return Just(())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
