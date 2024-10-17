//
//  GetLessonListItemProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import LocalizationServices
import Combine

class GetLessonListItemProgressRepository {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    private let userCountersRepository: UserCountersRepository
    private let localizationServices: LocalizationServices
    
    init(lessonProgressRepository: UserLessonProgressRepository, userCountersRepository: UserCountersRepository, localizationServices: LocalizationServices) {
        self.lessonProgressRepository = lessonProgressRepository
        self.userCountersRepository = userCountersRepository
        self.localizationServices = localizationServices
    }
    
    func getLessonListItemProgressChanged() -> AnyPublisher<Void, Never> {
        return lessonProgressRepository.getLessonProgressChangedPublisher()
    }
    
    func getLessonProgress(lesson: ResourceModel, appLanguage: AppLanguageDomainModel) -> LessonListItemProgressDomainModel {
        
        let lessonId = lesson.id
        let lessonCompletionUserCounterId = UserCounterNames.shared.LESSON_COMPLETION(tool: lesson.abbreviation)
        if self.userCountersRepository.getUserCounter(id: lessonCompletionUserCounterId) != nil {
            
            let completeString = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage.localeId, key: "lessons.lessonCompleted")
            return .complete(completeString: completeString)
        }
        else if let lessonProgress = self.lessonProgressRepository.getLessonProgress(lessonId: lessonId) {
            
            let progress = lessonProgress.progress
            
            let formatString = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage.localeId, key: "lessons.completionProgress")
            let percentageString = formatProgressPercentage(progress: progress, appLanguage: appLanguage)
            
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

extension GetLessonListItemProgressRepository {
    
    private func formatProgressPercentage(progress: Double, appLanguage: AppLanguageDomainModel) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.locale = Locale(identifier: appLanguage.localeId)
        
        return numberFormatter.string(from: NSNumber(value: progress)) ?? "\(progress)%"
    }
}
