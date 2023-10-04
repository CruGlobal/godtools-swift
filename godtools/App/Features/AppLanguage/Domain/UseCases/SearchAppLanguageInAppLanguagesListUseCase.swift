//
//  SearchAppLanguageInAppLanguagesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class SearchAppLanguageInAppLanguagesListUseCase {
    
    func getSearchResults(for searchText: String, searchingIn languageItems: [AppLanguageListItemDomainModel]) -> [AppLanguageListItemDomainModel] {
        
        if searchText.isEmpty {
            
            return languageItems
            
        } else {
            
            let lowercasedSearchText = searchText.lowercased()
            
            return languageItems.filter { languageItem in
                
                let lowercasedLanguageName = languageItem.languageNameTranslatedInCurrentAppLanguage.value.lowercased()
                
                return lowercasedLanguageName.contains(lowercasedSearchText)
            }
        }
    }
}
