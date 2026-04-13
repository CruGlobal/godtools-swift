//
//  ToolSettingsToolLanguagesListStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolSettingsToolLanguagesListStringsDomainModel: Sendable {
    
    let deleteParallelLanguageActionTitle: String
    
    static var emptyValue: ToolSettingsToolLanguagesListStringsDomainModel {
        return ToolSettingsToolLanguagesListStringsDomainModel(deleteParallelLanguageActionTitle: "")
    }
}
