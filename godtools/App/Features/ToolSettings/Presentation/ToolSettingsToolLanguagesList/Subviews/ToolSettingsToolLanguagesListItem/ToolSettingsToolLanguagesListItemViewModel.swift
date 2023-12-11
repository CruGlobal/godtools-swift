//
//  ToolSettingsToolLanguagesListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolSettingsToolLanguagesListItemViewModel: ObservableObject {
    
    let name: String
    
    init(domainModel: ToolSettingsToolLanguageDomainModel) {
        
        name = domainModel.languageName
    }
}
