//
//  GetAllLessonsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetAllLessonsUseCase: Sendable {
    
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
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel,
        filterLessonsByLanguageId: String?
    ) -> AnyPublisher<[LessonListItemDomainModel], Error> {

        return Publishers.CombineLatest(
            resourcesRepository
                .observeCollectionChangesPublisher(),
            lessonProgressRepository
                .getLessonProgressChangedPublisher()
        )
        .receive(on: DispatchQueue.global())
        .flatMap({ (resourcesDidChange: Void, lessonProgressDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Error> in

            return AnyPublisher() {
                try await self.asyncExecute(
                    appLanguage: appLanguage,
                    filterLessonsByLanguageId: filterLessonsByLanguageId
                )
            }
        })
        .eraseToAnyPublisher()

    }
    
    private func asyncExecute(
        appLanguage: AppLanguageDomainModel,
        filterLessonsByLanguageId: String?
    ) async throws -> [LessonListItemDomainModel] {
        
        let lessons: [ResourceDataModel] = try await resourcesRepository
            .getLessons(
                filterByLanguageId: filterLessonsByLanguageId,
                sorted: true
            )
        
        return try getLessonsListItems.mapLessonsToListItems(
            lessons: lessons,
            appLanguage: appLanguage,
            filterLessonsByLanguageId: filterLessonsByLanguageId
        )
    }
}
