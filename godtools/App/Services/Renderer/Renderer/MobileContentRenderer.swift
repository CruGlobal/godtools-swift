//
//  MobileContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentRenderer {
            
    private let sharedState: State
    
    let navigation: MobileContentRendererNavigation
    let resource: ResourceModel
    let primaryLanguage: LanguageModel
    let pageRenderers: [MobileContentPageRenderer]
    
    required init(navigation: MobileContentRendererNavigation, toolTranslations: ToolTranslations, pageViewFactories: MobileContentRendererPageViewFactories, manifestResourcesCache: ManifestResourcesCache) {
        
        let sharedState: State = State()
        let resource: ResourceModel = toolTranslations.tool
        let primaryLanguage: LanguageModel = toolTranslations.languageTranslationManifests[0].language
        
        var pageRenderers: [MobileContentPageRenderer] = Array()
        
        for languageTranslationManifest in toolTranslations.languageTranslationManifests {

            let pageRenderer = MobileContentPageRenderer(
                sharedState: sharedState,
                resource: resource,
                primaryLanguage: primaryLanguage,
                languageTranslationManifest: languageTranslationManifest,
                pageViewFactories: pageViewFactories,
                navigation: navigation,
                manifestResourcesCache: manifestResourcesCache
            )
            
            pageRenderers.append(pageRenderer)
        }
        
        self.sharedState = sharedState
        self.navigation = navigation
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.pageRenderers = pageRenderers
    }
}

