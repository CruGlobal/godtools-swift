//
//  ToolVersionDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolVersionDomainModel {
    
    let analyticsToolAbbreviation: String
    let bannerImageId: String
    let dataModelId: String
    let description: String
    let name: String
    let numberOfLanguages: String
    let toolLanguageName: String?
    let toolLanguageNameIsSupported: Bool
    let toolParallelLanguageName: String?
    let toolParallelLanguageNameIsSupported: Bool?
}

extension ToolVersionDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
