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
        
        return getAllLanguagesPublisher()
            .map { (languages: [AppLanguageDataModel]) in
                
                return languages.map({
                    AppLanguageDomainModel(
                        direction: $0.direction == .leftToRight ? .leftToRight : .rightToLeft,
                        languageCode: $0.languageCode
                    )
                })
            }
            .eraseToAnyPublisher()
    }
}
