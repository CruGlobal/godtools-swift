//
//  GetUserPersonalizedLessonFilterLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserPersonalizedLessonFilterLanguageUseCase: Sendable {
            
    init() {
        
    }
    
    @MainActor func execute() -> AnyPublisher<PersonalizedLessonFilterLanguageDomainModel?, Error> {
        
        // TODO: Get personalized lesson language filter. ~Levi
        
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
