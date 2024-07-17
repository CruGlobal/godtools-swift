//
//  SearchToolFilterCategoriesRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 3/6/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol SearchToolFilterCategoriesRepositoryInterface {
    
    func getSearchResultsPublisher(for searchText: String, in toolFilterCategories: [CategoryFilterDomainModel]) -> AnyPublisher<[CategoryFilterDomainModel], Never>
}
