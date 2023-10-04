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
    private let getLessonNameInAppLanguageUseCase: GetLessonNameInAppLanguageUseCase
    private let getLessonAvailabilityInAppLanguageUseCase: GetLessonAvailabilityInAppLanguageUseCase
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getFeaturedLessonsRepositoryInterface: GetFeaturedLessonsRepositoryInterface, getLessonNameInAppLanguageUseCase: GetLessonNameInAppLanguageUseCase, getLessonAvailabilityInAppLanguageUseCase: GetLessonAvailabilityInAppLanguageUseCase) {
       
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getFeaturedLessonsRepositoryInterface = getFeaturedLessonsRepositoryInterface
        self.getLessonNameInAppLanguageUseCase = getLessonNameInAppLanguageUseCase
        self.getLessonAvailabilityInAppLanguageUseCase = getLessonAvailabilityInAppLanguageUseCase
    }
    
    func observeFeaturedLessonsPublisher() -> AnyPublisher<[FeaturedLessonDomainModel], Never> {
        
        return Publishers.Merge(
            getFeaturedLessonsRepositoryInterface.observeFeaturedLessonsChangedPublisher(),
            getCurrentAppLanguageUseCase.observeLanguageChangedPublisher()
                .map { _ in
                    Void()
                }
        )
        .flatMap({ (void: Void) -> AnyPublisher<[FeaturedLessonDomainModel], Never> in
            return self.getFeaturedLessonsPublisher()
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    func getFeaturedLessonsPublisher() -> AnyPublisher<[FeaturedLessonDomainModel], Never> {
        
        return getFeaturedLessonsRepositoryInterface.getFeaturedLessonsPublisher()
            .flatMap({ (lessons: [LessonDomainModel]) -> AnyPublisher<[FeaturedLessonDomainModel], Never> in
                
                return self.getFeaturedLessonsPublishers(lessons: lessons)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getFeaturedLessonsPublishers(lessons: [LessonDomainModel]) -> AnyPublisher<[FeaturedLessonDomainModel], Never> {
        
        let featuredLessonsPublishers = lessons.map {
            self.getFeaturedLessonPublisher(lesson: $0)
        }
        
        return Publishers.MergeMany(featuredLessonsPublishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func getFeaturedLessonPublisher(lesson: LessonDomainModel) -> AnyPublisher<FeaturedLessonDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getLessonAvailabilityInAppLanguageUseCase.getAvailabilityPublisher(lesson: lesson),
            getLessonNameInAppLanguageUseCase.getLessonNamePublisher(lesson: lesson)
        )
        .flatMap({ (availability: LessonAvailabilityInAppLanguageDomainModel, lessonName: LessonNameDomainModel) -> AnyPublisher<FeaturedLessonDomainModel, Never> in
            
            let featuredLessons = FeaturedLessonDomainModel(
                appLanguageAvailability: availability,
                lesson: lesson,
                name: lessonName
            )
            
            return Just(featuredLessons)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
