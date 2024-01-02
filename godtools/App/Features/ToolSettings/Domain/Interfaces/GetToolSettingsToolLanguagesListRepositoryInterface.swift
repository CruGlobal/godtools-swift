//
//  GetToolSettingsToolLanguagesListRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolSettingsToolLanguagesListRepositoryInterface {
    
    // TODO: Eventually ResourceModel needs to be replaced by ToolDomainModel. ~Levi
    func getToolLanguagesPublisher(listType: ToolSettingsToolLanguagesListTypeDomainModel, primaryLanguage: ToolSettingsToolLanguageDomainModel?, parallelLanguage: ToolSettingsToolLanguageDomainModel?, tool: ResourceModel, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolSettingsToolLanguageDomainModel], Never>
}
