//
//  SearchAppLanguageInAppLanguagesListRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 2/22/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol SearchAppLanguageInAppLanguagesListRepositoryInterface {
    
    func getSearchResultsPublisher(searchText: String, appLanguagesList: [AppLanguageListItemDomainModel]) -> AnyPublisher<[AppLanguageListItemDomainModel], Never>
}
