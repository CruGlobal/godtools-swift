//
//  SearchAppLanguageInAppLanguagesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class SearchAppLanguageInAppLanguagesListUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }
    
    func execute(searchText: String, appLanguagesList: [AppLanguageListItemDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: appLanguagesList)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
