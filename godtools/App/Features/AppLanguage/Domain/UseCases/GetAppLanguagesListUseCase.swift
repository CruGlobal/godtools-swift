//
//  GetAppLanguagesListUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetAppLanguagesListUseCase {
    
    private let getAppLanguagesListRepositoryInterface: GetAppLanguagesListRepositoryInterface
    private let getAppLanguageNameUseCase: GetAppLanguageNameUseCase
    private let getAppLanguageNameInAppLanguageUseCase: GetAppLanguageNameInAppLanguageUseCase
    
    init(getAppLanguagesListRepositoryInterface: GetAppLanguagesListRepositoryInterface, getAppLanguageNameUseCase: GetAppLanguageNameUseCase, getAppLanguageNameInAppLanguageUseCase: GetAppLanguageNameInAppLanguageUseCase) {
        
        self.getAppLanguagesListRepositoryInterface = getAppLanguagesListRepositoryInterface
        self.getAppLanguageNameUseCase = getAppLanguageNameUseCase
        self.getAppLanguageNameInAppLanguageUseCase = getAppLanguageNameInAppLanguageUseCase
    }
    
    func getAppLanguagesList() -> [AppLanguageListItemDomainModel] {
        
        return getAppLanguagesListRepositoryInterface.getAppLanguagesList()
            .map({
                
                AppLanguageListItemDomainModel(
                    languageCode: $0,
                    languageNameTranslatedInOwnLanguage: self.getAppLanguageNameUseCase.getLanguageName(languageCode: $0),
                    languageNameTranslatedInCurrentAppLanguage: self.getAppLanguageNameInAppLanguageUseCase.getLanguageName(languageCode: $0)
                )
            })
    }
}
