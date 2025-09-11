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
    let parentPageParams: MobileContentParentPageParams?
    let safeArea: UIEdgeInsets
    let manifest: Manifest
    let resourcesCache: MobileContentRendererManifestResourcesCache
    let resource: ResourceModel
    let appLanguage: AppLanguageDomainModel
    let language: LanguageDataModel
    let translation: TranslationModel
    let viewRenderer: MobileContentViewRenderer
    let navigation: MobileContentRendererNavigation
    let primaryLanguageLayoutDirection: ApplicationLayoutDirection
    let rendererLanguages: MobileContentRendererLanguages
    let rendererState: State
    let trainingTipsEnabled: Bool
    let pageViewDataCache: MobileContentPageViewDataCache
    let userInfo: [String: Any]?
    
    private weak var weakWindow: UIViewController?
    
    init(pageModel: Page, page: Int, isLastPage: Bool, parentPageParams: MobileContentParentPageParams?, window: UIViewController, safeArea: UIEdgeInsets, manifest: Manifest, resourcesCache: MobileContentRendererManifestResourcesCache, resource: ResourceModel, appLanguage: AppLanguageDomainModel, language: LanguageDataModel, translation: TranslationModel, viewRenderer: MobileContentViewRenderer, navigation: MobileContentRendererNavigation, rendererLanguages: MobileContentRendererLanguages, rendererState: State, trainingTipsEnabled: Bool, pageViewDataCache: MobileContentPageViewDataCache, userInfo: [String: Any]?) {
        
        self.pageModel = pageModel
        self.page = page
        self.isLastPage = isLastPage
        self.parentPageParams = parentPageParams
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
        self.primaryLanguageLayoutDirection = rendererLanguages.primaryLanguage.direction == .rightToLeft ? .rightToLeft : .leftToRight
        self.rendererLanguages = rendererLanguages
        self.rendererState = rendererState
        self.trainingTipsEnabled = trainingTipsEnabled
        self.pageViewDataCache = pageViewDataCache
        self.userInfo = userInfo
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
    
    var primaryRendererLanguage: LanguageDataModel {
        return rendererLanguages.primaryLanguage
    }
}
