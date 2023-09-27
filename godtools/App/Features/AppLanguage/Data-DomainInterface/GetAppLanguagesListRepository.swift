//
//  GetAppLanguagesListRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetAppLanguagesListRepository: GetAppLanguagesListRepositoryInterface {
    
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(appLanguagesRepository: AppLanguagesRepository) {
        
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func getAppLanguagesList() -> [AppLanguageCodeDomainModel] {
        
        return appLanguagesRepository.getLanguages()
            .map {
                $0.languageCode
            }
    }
}
