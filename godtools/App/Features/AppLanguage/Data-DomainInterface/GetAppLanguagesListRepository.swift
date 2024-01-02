//
//  GetAppLanguagesListRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguagesListRepository: GetAppLanguagesListRepositoryInterface {
    
    private let appLanguagesRepository: AppLanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(appLanguagesRepository: AppLanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.appLanguagesRepository = appLanguagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func getLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return appLanguagesRepository.getLanguagesPublisher()
            .flatMap({ (languages: [AppLanguageDataModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                
                let appLanguagesList: [AppLanguageListItemDomainModel] = languages.map { (languageDataModel: AppLanguageDataModel) in
                                                            
                    let languageNameTranslatedInOwnLanguage: String = self.getTranslatedLanguageName.getLanguageName(language: languageDataModel, translatedInLanguage: languageDataModel.languageId)
                    let languageNameTranslatedInCurrentAppLanguage: String = self.getTranslatedLanguageName.getLanguageName(language: languageDataModel, translatedInLanguage: currentAppLanguage)
                    
                    return AppLanguageListItemDomainModel(
                        language: languageDataModel.languageId,
                        languageNameTranslatedInOwnLanguage: languageNameTranslatedInOwnLanguage,
                        languageNameTranslatedInCurrentAppLanguage: languageNameTranslatedInCurrentAppLanguage
                    )
                }
                
                return Just(appLanguagesList)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func observeLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return appLanguagesRepository.getLanguagesChangedPublisher()
            .eraseToAnyPublisher()
    }
}
