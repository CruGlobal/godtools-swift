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
    private let getAppLanguageName: GetAppLanguageName
    
    init(appLanguagesRepository: AppLanguagesRepository, getAppLanguageName: GetAppLanguageName) {
        
        self.appLanguagesRepository = appLanguagesRepository
        self.getAppLanguageName = getAppLanguageName
    }
    
    func getLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return appLanguagesRepository.getLanguagesPublisher()
            .flatMap({ (languages: [AppLanguageDataModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                
                let appLanguagesList: [AppLanguageListItemDomainModel] = languages.map { (languageDataModel: AppLanguageDataModel) in
                                        
                    let languageCode: String = languageDataModel.languageCode
                    let languageScriptCode: String? = languageDataModel.languageScriptCode
                    
                    let languageNameTranslatedInOwnLanguage: String = self.getAppLanguageName.getName(languageCode: languageCode, scriptCode: languageScriptCode, translatedInLanguage: languageDataModel.languageId)
                    let languageNameTranslatedInCurrentAppLanguage: String = self.getAppLanguageName.getName(languageCode: languageCode, scriptCode: languageScriptCode, translatedInLanguage: currentAppLanguage)
                    
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
