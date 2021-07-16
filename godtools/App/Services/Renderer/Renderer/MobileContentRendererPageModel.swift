//
//  MobileContentRendererPageModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentRendererPageModel {
    
    let pageModel: PageModelType
    let page: Int
    let isLastPage: Bool
    let pageColors: MobileContentPageColors
    let safeArea: UIEdgeInsets
    let manifest: MobileContentManifestType
    let resourcesCache: ManifestResourcesCache
    let resource: ResourceModel
    let language: LanguageModel
    let pageViewFactories: [MobileContentPageViewFactoryType]
    let primaryRendererLanguage: LanguageModel
    
    private weak var weakWindow: UIViewController?
    
    required init(pageModel: PageModelType, page: Int, isLastPage: Bool, window: UIViewController, safeArea: UIEdgeInsets, manifest: MobileContentManifestType, resourcesCache: ManifestResourcesCache, resource: ResourceModel, language: LanguageModel, pageViewFactories: [MobileContentPageViewFactoryType], primaryRendererLanguage: LanguageModel) {
        
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
    }
    
    var window: UIViewController {
        
        guard let window = self.weakWindow else {
            assertionFailure("Window should not be nil.")
            return UIViewController()
        }
        
        return window
    }
}
