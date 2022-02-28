//
//  MobileContentRendererPageModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

// TODO: Should I rename this class to MobileContentRenderedPageModel? ~Levi
class MobileContentRendererPageModel {
    
    let pageModel: Page
    let page: Int
    let isLastPage: Bool
    let safeArea: UIEdgeInsets
    let manifest: Manifest
    let resourcesCache: ManifestResourcesCache
    let resource: ResourceModel
    let language: LanguageModel
    let pageViewFactories: MobileContentRendererPageViewFactories
    let primaryRendererLanguage: LanguageModel
    let rendererState: State
    
    private weak var weakWindow: UIViewController?
    
    required init(pageModel: Page, page: Int, isLastPage: Bool, window: UIViewController, safeArea: UIEdgeInsets, manifest: Manifest, resourcesCache: ManifestResourcesCache, resource: ResourceModel, language: LanguageModel, pageViewFactories: MobileContentRendererPageViewFactories, primaryRendererLanguage: LanguageModel, rendererState: State) {
        
        self.pageModel = pageModel
        self.page = page
        self.isLastPage = isLastPage
        self.weakWindow = window
        self.safeArea = safeArea
        self.manifest = manifest
        self.resourcesCache = resourcesCache
        self.resource = resource
        self.language = language
        self.pageViewFactories = pageViewFactories
        self.primaryRendererLanguage = primaryRendererLanguage
        self.rendererState = rendererState
    }
    
    var window: UIViewController {
        
        guard let window = self.weakWindow else {
            assertionFailure("Window should not be nil.")
            return UIViewController()
        }
        
        return window
    }
}
