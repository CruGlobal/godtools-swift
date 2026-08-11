//
//  GetLessonListItemProgress.swift
//  godtools
//
//  Created by Rachael Skeath on 10/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import Combine

final class GetLessonListItemProgress {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    private let userCountersRepository: UserCountersRepository
    private let localizationServices: LocalizationServicesInterface
    private let getTranslatedPercentage: GetTranslatedPercentage
    
    init(
        lessonProgressRepository: UserLessonProgressRepository,
        userCountersRepository: UserCountersRepository,
        localizationServices: LocalizationServicesInterface,
        getTranslatedPercentage: GetTranslatedPercentage
    ) {
        
        self.lessonProgressRepository = lessonProgressRepository
        self.userCountersRepository = userCountersRepository
        self.localizationServices = localizationServices
        self.getTranslatedPercentage = getTranslatedPercentage
    }
    
    func getLessonProgress(
        lesson: ResourceDataModel,
        appLanguage: AppLanguageDomainModel
    ) async throws -> LessonListItemProgressDomainModel {
        
        let lessonId: String = lesson.id
        let lessonCompletionUserCounterId: String = UserCounterNames.shared.LESSON_COMPLETION(tool: lesson.abbreviation)
        let lessonProgress: UserLessonProgressDataModel? = lessonProgressRepository.getLessonProgress(lessonId: lessonId)
        let progress: Double? = lessonProgress?.progress
        let lessonProgressIsComplete: Bool = progress == 1
        
        if try userCountersRepository.getCachedCounter(id: lessonCompletionUserCounterId) != nil || lessonProgressIsComplete {
            
            let completeString = await localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage.localeId,
                key: LocalizableStringKeys.lessonsLessonCompleted.key
            )
            
            return .complete(completeString: completeString)
        }
        else if let lessonProgress = lessonProgress {
            
            let progress: Double = lessonProgress.progress
            
            let formatString = await localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage.localeId,
                key: LocalizableStringKeys.lessonsCompletionProgress.key
            )
            
            let percentageString = getTranslatedPercentage.getTranslatedPercentage(
                percentValue: progress,
                translateInLanguage: appLanguage
            )
            
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
