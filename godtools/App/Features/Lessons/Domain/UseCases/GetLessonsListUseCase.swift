//
//  GetLessonsListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsListUseCase {

    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLessonsListRepositoryInterface: GetLessonsListRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLessonsListRepositoryInterface: GetLessonsListRepositoryInterface) {
       
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLessonsListRepositoryInterface = getLessonsListRepositoryInterface
    }
    
    func getLessonsListPublisher() -> AnyPublisher<[LessonListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            getLessonsListRepositoryInterface.observeLessonsChangedPublisher(),
            getCurrentAppLanguageUseCase.getLanguagePublisher()
        )
        .flatMap({ (lessonsListChanged: Void, currentAppLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<[LessonListItemDomainModel], Never> in

            return self.getLessonsListRepositoryInterface.getLessonsListPublisher(currentAppLanguageCode: currentAppLanguageCode)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
