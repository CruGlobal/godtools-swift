//
//  MobileContentRenderedPageContext.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentRenderedPageContext {
    
    let pageModel: Page
    let page: Int
    let isLastPage: Bool
    let safeArea: UIEdgeInsets
    let manifest: Manifest
    let resourcesCache: ManifestResourcesCache
    let resource: ResourceModel
    let language: LanguageDomainModel
    let translation: TranslationModel
    let pageViewFactories: MobileContentRendererPageViewFactories
    let navigation: MobileContentRendererNavigation
    let primaryRendererLanguage: LanguageDomainModel
    let rendererState: State
    let trainingTipsEnabled: Bool
    
    private weak var weakWindow: UIViewController?
    
    required init(pageModel: Page, page: Int, isLastPage: Bool, window: UIViewController, safeArea: UIEdgeInsets, manifest: Manifest, resourcesCache: ManifestResourcesCache, resource: ResourceModel, language: LanguageDomainModel, translation: TranslationModel, pageViewFactories: MobileContentRendererPageViewFactories, navigation: MobileContentRendererNavigation, primaryRendererLanguage: LanguageDomainModel, rendererState: State, trainingTipsEnabled: Bool) {
        
        self.pageModel = pageModel
        self.page = page
        self.isLastPage = isLastPage
        self.weakWindow = window
        self.safeArea = safeArea
        self.manifest = manifest
        self.resourcesCache = resourcesCache
        self.resource = resource
        self.language = language
        self.translation = translation
        self.pageViewFactories = pageViewFactories
        self.navigation = navigation
        self.primaryRendererLanguage = primaryRendererLanguage
        self.rendererState = rendererState
        self.trainingTipsEnabled = trainingTipsEnabled
    }
    
    var window: UIViewController {
        
        guard let window = self.weakWindow else {
            assertionFailure("Window should not be nil.")
            return UIViewController()
        }
        
        return window
    }
}
