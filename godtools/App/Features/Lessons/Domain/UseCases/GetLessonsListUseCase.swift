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
    private let getLessonNameInAppLanguageUseCase: GetLessonNameInAppLanguageUseCase
    private let getLessonAvailabilityInAppLanguageUseCase: GetLessonAvailabilityInAppLanguageUseCase
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLessonsListRepositoryInterface: GetLessonsListRepositoryInterface, getLessonNameInAppLanguageUseCase: GetLessonNameInAppLanguageUseCase, getLessonAvailabilityInAppLanguageUseCase: GetLessonAvailabilityInAppLanguageUseCase) {
       
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLessonsListRepositoryInterface = getLessonsListRepositoryInterface
        self.getLessonNameInAppLanguageUseCase = getLessonNameInAppLanguageUseCase
        self.getLessonAvailabilityInAppLanguageUseCase = getLessonAvailabilityInAppLanguageUseCase
    }
    
    func observeLessonsListPublisher() -> AnyPublisher<[LessonListItemDomainModel], Never> {
        
        return Publishers.Merge(
            getLessonsListRepositoryInterface.observeLessonsChangedPublisher(),
            getCurrentAppLanguageUseCase.observeLanguageChangedPublisher()
                .map { _ in
                    Void()
                }
        )
        .flatMap({ (void: Void) -> AnyPublisher<[LessonListItemDomainModel], Never> in
            return self.getLessonsListPublisher()
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    func getLessonsListPublisher() -> AnyPublisher<[LessonListItemDomainModel], Never> {
        
        return getLessonsListRepositoryInterface.getLessonsListPublisher()
            .flatMap({ (lessons: [LessonDomainModel]) -> AnyPublisher<[LessonListItemDomainModel], Never> in
                
                return self.getLessonListItemPublishers(lessons: lessons)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getLessonListItemPublishers(lessons: [LessonDomainModel]) -> AnyPublisher<[LessonListItemDomainModel], Never> {
        
        let lessonItemPublishers = lessons.map {
            self.getLessonListItemPublisher(lesson: $0)
        }
        
        return Publishers.MergeMany(lessonItemPublishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func getLessonListItemPublisher(lesson: LessonDomainModel) -> AnyPublisher<LessonListItemDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getLessonAvailabilityInAppLanguageUseCase.getAvailabilityPublisher(lesson: lesson),
            getLessonNameInAppLanguageUseCase.getLessonNamePublisher(lesson: lesson)
        )
        .flatMap({ (availability: LessonAvailabilityInAppLanguageDomainModel, lessonName: LessonNameDomainModel) -> AnyPublisher<LessonListItemDomainModel, Never> in
            
            let lessonListItem = LessonListItemDomainModel(
                appLanguageAvailability: availability,
                lesson: lesson,
                name: lessonName
            )
            
            return Just(lessonListItem)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
