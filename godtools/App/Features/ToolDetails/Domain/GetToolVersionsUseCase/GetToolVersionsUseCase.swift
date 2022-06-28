//
//  GetToolVersionsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolVersionsUseCase {
    
    private let resourcesCache: ResourcesCache
    private let languageSettingsService: LanguageSettingsService
    private let getToolLanguagesUseCase: GetToolLanguagesUseCase
    
    init(resourcesCache: ResourcesCache, languageSettingsService: LanguageSettingsService, getToolLanguagesUseCase: GetToolLanguagesUseCase) {
        
        self.resourcesCache = resourcesCache
        self.languageSettingsService = languageSettingsService
        self.getToolLanguagesUseCase = getToolLanguagesUseCase
    }
    
    func getToolVersions(resourceId: String) -> [ToolVersion] {
        
        let variants: [ResourceModel] = resourcesCache.getResourceVariants(resourceId: resourceId)
        
        guard !variants.isEmpty else {
            return []
        }
        
        return variants.map({
            getToolVersion(resource: $0)
        })
    }
    
    private func getToolVersion(resource: ResourceModel) -> ToolVersion {
        
        return ToolVersion(
            id: UUID().uuidString,
            bannerImageId: resource.attrBanner,
            name: resource.name,
            description: resource.resourceDescription,
            languagesDetails: ""
        )
    }
}
