//
//  GetAppLanguagesListUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppLanguagesListUseCase {
    
    private let getAppLanguagesListRepository: GetAppLanguagesListRepositoryInterface
    
    init(getAppLanguagesListRepository: GetAppLanguagesListRepositoryInterface) {
        
        self.getAppLanguagesListRepository = getAppLanguagesListRepository
    }
    
    func getAppLanguagesListPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return getAppLanguagesListRepository
            .getLanguagesPublisher(appLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
