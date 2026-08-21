//
//  GetAppLanguagesListUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetAppLanguagesListUseCase: Sendable {
    
    private let appLanguagesRepository: AppLanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(appLanguagesRepository: AppLanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.appLanguagesRepository = appLanguagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async throws -> [AppLanguageListItemDomainModel] {
        
        let languages: [AppLanguageDataModel] = try await appLanguagesRepository.getLanguages()
        
        var appLanguages: [AppLanguageListItemDomainModel] = Array()

        for languageDataModel in languages {

            let languageNameTranslatedInOwnLanguage: String = self.getTranslatedLanguageName.getLanguageName(language: languageDataModel, translatedInLanguage: languageDataModel.languageId)
            let languageNameTranslatedInCurrentAppLanguage: String = self.getTranslatedLanguageName.getLanguageName(language: languageDataModel, translatedInLanguage: appLanguage)

            appLanguages.append(
                AppLanguageListItemDomainModel(
                    language: languageDataModel.languageId,
                    languageNameTranslatedInOwnLanguage: languageNameTranslatedInOwnLanguage,
                    languageNameTranslatedInCurrentAppLanguage: languageNameTranslatedInCurrentAppLanguage
                )
            )
        }

        let appLanguagesList: [AppLanguageListItemDomainModel] = appLanguages
            .sorted { (thisAppLanguage: AppLanguageListItemDomainModel, thatAppLanguage: AppLanguageListItemDomainModel) in
                return thisAppLanguage.languageNameTranslatedInCurrentAppLanguage < thatAppLanguage.languageNameTranslatedInCurrentAppLanguage
            }

        return appLanguagesList
    }
}
