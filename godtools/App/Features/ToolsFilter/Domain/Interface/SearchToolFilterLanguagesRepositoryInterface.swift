//
//  SearchToolFilterLanguagesRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 3/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol SearchToolFilterLanguagesRepositoryInterface {
    
    func getSearchResultsPublisher(for searchText: String, in toolFilterLanguages: [LanguageFilterDomainModel]) -> AnyPublisher<[LanguageFilterDomainModel], Never>
}
