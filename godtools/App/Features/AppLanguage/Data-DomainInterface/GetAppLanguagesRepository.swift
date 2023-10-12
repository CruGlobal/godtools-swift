//
//  GetAppLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguagesRepository: GetAppLanguagesRepositoryInterface {
    
    private let appLanguagesRepository: AppLanguagesRepository
    
    init(appLanguagesRepository: AppLanguagesRepository) {
        
        self.appLanguagesRepository = appLanguagesRepository
    }
    
    func getAppLanguagesPublisher() -> AnyPublisher<[AppLanguageCodeDomainModel], Never> {
        
        return appLanguagesRepository.getLanguagesPublisher()
            .flatMap({ (languages: [AppLanguageDataModel]) -> AnyPublisher<[AppLanguageCodeDomainModel], Never> in
                
                let appLanguages: [AppLanguageCodeDomainModel] = languages.map {
                    $0.languageCode
                }
                
                return Just(appLanguages)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func observeAppLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return appLanguagesRepository.getLanguagesChangedPublisher()
    }
}
