//
//  MobileContentRendererPageModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentRendererPageModel {
    
    let pageModel: PageModelType
    let page: Int
    let isLastPage: Bool
    let pageColors: MobileContentPageColors
    let safeArea: UIEdgeInsets
    let manifest: MobileContentManifestType
    let resourcesCache: ManifestResourcesCacheType
    let resource: ResourceModel
    let language: LanguageModel
    let pageViewFactories: MobileContentRendererPageViewFactories
    let primaryRendererLanguage: LanguageModel
    let rendererState: State
    
    private weak var weakWindow: UIViewController?
    
    required init(pageModel: PageModelType, page: Int, isLastPage: Bool, window: UIViewController, safeArea: UIEdgeInsets, manifest: MobileContentManifestType, resourcesCache: ManifestResourcesCacheType, resource: ResourceModel, language: LanguageModel, pageViewFactories: MobileContentRendererPageViewFactories, primaryRendererLanguage: LanguageModel, rendererState: State) {
        
        self.pageModel = pageModel
        self.page = page
        self.isLastPage = isLastPage
        self.pageColors = MobileContentPageColors(pageModel: pageModel, manifest: manifest)
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
