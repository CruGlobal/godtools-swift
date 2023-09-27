//
//  GetInterfaceStringInAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetInterfaceStringInAppLanguageUseCase {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getInterfaceStringRepositoryInterface: GetInterfaceStringForLanguageRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getInterfaceStringRepositoryInterface = getInterfaceStringRepositoryInterface
    }
    
    func getString(id: String) -> String {
        
        let currentAppLanguage: AppLanguageCodeDomainModel = getCurrentAppLanguageUseCase.getAppLanguage()
        
        return getInterfaceStringRepositoryInterface.getInterfaceStringForLanguage(languageCode: currentAppLanguage, stringId: id)
    }
}
