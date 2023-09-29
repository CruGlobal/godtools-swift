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
    
    private let getAppLanguagesListRepositoryInterface: GetAppLanguagesListRepositoryInterface
    private let getAppLanguageNameUseCase: GetAppLanguageNameUseCase
    private let getAppLanguageNameInAppLanguageUseCase: GetAppLanguageNameInAppLanguageUseCase
    
    init(getAppLanguagesListRepositoryInterface: GetAppLanguagesListRepositoryInterface, getAppLanguageNameUseCase: GetAppLanguageNameUseCase, getAppLanguageNameInAppLanguageUseCase: GetAppLanguageNameInAppLanguageUseCase) {
        
        self.getAppLanguagesListRepositoryInterface = getAppLanguagesListRepositoryInterface
        self.getAppLanguageNameUseCase = getAppLanguageNameUseCase
        self.getAppLanguageNameInAppLanguageUseCase = getAppLanguageNameInAppLanguageUseCase
    }
    
    func getAppLanguagesListPublisher() -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return getAppLanguagesListRepositoryInterface.getLanguagesPublisher()
            .flatMap({ (appLanguages: [AppLanguageCodeDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                
                return self.getLanguageListItemPublishers(appLanguages: appLanguages)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (items: [AppLanguageListItemDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> in
                
                let sortedItems: [AppLanguageListItemDomainModel] = items.sorted { (thisAppLanguage: AppLanguageListItemDomainModel, thatAppLanguage: AppLanguageListItemDomainModel) in
                    return thisAppLanguage.languageNameTranslatedInCurrentAppLanguage.value < thatAppLanguage.languageNameTranslatedInCurrentAppLanguage.value
                }
                
                return Just(sortedItems)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getLanguageListItemPublishers(appLanguages: [AppLanguageCodeDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        let languageItemsPublishers = appLanguages.map {
            self.getLanguageListItemPublisher(language: $0)
        }
        
        return Publishers.MergeMany(languageItemsPublishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func getLanguageListItemPublisher(language: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageListItemDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getAppLanguageNameUseCase.getLanguageNamePublisher(language: language),
            getAppLanguageNameInAppLanguageUseCase.getLanguageNamePublisher(language: language)
        )
        .flatMap({ (languageNameTranslatedInOwnLanguage: AppLanguageNameDomainModel, languageNameTranslatedInCurrentAppLanguage: AppLanguageNameDomainModel) -> AnyPublisher<AppLanguageListItemDomainModel, Never> in
            
            let listItem = AppLanguageListItemDomainModel(
                languageCode: language,
                languageNameTranslatedInOwnLanguage: languageNameTranslatedInOwnLanguage,
                languageNameTranslatedInCurrentAppLanguage: languageNameTranslatedInCurrentAppLanguage
            )
            
            return Just(listItem)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
