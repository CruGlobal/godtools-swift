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
    private let localeLanguageScriptName: LocaleLanguageScriptName
    
    init(appLanguagesRepository: AppLanguagesRepository, localeLanguageName: LocaleLanguageName, localeLanguageScriptName: LocaleLanguageScriptName) {
        
        self.appLanguagesRepository = appLanguagesRepository
        self.localeLanguageName = localeLanguageName
        self.localeLanguageScriptName = localeLanguageScriptName
    }
    
    func getLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return appLanguagesRepository.getLanguagesPublisher()
            .flatMap({ (languages: [AppLanguageDataModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                
                let appLanguagesList: [AppLanguageListItemDomainModel] = languages.map { (languageDataModel: AppLanguageDataModel) in
                    
                    let languageNameTranslatedInOwnLanguage: String = self.localeLanguageName.getLanguageName(forLanguageCode: languageDataModel.languageCode, translatedInLanguageId: languageDataModel.languageId) ?? ""
                    let languageNameTranslatedInAppLanguage: String = self.localeLanguageName.getLanguageName(forLanguageCode: languageDataModel.languageCode, translatedInLanguageId: currentAppLanguage) ?? ""
                    
                    let languageScriptNameTranslatedInOwnLanguage: String?
                    let languageScriptNameTranslatedInAppLanguage: String?
                    
                    if let languageScriptCode = languageDataModel.languageScriptCode, !languageScriptCode.isEmpty {
                        
                        languageScriptNameTranslatedInOwnLanguage = self.localeLanguageScriptName.getScriptName(forScriptCode: languageScriptCode, translatedInLanguageId: languageDataModel.languageId) ?? ""
                        languageScriptNameTranslatedInAppLanguage = self.localeLanguageScriptName.getScriptName(forScriptCode: languageScriptCode, translatedInLanguageId: currentAppLanguage)
                    }
                    else {
                        
                        languageScriptNameTranslatedInOwnLanguage = nil
                        languageScriptNameTranslatedInAppLanguage = nil
                    }
                    
                    return AppLanguageListItemDomainModel(
                        language: languageDataModel.languageId,
                        languageNameTranslatedInOwnLanguage: AppLanguageNameDomainModel(
                            languageName: languageNameTranslatedInOwnLanguage,
                            languageScriptName: languageScriptNameTranslatedInOwnLanguage
                        ),
                        languageNameTranslatedInCurrentAppLanguage: AppLanguageNameDomainModel(
                            languageName: languageNameTranslatedInAppLanguage,
                            languageScriptName: languageScriptNameTranslatedInAppLanguage
                        )
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
