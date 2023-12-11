//
//  ToolSettingsToolLanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolSettingsToolLanguageDomainModel {
    
    let dataModelId: String
    let languageName: String
}

extension ToolSettingsToolLanguageDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
