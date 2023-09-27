//
//  GetAppUILayoutDirectionUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetAppUILayoutDirectionUseCase {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguageRepositoryInterface: GetAppLanguageRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguageRepositoryInterface: GetAppLanguageRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguageRepositoryInterface = getAppLanguageRepositoryInterface
    }
    
    func getLayoutDirection() -> AppUILayoutDirectionDomainModel {
        
        let currentAppLanguageCode: AppLanguageCodeDomainModel = getCurrentAppLanguageUseCase.getAppLanguage()
        
        guard let appLanguage = getAppLanguageRepositoryInterface.getAppLanguage(appLanguageCode: currentAppLanguageCode) else {
            return .leftToRight
        }
        
        return appLanguage.languageDirection == .leftToRight ? .leftToRight : .rightToLeft
    }
}
