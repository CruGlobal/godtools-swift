//
//  GetInterfaceLayoutDirectionUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetInterfaceLayoutDirectionUseCase: Sendable {
    
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(appLanguagesRepository: AppLanguagesRepository) {
        
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AppInterfaceLayoutDirectionDomainModel {
        
        let language: AppLanguageDataModel? = appLanguagesRepository.getLanguage(id: appLanguage)
        
        guard let language = language else {
            return .leftToRight
        }
        
        return language.languageDirection == .leftToRight ? .leftToRight : .rightToLeft
    }
}
