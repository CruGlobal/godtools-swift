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
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getFeaturedLessonsRepositoryInterface: GetFeaturedLessonsRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getFeaturedLessonsRepositoryInterface: GetFeaturedLessonsRepositoryInterface) {
       
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getFeaturedLessonsRepositoryInterface = getFeaturedLessonsRepositoryInterface
    }
    
    func getFeaturedLessonsPublisher() -> AnyPublisher<[FeaturedLessonDomainModel], Never> {
        
        return Publishers.CombineLatest(
            getFeaturedLessonsRepositoryInterface.observeFeaturedLessonsChangedPublisher(),
            getCurrentAppLanguageUseCase.getLanguagePublisher()
        )
        .flatMap({ (featuredLessonsChanged: Void, appLanguage: AppLanguageDomainModel) -> AnyPublisher<[FeaturedLessonDomainModel], Never> in

            return self.getFeaturedLessonsRepositoryInterface.getFeaturedLessonsPublisher(appLanguage: appLanguage)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
