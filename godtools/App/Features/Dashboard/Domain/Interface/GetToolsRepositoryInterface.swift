//
//  GetToolsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolsRepositoryInterface {
    
    func getToolsPublisher(translatedInAppLanguage: AppLanguageDomainModel, languageForAvailabilityText: LanguageDomainModel?, filterToolsByCategory: ToolFilterCategoryDomainModelInterface?, filterToolsByLanguage: ToolFilterLanguageDomainModelInterface?) -> AnyPublisher<[ToolListItemDomainModel], Never>
}
