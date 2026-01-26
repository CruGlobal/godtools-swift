//
//  ViewLessonFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 6/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewLessonFilterLanguagesUseCase {
    
    private let getLessonFilterLanguagesRepository: GetLessonFilterLanguagesRepositoryInterface
    private let getInterfaceStringsRepository: GetLessonFilterLanguagesInterfaceStringsRepositoryInterface
    
    init(getLessonFilterLanguagesRepository: GetLessonFilterLanguagesRepositoryInterface, getInterfaceStringsRepository: GetLessonFilterLanguagesInterfaceStringsRepositoryInterface) {
        self.getLessonFilterLanguagesRepository = getLessonFilterLanguagesRepository
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    func viewPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewLessonFilterLanguagesDomainModel, Error> {
            
        return Publishers.CombineLatest(
            getInterfaceStringsRepository
                .getStringsPublisher(translateInAppLanguage: translatedInAppLanguage)
                .setFailureType(to: Error.self),
            getLessonFilterLanguagesRepository
                .getLessonFilterLanguagesPublisher(translatedInAppLanguage: translatedInAppLanguage)
        )
        .map { interfaceStrings, languageFilters in
            
            return ViewLessonFilterLanguagesDomainModel(
                interfaceStrings: interfaceStrings,
                languageFilters: languageFilters
            )
        }
        .eraseToAnyPublisher()
    }
}
