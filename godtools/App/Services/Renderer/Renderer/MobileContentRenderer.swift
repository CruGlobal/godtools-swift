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
    
    let resource: ResourceModel
    let primaryLanguage: LanguageModel
    let pageRenderers: [MobileContentPageRenderer]
    
    required init(toolTranslations: ToolTranslations, pageViewFactories: MobileContentRendererPageViewFactories, translationsFileCache: TranslationsFileCache) {
        
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
                translationsFileCache: translationsFileCache
            )
            
            pageRenderers.append(pageRenderer)
        }
        
        self.sharedState = sharedState
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.pageRenderers = pageRenderers
    }
}

