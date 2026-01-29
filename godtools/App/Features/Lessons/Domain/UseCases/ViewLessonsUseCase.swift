//
//  ViewLessonsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewLessonsUseCase {
    
    private let getInterfaceStringsRepository: GetLessonsInterfaceStringsRepositoryInterface
    private let getLessonsListRepository: GetLessonsListRepositoryInterface
    
    init(getInterfaceStringsRepository: GetLessonsInterfaceStringsRepositoryInterface, getLessonsListRepository: GetLessonsListRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getLessonsListRepository = getLessonsListRepository
    }
    
    @MainActor func viewPublisher(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<ViewLessonsDomainModel, Error> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository
                .getStringsPublisher(translateInLanguage: appLanguage)
                .setFailureType(to: Error.self),
            getLessonsListRepository.getLessonsListPublisher(appLanguage: appLanguage, filterLessonsByLanguage: filterLessonsByLanguage)
        )
        .flatMap({ (interfaceStrings: LessonsInterfaceStringsDomainModel, lessons: [LessonListItemDomainModel]) -> AnyPublisher<ViewLessonsDomainModel, Never> in
            
            let domainModel = ViewLessonsDomainModel(
                interfaceStrings: interfaceStrings,
                lessons: lessons
            )
            
            return Just(domainModel)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
