//
//  GetToolFilterCategoriesRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 2/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolFilterCategoriesRepositoryInterface {
    
    func getToolFilterCategoriesPublisher(translatedInAppLanguage: AppLanguageDomainModel, filteredByLanguageId: String?) -> AnyPublisher<[CategoryFilterDomainModel], Never>
    func getAnyCategoryFilterDomainModel(translatedInAppLanguage: AppLanguageDomainModel) -> CategoryFilterDomainModel
}
