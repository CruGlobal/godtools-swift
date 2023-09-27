//
//  GetAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetAppLanguageRepository: GetAppLanguageRepositoryInterface {
    
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(appLanguagesRepository: AppLanguagesRepository) {
        
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func getAppLanguage(appLanguageCode: AppLanguageCodeDomainModel) -> AppLanguageDomainModel? {
        
        guard let appLanguageDataModel = appLanguagesRepository.getLanguage(languageCode: appLanguageCode) else {
            return nil
        }
                
        return AppLanguageDomainModel(
            languageCode: appLanguageCode,
            languageDirection: appLanguageDataModel.languageDirection == .leftToRight ? .leftToRight : .rightToLeft
        )
    }
}
