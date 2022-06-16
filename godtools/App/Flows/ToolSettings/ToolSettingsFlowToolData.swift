//
//  ToolSettingsFlowToolData.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//
import Foundation
import GodToolsToolParser

class ToolSettingsFlowToolData {
    
    let renderer: MobileContentRenderer
    let manifestResourcesCache: ManifestResourcesCache
    let tractRemoteSharePublisher: TractRemoteSharePublisher
    let resource: ResourceModel
    let selectedLanguage: LanguageModel
    let primaryLanguage: LanguageModel
    let parallelLanguage: LanguageModel?
    let shareables: [Shareable]
    let pageNumber: Int
    let trainingTipsEnabled: Bool
    
    required init(renderer: MobileContentRenderer, manifestResourcesCache: ManifestResourcesCache, tractRemoteSharePublisher: TractRemoteSharePublisher, resource: ResourceModel, selectedLanguage: LanguageModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, shareables: [Shareable], pageNumber: Int, trainingTipsEnabled: Bool) {
        
        self.renderer = renderer
        self.manifestResourcesCache = manifestResourcesCache
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.resource = resource
        self.selectedLanguage = selectedLanguage
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage
        self.shareables = shareables
        self.pageNumber = pageNumber
        self.trainingTipsEnabled = trainingTipsEnabled
    }
}
