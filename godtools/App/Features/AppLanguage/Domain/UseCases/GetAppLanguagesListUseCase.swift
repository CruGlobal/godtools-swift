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
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getAppLanguagesListRepositoryInterface: GetAppLanguagesListRepositoryInterface
    private let getUserPreferredAppLanguageRepositoryInterface: GetUserPreferredAppLanguageRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguagesListRepositoryInterface: GetAppLanguagesListRepositoryInterface, getUserPreferredAppLanguageRepositoryInterface: GetUserPreferredAppLanguageRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguagesListRepositoryInterface = getAppLanguagesListRepositoryInterface
        self.getUserPreferredAppLanguageRepositoryInterface = getUserPreferredAppLanguageRepositoryInterface
    }
    
    func getAppLanguagesListPublisher() -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        Publishers.CombineLatest(
            getAppLanguagesListRepositoryInterface.observeLanguagesChangedPublisher(),
            getCurrentAppLanguageUseCase.getLanguagePublisher()
        )
        .flatMap({ (languagesListChanged: Void, currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
            
            return self.getAppLanguagesListRepositoryInterface.getLanguagesPublisher(currentAppLanguage: currentAppLanguage)
                .eraseToAnyPublisher()
        })
        .flatMap({ (items: [AppLanguageListItemDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                        
            let sortedItems: [AppLanguageListItemDomainModel] = items.sorted { (thisAppLanguage: AppLanguageListItemDomainModel, thatAppLanguage: AppLanguageListItemDomainModel) in
                return thisAppLanguage.languageNameTranslatedInCurrentAppLanguage < thatAppLanguage.languageNameTranslatedInCurrentAppLanguage
            }
            
            return Just(sortedItems)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
