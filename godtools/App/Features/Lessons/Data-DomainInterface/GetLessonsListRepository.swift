//
//  GetLessonsListRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser
import LocalizationServices

class GetLessonsListRepository: GetLessonsListRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    private let lessonProgressRepository: UserLessonProgressRepository
    private let userCountersRepository: UserCountersRepository
    private let localizationServices: LocalizationServices

    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability, lessonProgressRepository: UserLessonProgressRepository, userCountersRepository: UserCountersRepository, localizationServices: LocalizationServices) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
        self.lessonProgressRepository = lessonProgressRepository
        self.userCountersRepository = userCountersRepository
        self.localizationServices = localizationServices
    }
    
    func getLessonsListPublisher(appLanguage: AppLanguageDomainModel, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) -> AnyPublisher<[LessonListItemDomainModel], Never> {
                
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChangedPublisher(),
            lessonProgressRepository.getLessonProgressChangedPublisher()
        )
        .flatMap({ (resourcesDidChange: Void, lessonProgressDidChange: Void) -> AnyPublisher<[LessonListItemDomainModel], Never> in
            
            let lessons: [ResourceModel] = self.resourcesRepository.getAllLessons(filterByLanguageId: filterLessonsByLanguage?.languageId, sorted: true)
            
            let lessonListItems: [LessonListItemDomainModel] = lessons.map { (resource: ResourceModel) in
                
                let filterLanguageModel: LanguageModel?
                if let filterLanguageId = filterLessonsByLanguage?.languageId {
                    
                    filterLanguageModel = self.languagesRepository.getLanguage(id: filterLanguageId)
                } else {
                    filterLanguageModel = nil
                }
                
                let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel = self.getToolLanguageAvailability(appLanguage: appLanguage, filterLanguageModel: filterLanguageModel, resource: resource)
                let lessonName: String = self.getTranslatedToolName.getToolName(resource: resource, translateInLanguage: filterLanguageModel?.code ?? appLanguage)
                
                let lessonProgress: LessonListItemProgressDomainModel = self.getLessonProgress(lesson: resource, appLanguage: appLanguage)
                
                return LessonListItemDomainModel(
                    analyticsToolName: resource.abbreviation,
                    availabilityInAppLanguage: toolLanguageAvailability,
                    bannerImageId: resource.attrBanner,
                    dataModelId: resource.id,
                    name: lessonName,
                    lessonProgress: lessonProgress
                )
            }
            
            return Just(lessonListItems)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()

    }
}

extension GetLessonsListRepository {
    
    private func getToolLanguageAvailability(appLanguage: AppLanguageDomainModel, filterLanguageModel: LanguageModel?, resource: ResourceModel) -> ToolLanguageAvailabilityDomainModel {

        if let appLanguageModel = languagesRepository.getLanguage(code: appLanguage) {
            
            let language: LanguageModel
            
            if let filterLanguageModel = filterLanguageModel {
                language = filterLanguageModel
            } else {
                language = appLanguageModel
            }
            
            return self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: resource, language: language, translateInLanguage: appLanguageModel)
        }
        else {
            return ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
        }
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
            return .inProgress(completionProgress: progress, progressString: progressString)
           
        } else {
            return .hidden
        }
    }
    
    func formatProgressPercentage(progress: Double, appLanguage: AppLanguageDomainModel) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.locale = Locale(identifier: appLanguage.localeId)
        
        return numberFormatter.string(from: NSNumber(value: progress)) ?? "\(progress)%"
    }
}
