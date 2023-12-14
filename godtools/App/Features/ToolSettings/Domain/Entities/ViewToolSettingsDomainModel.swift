//
//  ViewToolSettingsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ViewToolSettingsDomainModel {
    
    let interfaceStrings: ToolSettingsInterfaceStringsDomainModel
    let primaryLanguage: ToolSettingsToolLanguageDomainModel?
    let parallelLanguage: ToolSettingsToolLanguageDomainModel?
}
