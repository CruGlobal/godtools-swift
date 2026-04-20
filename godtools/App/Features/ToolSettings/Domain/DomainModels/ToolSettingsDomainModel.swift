//
//  ToolSettingsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolSettingsDomainModel: Sendable {
    
    let hasTips: Bool
    let primaryLanguage: ToolSettingsToolLanguageDomainModel?
    let parallelLanguage: ToolSettingsToolLanguageDomainModel?
    
    static var emptyValue: ToolSettingsDomainModel {
        return ToolSettingsDomainModel(hasTips: false, primaryLanguage: nil, parallelLanguage: nil)
    }
}
