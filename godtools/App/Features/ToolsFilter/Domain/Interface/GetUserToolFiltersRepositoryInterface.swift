//
//  GetUserToolFiltersRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetUserToolFiltersRepositoryInterface {
    
    func getUserCategoryFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<CategoryFilterDomainModel, Never>
    func getUserLanguageFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageFilterDomainModel, Never>
}
