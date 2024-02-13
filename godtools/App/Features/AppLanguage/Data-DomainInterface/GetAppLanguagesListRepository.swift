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
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    
    init(appLanguagesRepository: AppLanguagesRepository, translatedLanguageNameRepository: TranslatedLanguageNameRepository) {
        
        self.appLanguagesRepository = appLanguagesRepository
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
    }
    
    func getLanguagesPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return appLanguagesRepository.getLanguagesPublisher()
            .flatMap({ (languages: [AppLanguageDataModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                
                let appLanguagesList: [AppLanguageListItemDomainModel] = languages.map { (languageDataModel: AppLanguageDataModel) in
                                                            
                    let languageNameTranslatedInOwnLanguage: String = self.translatedLanguageNameRepository.getLanguageName(language: languageDataModel, translatedInLanguage: languageDataModel.languageId)
                    let languageNameTranslatedInCurrentAppLanguage: String = self.translatedLanguageNameRepository.getLanguageName(language: languageDataModel, translatedInLanguage: appLanguage)
                    
                    return AppLanguageListItemDomainModel(
                        language: languageDataModel.languageId,
                        languageNameTranslatedInOwnLanguage: languageNameTranslatedInOwnLanguage,
                        languageNameTranslatedInCurrentAppLanguage: languageNameTranslatedInCurrentAppLanguage
                    )
                }
                .sorted { (thisAppLanguage: AppLanguageListItemDomainModel, thatAppLanguage: AppLanguageListItemDomainModel) in
                    return thisAppLanguage.languageNameTranslatedInCurrentAppLanguage < thatAppLanguage.languageNameTranslatedInCurrentAppLanguage
                }
                
                return Just(appLanguagesList)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
