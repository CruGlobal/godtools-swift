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
    private let pageViewFactories: MobileContentRendererPageViewFactories
    private let manifestResourcesCache: MobileContentRendererManifestResourcesCache
    
    let navigation: MobileContentRendererNavigation
    let resource: ResourceModel
    let appLanguage: AppLanguageDomainModel
    let primaryLanguage: LanguageModel
    let pageRenderers: [MobileContentPageRenderer]
    
    init(navigation: MobileContentRendererNavigation, appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel, pageViewFactories: MobileContentRendererPageViewFactories, manifestResourcesCache: MobileContentRendererManifestResourcesCache) {
        
        let sharedState: State = State()
        let resource: ResourceModel = toolTranslations.tool
        let primaryLanguage: LanguageModel = toolTranslations.languageTranslationManifests[0].language
        
        var pageRenderers: [MobileContentPageRenderer] = Array()
        
        for languageTranslationManifest in toolTranslations.languageTranslationManifests {

            let pageRenderer = MobileContentPageRenderer(
                sharedState: sharedState,
                resource: resource,
                appLanguage: appLanguage,
                primaryLanguage: primaryLanguage,
                languageTranslationManifest: languageTranslationManifest,
                pageViewFactories: pageViewFactories,
                navigation: navigation,
                manifestResourcesCache: manifestResourcesCache
            )
            
            pageRenderers.append(pageRenderer)
        }
        
        self.sharedState = sharedState
        self.pageViewFactories = pageViewFactories
        self.manifestResourcesCache = manifestResourcesCache
        self.navigation = navigation
        self.resource = resource
        self.appLanguage = appLanguage
        self.primaryLanguage = primaryLanguage
        self.pageRenderers = pageRenderers
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func copy(toolTranslations: ToolTranslationsDomainModel) -> MobileContentRenderer {
        
        return MobileContentRenderer(
            navigation: navigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations,
            pageViewFactories: pageViewFactories,
            manifestResourcesCache: manifestResourcesCache
        )
    }
}
