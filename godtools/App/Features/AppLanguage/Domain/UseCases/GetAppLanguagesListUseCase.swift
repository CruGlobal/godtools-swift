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

            let languageNamePair: TranslatedLanguageNamePairDomainModel = getTranslatedLanguageName.getLanguageNamePair(
                language: languageDataModel,
                appLanguage: appLanguage
            )

            appLanguages.append(
                AppLanguageListItemDomainModel(
                    language: languageDataModel.languageId,
                    languageNamePair: languageNamePair
                )
            )
        }

        let appLanguagesList: [AppLanguageListItemDomainModel] = appLanguages
            .sorted { (thisAppLanguage: AppLanguageListItemDomainModel, thatAppLanguage: AppLanguageListItemDomainModel) in
                return thisAppLanguage.languageNamePair.nameInAppLanguage < thatAppLanguage.languageNamePair.nameInAppLanguage
            }

        return appLanguagesList
    }
}
