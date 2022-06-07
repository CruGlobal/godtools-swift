//
//  ToolSettingsToolType.swift
//  godtools
//
//  Created by Levi Eggert on 5/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol ToolSettingsToolType {
    
    func setTrainingTipsEnabled(enabled: Bool)
    func setPrimaryLanguage(languageId: String)
    func setParallelLanguage(languageId: String)
    func clearParallelLanguage()
    func swapLanguages(fromLanguageId: String, toLanguageId: String)
}
