//
//  GetToolSettingsParallelLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsParallelLanguageRepository: GetToolSettingsParallelLanguageRepositoryInterface {
    
    init() {
        
    }
    
    func getLanguagePublisher() -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> {
        
        return Just(nil)
            .eraseToAnyPublisher()
    }
}
