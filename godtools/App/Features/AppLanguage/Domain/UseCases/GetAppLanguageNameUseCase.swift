//
//  GetAppLanguageNameUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetAppLanguageNameUseCase {
    
    private let getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepositoryInterface
    
    init(getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepositoryInterface) {
        
        self.getAppLanguageNameRepositoryInterface = getAppLanguageNameRepositoryInterface
    }
    
    func getLanguageName(languageCode: AppLanguageCodeDomainModel) -> AppLanguageNameDomainModel {
        
        return getAppLanguageNameRepositoryInterface.getLanguageName(languageCode: languageCode, translateInLanguageCode: languageCode)
    }
}
