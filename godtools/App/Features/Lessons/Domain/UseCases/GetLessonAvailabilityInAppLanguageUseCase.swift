//
//  GetLessonAvailabilityInAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonAvailabilityInAppLanguageUseCase {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguageNameUseCase: GetAppLanguageNameUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let getLessonIsAvailableInAppLanguageRepositoryInterface: GetLessonIsAvailableInAppLanguageRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguageNameUseCase: GetAppLanguageNameUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, getLessonIsAvailableInAppLanguageRepositoryInterface: GetLessonIsAvailableInAppLanguageRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguageNameUseCase = getAppLanguageNameUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.getLessonIsAvailableInAppLanguageRepositoryInterface = getLessonIsAvailableInAppLanguageRepositoryInterface
    }
    
    func getAvailabilityPublisher(lesson: LessonDomainModel) -> AnyPublisher<LessonAvailabilityInAppLanguageDomainModel, Never> {
        
        var appLanguage: AppLanguageCodeDomainModel = ""
        var appLanguageName: AppLanguageNameDomainModel = AppLanguageNameDomainModel(value: "")
        var languageNotAvailableString: String = ""
        
        return getCurrentAppLanguageUseCase.getLanguagePublisher()
            .flatMap({ (appLanguageCodeDomainModel: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageNameDomainModel, Never> in
                
                appLanguage = appLanguageCodeDomainModel
                
                return self.getAppLanguageNameUseCase.getLanguageNamePublisher(language: appLanguage)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (appLanguageNameDomainModel: AppLanguageNameDomainModel) -> AnyPublisher<String, Never> in
                
                appLanguageName = appLanguageNameDomainModel
                
                return self.getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "lessonCard.languageNotAvailable")
                    .eraseToAnyPublisher()
            })
            .flatMap({ (languageNotAvailableInterfaceString: String) -> AnyPublisher<Bool, Never> in
                
                languageNotAvailableString = languageNotAvailableInterfaceString
                
                return self.getLessonIsAvailableInAppLanguageRepositoryInterface.getLessonIsAvailableInAppLanguagePublisher(lesson: lesson, appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (isAvailable: Bool) -> AnyPublisher<LessonAvailabilityInAppLanguageDomainModel, Never> in
              
                let availabilityString: String
                
                if isAvailable {
                    availabilityString = appLanguageName.value + " ✓"
                }
                else {
                    availabilityString = String.localizedStringWithFormat(languageNotAvailableString, appLanguageName.value) + " ✕"
                }
                
                let availability = LessonAvailabilityInAppLanguageDomainModel(
                    availabilityString: availabilityString
                )
                
                return Just(availability)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
