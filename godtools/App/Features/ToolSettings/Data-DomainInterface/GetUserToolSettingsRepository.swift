//
//  GetUserToolSettingsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 6/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserToolSettingsRepository: GetUserToolSettingsRepositoryInterface {
    
    private let userToolSettingsRepository: UserToolSettingsRepository
    
    init(userToolSettingsRepository: UserToolSettingsRepository) {
        self.userToolSettingsRepository = userToolSettingsRepository
    }
    
    func getUserToolSettingsPublisher(toolId: String) -> AnyPublisher<UserToolSettingsDomainModel?, Never> {
        
        return userToolSettingsRepository.getUserToolSettingsPublisher(toolId: toolId)
            .map { toolSettingsDataModel in
                
                guard let toolSettingsDataModel = toolSettingsDataModel else { return nil }
                
                return UserToolSettingsDomainModel(
                    toolId: toolId,
                    primaryLanguageId: toolSettingsDataModel.primaryLanguageId,
                    parallelLanguageId: toolSettingsDataModel.parallelLanguageId
                )
            }
            .eraseToAnyPublisher()
    }
    
    
    
}
