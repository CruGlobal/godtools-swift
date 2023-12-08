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
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewLessonsDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInLanguage: appLanguage),
            getLessonsListRepository.getLessonsListPublisher(appLanguage: appLanguage)
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
