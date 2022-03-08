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
    
    required init(resource: ResourceModel, primaryLanguage: LanguageModel, languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest], pageViewFactories: MobileContentRendererPageViewFactories, translationsFileCache: TranslationsFileCache) {
        
        let sharedState: State = State()
        
        var pageRenderers: [MobileContentPageRenderer] = Array()
        
        for languageTranslationManifest in languageTranslationManifests {

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

