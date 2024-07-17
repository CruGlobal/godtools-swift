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
    let resourcesCache: MobileContentRendererManifestResourcesCache
    let resource: ResourceModel
    let appLanguage: AppLanguageDomainModel
    let language: LanguageDomainModel
    let translation: TranslationModel
    let viewRenderer: MobileContentViewRenderer
    let navigation: MobileContentRendererNavigation
    let primaryRendererLanguage: LanguageDomainModel
    let primaryLanguageLayoutDirection: ApplicationLayoutDirection
    let rendererState: State
    let trainingTipsEnabled: Bool
    let pageViewDataCache: MobileContentPageViewDataCache
    
    private weak var weakWindow: UIViewController?
    
    init(pageModel: Page, page: Int, isLastPage: Bool, window: UIViewController, safeArea: UIEdgeInsets, manifest: Manifest, resourcesCache: MobileContentRendererManifestResourcesCache, resource: ResourceModel, appLanguage: AppLanguageDomainModel, language: LanguageDomainModel, translation: TranslationModel, viewRenderer: MobileContentViewRenderer, navigation: MobileContentRendererNavigation, primaryRendererLanguage: LanguageDomainModel, rendererState: State, trainingTipsEnabled: Bool, pageViewDataCache: MobileContentPageViewDataCache) {
        
        self.pageModel = pageModel
        self.page = page
        self.isLastPage = isLastPage
        self.weakWindow = window
        self.safeArea = safeArea
        self.manifest = manifest
        self.resourcesCache = resourcesCache
        self.resource = resource
        self.appLanguage = appLanguage
        self.language = language
        self.translation = translation
        self.viewRenderer = viewRenderer
        self.navigation = navigation
        self.primaryRendererLanguage = primaryRendererLanguage
        self.primaryLanguageLayoutDirection = primaryRendererLanguage.direction == .rightToLeft ? .rightToLeft : .leftToRight
        self.rendererState = rendererState
        self.trainingTipsEnabled = trainingTipsEnabled
        self.pageViewDataCache = pageViewDataCache
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    var window: UIViewController {
        
        guard let window = self.weakWindow else {
            assertionFailure("Window should not be nil.")
            return UIViewController()
        }
        
        return window
    }
}
