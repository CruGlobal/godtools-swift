//
//  GetSettingsPrimaryLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSettingsPrimaryLanguageUseCase {
    
    private let languageSettingsRepository: LanguageSettingsRepository
    
    init(languageSettingsRepository: LanguageSettingsRepository) {
        
        self.languageSettingsRepository = languageSettingsRepository
    }
    
    func getPrimaryLanguage() -> LanguageModel? {
        
        return nil
    }
}
