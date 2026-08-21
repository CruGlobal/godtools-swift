//
//  SearchAppLanguageInAppLanguagesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SearchAppLanguageInAppLanguagesListUseCase: Sendable {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func execute(
        searchText: String,
        appLanguagesList: [AppLanguageListItemDomainModel]
    ) -> [AppLanguageListItemDomainModel] {
        
        return stringSearcher.search(for: searchText, in: appLanguagesList)
    }
}
