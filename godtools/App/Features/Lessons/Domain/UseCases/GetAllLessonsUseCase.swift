//
//  GetAllLessonsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetAllLessonsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let lessonProgressRepository: UserLessonProgressRepository
    private let getLessonsListItems: GetLessonsListItems

    init(
        resourcesRepository: ResourcesRepository,
        lessonProgressRepository: UserLessonProgressRepository,
        getLessonsListItems: GetLessonsListItems
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.lessonProgressRepository = lessonProgressRepository
        self.getLessonsListItems = getLessonsListItems
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Error> {

        return Publishers.CombineLatest(
            resourcesRepository
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
        )
        .flatMap({ (resourcesDidChange: Void, lessonProgressDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Error> in

            return AnyPublisher() {
                try await self.asyncExecute(appLanguage: appLanguage, filterLessonsByLanguage: filterLessonsByLanguage)
            }
        })
        .eraseToAnyPublisher()

    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) async throws -> [LessonListItemDomainModel] {
        
        let lessons: [ResourceDataModel] = try await resourcesRepository
            .getLessons(filterByLanguageId: filterLessonsByLanguage?.languageId, sorted: true)
        
        return try getLessonsListItems.mapLessonsToListItems(
            lessons: lessons,
            appLanguage: appLanguage,
            filterLessonsByLanguage: filterLessonsByLanguage
        )
    }
}
