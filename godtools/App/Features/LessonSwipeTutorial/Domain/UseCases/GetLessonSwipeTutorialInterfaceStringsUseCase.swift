//
//  GetLessonSwipeTutorialInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonSwipeTutorialInterfaceStringsUseCase {
    
    private let getLessonSwipeTutorialInterfaceStringsRepo: GetLessonSwipeTutorialInterfaceStringsRepositoryInterface
    
    init(getLessonSwipeTutorialInterfaceStringsRepo: GetLessonSwipeTutorialInterfaceStringsRepositoryInterface) {
        self.getLessonSwipeTutorialInterfaceStringsRepo = getLessonSwipeTutorialInterfaceStringsRepo
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonSwipeTutorialInterfaceStringsDomainModel, Never> {
        
        return getLessonSwipeTutorialInterfaceStringsRepo
            .getStringsPublisher(translateInLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
