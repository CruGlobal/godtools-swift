//
//  ToolSettingsToolLanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolSettingsToolLanguageDomainModel: Sendable {
    
    let dataModelId: String
    let languageName: String
}

extension ToolSettingsToolLanguageDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}

extension ToolSettingsToolLanguageDomainModel: Equatable {
    static func == (this: ToolSettingsToolLanguageDomainModel, that: ToolSettingsToolLanguageDomainModel) -> Bool {
        return this.dataModelId == that.dataModelId
    }
}
