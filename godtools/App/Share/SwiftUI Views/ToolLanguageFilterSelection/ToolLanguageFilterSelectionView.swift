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
    private let selectedLanguageId: String?
    private let languageTapped: ((_ languageId: String) -> Void)?
    
    @Binding private var searchText: String
    
    init(
        searchText: Binding<String>,
        searchBarStrings: SearchBarStringsDomainModel,
        languages: [Language],
        selectedLanguageId: String?,
        languageTapped: ((_ languageId: String) -> Void)?
    ) {
        
        self._searchText = searchText
        self.searchBarStrings = searchBarStrings
        self.languages = languages
        self.selectedLanguageId = selectedLanguageId
        self.languageTapped = languageTapped
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
                        
            SearchBarView(searchText: $searchText, strings: searchBarStrings)
            
            List {
                ForEach(languages) { language in
                    
                    Button {
                        
                        languageTapped?(language.id)
                        
                    } label: {
                        
                        ToolLanguageFilterItemView(
                            language: language,
                            isSelected: selectedLanguageId == language.id
                        )
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}
