//
//  SearchToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class SearchToolFilterLanguagesUseCase {
    
    private let stringSearcher: StringSearcher
    
    init(stringSearcher: StringSearcher) {
        
        self.stringSearcher = stringSearcher
    }
    
    func execute(for searchText: String, in toolFilterLanguages: [ToolFilterLanguageDomainModel]) -> AnyPublisher<[ToolFilterLanguageDomainModel], Never> {
        
        let searchResults = stringSearcher.search(for: searchText, in: toolFilterLanguages)
        
        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
