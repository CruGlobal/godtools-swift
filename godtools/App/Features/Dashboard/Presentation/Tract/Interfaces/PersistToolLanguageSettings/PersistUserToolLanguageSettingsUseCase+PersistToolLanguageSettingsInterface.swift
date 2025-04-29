//
//  PersistUserToolLanguageSettingsUseCase+PersistToolLanguageSettingsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

extension PersistUserToolLanguageSettingsUseCase: PersistToolLanguageSettingsInterface {
    
    func persistToolLanguageSettingsPublisher(with toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never> {
        
        return persistUserToolSettingsPublisher(
            with: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
    }
}
