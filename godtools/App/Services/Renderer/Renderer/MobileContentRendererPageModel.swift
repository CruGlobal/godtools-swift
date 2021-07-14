//
//  MobileContentRendererPageModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentRendererPageModel {
    
    let pageNode: PageNode
    let page: Int
    let isLastPage: Bool
    let pageColors: MobileContentPageColors
    let safeArea: UIEdgeInsets
    let manifest: MobileContentXmlManifest
    let resourcesCache: ManifestResourcesCache
    let resource: ResourceModel
    let language: LanguageModel
    let pageViewFactories: [MobileContentPageViewFactoryType]
    let primaryRendererLanguage: LanguageModel
    
    private weak var weakWindow: UIViewController?
    
    required init(pageNode: PageNode, page: Int, isLastPage: Bool, window: UIViewController, safeArea: UIEdgeInsets, manifest: MobileContentXmlManifest, resourcesCache: ManifestResourcesCache, resource: ResourceModel, language: LanguageModel, pageViewFactories: [MobileContentPageViewFactoryType], primaryRendererLanguage: LanguageModel) {
        
        self.pageNode = pageNode
        self.page = page
        self.isLastPage = isLastPage
        self.pageColors = MobileContentPageColors(pageNode: pageNode, manifest: manifest)
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
