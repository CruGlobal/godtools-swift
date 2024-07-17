//
//  GetDownloadedLanguagesListRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetDownloadedLanguagesListRepositoryInterface {
    
    func getDownloadedLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadedLanguageListItemDomainModel], Never>
}
