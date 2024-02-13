//
//  SearchAppLanguageInAppLanguagesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchAppLanguageInAppLanguagesListUseCase {
        
    init() {

    }
    
    func getSearchResultsPublisher(searchText: String, appLanguagesList: [AppLanguageListItemDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        if searchText.isEmpty {
            
            return Just(appLanguagesList)
                .eraseToAnyPublisher()
            
        } else {
            
            let lowercasedSearchText = searchText.lowercased()
            
            let filteredItems = appLanguagesList.filter { languageItem in
                
                let lowercasedLanguageName = languageItem.languageNameTranslatedInCurrentAppLanguage.lowercased()
                
                return lowercasedLanguageName.contains(lowercasedSearchText)
            }
            
            return Just(filteredItems)
                .eraseToAnyPublisher()
        }
    }
}
