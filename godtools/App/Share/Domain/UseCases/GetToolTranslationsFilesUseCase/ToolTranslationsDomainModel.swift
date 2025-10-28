//
//  ToolTranslationsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolTranslationsDomainModel {
    
    let tool: ResourceDataModel
    let languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest]
}
