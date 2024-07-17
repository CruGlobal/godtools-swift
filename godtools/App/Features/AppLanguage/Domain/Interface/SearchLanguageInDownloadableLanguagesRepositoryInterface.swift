//
//  SearchLanguageInDownloadableLanguagesRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 2/23/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol SearchLanguageInDownloadableLanguagesRepositoryInterface {
    
    func getSearchResultsPublisher(searchText: String, downloadableLanguagesList: [DownloadableLanguageListItemDomainModel]) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never>
}
