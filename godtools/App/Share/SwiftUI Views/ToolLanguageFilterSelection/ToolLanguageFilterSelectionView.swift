//
//  ToolLanguageFilterSelectionView.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ToolLanguageFilterSelectionView<Language: ToolLanguageFilterItemDomainModelInterface>: View {
    
    private let searchBarStrings: SearchBarStringsDomainModel
    private let languages: [Language]
    private let selectedLanguage: Language?
    private let languageTapped: ((_ language: Language) -> Void)?
    
    @Binding private var searchText: String
    
    init(
        searchText: Binding<String>,
        searchBarStrings: SearchBarStringsDomainModel,
        languages: [Language],
        selectedLanguage: Language?,
        languageTapped: ((_ language: Language) -> Void)?
    ) {
        
        self._searchText = searchText
        self.searchBarStrings = searchBarStrings
        self.languages = languages
        self.selectedLanguage = selectedLanguage
        self.languageTapped = languageTapped
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
                        
            SearchBarView(searchText: $searchText, strings: searchBarStrings)
            
            List {
                ForEach(languages) { language in
                    
                    Button {
                        
                        languageTapped?(language)
                        
                    } label: {
                        
                        ToolLanguageFilterItemView(
                            language: language,
                            isSelected: selectedLanguage?.id == language.id
                        )
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}
