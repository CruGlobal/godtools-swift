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
    let numberOfPages: Int
    let safeArea: UIEdgeInsets
    let manifest: MobileContentXmlManifest
    let resourcesCache: ManifestResourcesCache
    let language: LanguageModel
    
    private weak var weakWindow: UIViewController?
    
    required init(pageNode: PageNode, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, manifest: MobileContentXmlManifest, resourcesCache: ManifestResourcesCache, language: LanguageModel) {
        
        self.pageNode = pageNode
        self.page = page
        self.numberOfPages = numberOfPages
        self.weakWindow = window
        self.safeArea = safeArea
        self.manifest = manifest
        self.resourcesCache = resourcesCache
        self.language = language
    }
    
    var window: UIViewController {
        
        guard let window = self.weakWindow else {
            assertionFailure("Window should not be nil.")
            return UIViewController()
        }
        
        return window
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        
        switch language.languageDirection {
            case .leftToRight:
                return .forceLeftToRight
            case .rightToLeft:
                return .forceRightToLeft
        }
    }
    
    var isLastPage: Bool {
        return page == numberOfPages - 1
    }
}
