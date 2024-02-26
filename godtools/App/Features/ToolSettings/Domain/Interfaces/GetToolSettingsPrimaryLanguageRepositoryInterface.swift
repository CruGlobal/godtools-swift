//
//  GetToolSettingsPrimaryLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolSettingsPrimaryLanguageRepositoryInterface {
 
    func getLanguagePublisher(primaryLanguageId: String, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never>
}
