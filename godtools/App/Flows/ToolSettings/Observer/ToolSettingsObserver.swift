//
//  ToolSettingsObserver.swift
//  godtools
//
//  Created by Levi Eggert on 2/22/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ToolSettingsObserver: ObservableObject {
    
    @Published var languages: ToolSettingsLanguages
    @Published var trainingTipsEnabled: Bool
    
    let toolId: String
    let pageNumber: Int
    let resourceType: ResourceType
    
    init(toolId: String, languages: ToolSettingsLanguages, pageNumber: Int, trainingTipsEnabled: Bool, resourceType: ResourceType) {
        
        self.toolId = toolId
        self.languages = languages
        self.pageNumber = pageNumber
        self.trainingTipsEnabled = trainingTipsEnabled
        self.resourceType = resourceType
    }
}

extension ToolSettingsObserver {
    var isRemoteShareable: Bool {
        return self is RemoteShareable
    }
    
    var isLinkShareable: Bool {
        return self is LinkShareable
    }
}
