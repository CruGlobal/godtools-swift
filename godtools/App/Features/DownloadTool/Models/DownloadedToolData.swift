//
//  DownloadedToolData.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DownloadedToolData {
    
    let resource: ResourceModel
    let languageTranslations: [ToolTranslation]
    
    required init(resource: ResourceModel, languageTranslations: [ToolTranslation]) {
        
        self.resource = resource
        self.languageTranslations = languageTranslations
    }
}
