//
//  GetAllLessonsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllLessonsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonsListItems: GetLessonsListItems

    init(resourcesRepository: ResourcesRepository, lessonProgressRepository: UserLessonProgressRepository, getLessonsListItems: GetLessonsListItems) {
        
        self.resourcesRepository = resourcesRepository
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonsListItems = getLessonsListItems
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Error> {
                
        return Publishers.CombineLatest(
            resourcesRepository
                .persistence
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
                .setFailureType(to: Error.self)
        )
        .flatMap({ (resourcesDidChange: Void, lessonProgressDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Error> in
                        
            return self.resourcesRepository
                .cache
                .getLessonsPublisher(filterByLanguageId: filterLessonsByLanguage?.languageId, sorted: true)
                .map { (lessons: [ResourceDataModel]) in
                    
                    let lessonsListItems: [LessonListItemDomainModel] = self.getLessonsListItems.mapLessonsToListItems(
                        lessons: lessons,
                        appLanguage: appLanguage,
                        filterLessonsByLanguage: filterLessonsByLanguage
                    )

                    return lessonsListItems
                }
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

    }
}
