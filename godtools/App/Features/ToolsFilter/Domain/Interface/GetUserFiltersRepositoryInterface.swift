//
//  GetUserFiltersRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetUserFiltersRepositoryInterface {
    
    func getUserCategoryFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<String?, Never>   // TODO: - return CategoryFilterDomainModel? instead of String? here
    func getUserLanguageFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageFilterDomainModel?, Never>
}
