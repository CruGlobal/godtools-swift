//
//  GetToolFilterLanguagesRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 2/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolFilterLanguagesRepositoryInterface {
    
    func getToolFilterLanguagesPublisher(translatedInAppLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> AnyPublisher<[LanguageFilterDomainModel], Never>
}
