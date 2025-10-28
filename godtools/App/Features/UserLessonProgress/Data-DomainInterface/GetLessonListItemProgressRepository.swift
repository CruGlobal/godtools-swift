//
//  GetLessonListItemProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import Combine

class GetLessonListItemProgressRepository {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    private let userCountersRepository: UserCountersRepository
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedPercentage: GetTranslatedPercentage
    
    init(lessonProgressRepository: UserLessonProgressRepository, userCountersRepository: UserCountersRepository, localizationServices: LocalizationServicesInterface, getTranslatedPercentage: GetTranslatedPercentage) {
        self.lessonProgressRepository = lessonProgressRepository
        self.userCountersRepository = userCountersRepository
        self.localizationServices = localizationServices
        self.getTranslatedPercentage = getTranslatedPercentage
    }
    
    func getLessonListItemProgressChanged() -> AnyPublisher<Void, Never> {
        return lessonProgressRepository.getLessonProgressChangedPublisher()
    }
    
    func getLessonProgress(lesson: ResourceDataModel, appLanguage: AppLanguageDomainModel) -> LessonListItemProgressDomainModel {
        
        let lessonId = lesson.id
        let lessonCompletionUserCounterId = UserCounterNames.shared.LESSON_COMPLETION(tool: lesson.abbreviation)
        if self.userCountersRepository.getUserCounter(id: lessonCompletionUserCounterId) != nil {
            
            let completeString = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage.localeId, key: "lessons.lessonCompleted")
            return .complete(completeString: completeString)
        }
        else if let lessonProgress = self.lessonProgressRepository.getLessonProgress(lessonId: lessonId) {
            
            let progress = lessonProgress.progress
            
            let formatString = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage.localeId, key: "lessons.completionProgress")
            let percentageString = getTranslatedPercentage.getTranslatedPercentage(percentValue: progress, translateInLanguage: appLanguage)
            
            let progressString = String(
                format: formatString,
                locale: Locale(identifier: appLanguage.localeId),
                percentageString
            )
            return .inProgress(progress: progress, progressString: progressString)
            
        } else {
            return .hidden
        }
    }
}
