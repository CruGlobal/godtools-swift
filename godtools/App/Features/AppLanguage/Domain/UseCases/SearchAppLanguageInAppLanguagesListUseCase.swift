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
    
    private let getAppLanguagesListUseCase: GetAppLanguagesListUseCase
    
    init(getAppLanguagesListUseCase: GetAppLanguagesListUseCase) {
        self.getAppLanguagesListUseCase = getAppLanguagesListUseCase
    }
    
    func getSearchResultsPublisher(for searchTextPublisher: AnyPublisher<String, Never>) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            searchTextPublisher,
            getAppLanguagesListUseCase.observeAppLanguagesListPublisher()
        )
            .flatMap { searchText, languageItems in
                
                print("did search: \(searchText)")
                
                if searchText.isEmpty {
                    
                    return Just(languageItems)
                    
                } else {
                    
                    let lowercasedSearchText = searchText.lowercased()
                    
                    let filteredItems = languageItems.filter { languageItem in
                        
                        let lowercasedLanguageName = languageItem.languageNameTranslatedInCurrentAppLanguage.value.lowercased()
                        
                        return lowercasedLanguageName.contains(lowercasedSearchText)
                    }
                    
                    return Just(filteredItems)
                }
            }
            .eraseToAnyPublisher()
    }
}
