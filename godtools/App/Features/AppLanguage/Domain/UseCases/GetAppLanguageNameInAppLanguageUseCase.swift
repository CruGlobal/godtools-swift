//
//  GetAppLanguageNameInAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetAppLanguageNameInAppLanguageUseCase {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguageNameRepositoryInterface = getAppLanguageNameRepositoryInterface
    }
    
    func getLanguageName(languageCode: AppLanguageCodeDomainModel) -> AppLanguageNameDomainModel {
        
        let appLanguageLanguageCode: AppLanguageCodeDomainModel = getCurrentAppLanguageUseCase.getAppLanguage()
        
        return getAppLanguageNameRepositoryInterface.getLanguageName(languageCode: languageCode, translateInLanguageCode: appLanguageLanguageCode)
    }
}
