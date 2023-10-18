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
    private let localeLanguageName: LocaleLanguageName
    
    init(appLanguagesRepository: AppLanguagesRepository, localeLanguageName: LocaleLanguageName) {
        
        self.appLanguagesRepository = appLanguagesRepository
        self.localeLanguageName = localeLanguageName
    }
    
    func getLanguagesPublisher(currentAppLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return appLanguagesRepository.getLanguagesPublisher()
            .flatMap({ (languages: [AppLanguageDataModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                
                let appLanguagesList: [AppLanguageListItemDomainModel] = languages.map { (languageDataModel: AppLanguageDataModel) in
                    
                    return AppLanguageListItemDomainModel(
                        languageCode: languageDataModel.languageCode,
                        languageNameTranslatedInOwnLanguage: self.localeLanguageName.getDisplayName(
                            forLanguageCode: languageDataModel.languageCode,
                            translatedInLanguageCode: languageDataModel.languageCode
                        ) ?? "",
                        languageNameTranslatedInCurrentAppLanguage: self.localeLanguageName.getDisplayName(
                            forLanguageCode: languageDataModel.languageCode,
                            translatedInLanguageCode: currentAppLanguageCode
                        ) ?? ""
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
