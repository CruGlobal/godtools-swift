//
//  GetFeaturedLessonsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFeaturedLessonsUseCase {
    
    private let getFeaturedLessonsRepository: GetFeaturedLessonsRepositoryInterface
    
    init(getFeaturedLessonsRepository: GetFeaturedLessonsRepositoryInterface) {
       
        self.getFeaturedLessonsRepository = getFeaturedLessonsRepository
    }
    
    func getFeaturedLessonsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[FeaturedLessonDomainModel], Never> {
        
        return getFeaturedLessonsRepository
            .getFeaturedLessonsPublisher(appLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
