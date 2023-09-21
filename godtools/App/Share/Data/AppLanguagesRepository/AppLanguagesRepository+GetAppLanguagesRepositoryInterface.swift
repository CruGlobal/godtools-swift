//
//  AppLanguagesRepository+GetAppLanguagesRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

extension AppLanguagesRepository: GetAppLanguagesRepositoryInterface {
    
    func getAppLanguagesPublisher() -> AnyPublisher<[AppLanguageDomainModel], Never> {
        
        let appLanguagesCodes: [LanguageCode] = [.arabic, .chinese, .english, .french, .latvian, .russian, .spanish, .vietnamese]
        
        let appLanguages: [AppLanguageDomainModel] = appLanguagesCodes.map({
            return AppLanguageDomainModel(direction: .leftToRight, languageCode: $0.value)
        })
        
        return Just(appLanguages)
            .eraseToAnyPublisher()
    }
}
