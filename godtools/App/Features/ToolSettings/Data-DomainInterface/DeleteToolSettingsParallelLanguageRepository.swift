//
//  DeleteToolSettingsParallelLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DeleteToolSettingsParallelLanguageRepository: DeleteToolSettingsParallelLanguageRepositoryInterface {
    
    private let toolSettingsRepository: ToolSettingsRepository
    
    init(toolSettingsRepository: ToolSettingsRepository) {
        
        self.toolSettingsRepository = toolSettingsRepository
    }
    
    func deletePublisher() -> AnyPublisher<Void, Never> {
        
        return toolSettingsRepository
            .deleteParallelLanguagePublisher()
            .eraseToAnyPublisher()
    }
}
