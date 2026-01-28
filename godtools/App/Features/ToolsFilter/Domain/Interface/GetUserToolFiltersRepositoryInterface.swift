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
    
    @MainActor func getUserCategoryFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterCategoryDomainModel, Never>
    @MainActor func getUserLanguageFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterLanguageDomainModel, Never>
}
