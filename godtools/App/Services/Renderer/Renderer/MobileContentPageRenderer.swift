//
//  MobileContentPageRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentPageRenderer {
    
    private let navigation: MobileContentRendererNavigation
    
    let sharedState: State
    let resource: ResourceModel
    let primaryLanguage: LanguageDomainModel
    let manifest: Manifest
    let language: LanguageDomainModel
    let translation: TranslationModel
    let manifestResourcesCache: MobileContentRendererManifestResourcesCache
    let viewRenderer: MobileContentViewRenderer
    let pagesViewDataCache: MobileContentPageRendererPagesViewDataCache = MobileContentPageRendererPagesViewDataCache()
    
    init(sharedState: State, resource: ResourceModel, primaryLanguage: LanguageDomainModel, languageTranslationManifest: MobileContentRendererLanguageTranslationManifest, pageViewFactories: MobileContentRendererPageViewFactories, navigation: MobileContentRendererNavigation, manifestResourcesCache: MobileContentRendererManifestResourcesCache) {
        
        self.sharedState = sharedState
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.manifest = languageTranslationManifest.manifest
        self.language = languageTranslationManifest.language
        self.translation = languageTranslationManifest.translation
        self.manifestResourcesCache = manifestResourcesCache
        self.viewRenderer = MobileContentViewRenderer(pageViewFactories: pageViewFactories)
        self.navigation = navigation
    }
    
    func getAllPageModels() -> [Page] {
        return manifest.pages
    }
    
    func getPageModel(page: Int) -> Page? {
        
        let pageModels: [Page] = getAllPageModels()
        
        guard page >= 0 && page < pageModels.count else {
            return nil
        }
        return pageModels[page]
    }
    
    func getVisiblePageModels() -> [Page] {
        let pageModels: [Page] = getAllPageModels()
        return pageModels.filter({!$0.isHidden})
    }
    
    func getPageForListenerEvents(eventIds: [EventId]) -> Int? {
                
        let pageModels: [Page] = getAllPageModels()
        
        for pageIndex in 0 ..< pageModels.count {
            
            let pageModel: Page = pageModels[pageIndex]
            
            for listener in pageModel.listeners {
               
                if eventIds.contains(listener) {
                    return pageIndex
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Page Renderering
    
    private func getRenderedPageContext(pageModel: Page, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, manifest: Manifest, manifestResourcesCache: MobileContentRendererManifestResourcesCache, resource: ResourceModel, language: LanguageDomainModel, translation: TranslationModel, viewRenderer: MobileContentViewRenderer, primaryLanguage: LanguageDomainModel, sharedState: State, trainingTipsEnabled: Bool) -> MobileContentRenderedPageContext {
        
        let renderedPageContext = MobileContentRenderedPageContext(
            pageModel: pageModel,
            page: page,
            isLastPage: page == numberOfPages - 1,
            window: window,
            safeArea: safeArea,
            manifest: manifest,
            resourcesCache: manifestResourcesCache,
            resource: resource,
            language: language,
            translation: translation,
            viewRenderer: viewRenderer,
            navigation: navigation,
            primaryRendererLanguage: primaryLanguage,
            rendererState: sharedState,
            trainingTipsEnabled: trainingTipsEnabled,
            pageViewDataCache: pagesViewDataCache.getPageViewDataCache(page: pageModel)
        )
        
        return renderedPageContext
    }
    
    func renderPageModel(pageModel: Page, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, trainingTipsEnabled: Bool) -> Result<MobileContentView, Error> {
        
        let renderedPageContext: MobileContentRenderedPageContext = getRenderedPageContext(
            pageModel: pageModel,
            page: page,
            numberOfPages: numberOfPages,
            window: window,
            safeArea: safeArea,
            manifest: manifest,
            manifestResourcesCache: manifestResourcesCache,
            resource: resource,
            language: language,
            translation: translation,
            viewRenderer: viewRenderer,
            primaryLanguage: primaryLanguage,
            sharedState: sharedState,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        guard let renderableView = viewRenderer.recurseAndRender(renderableModel: pageModel, renderableModelParent: nil, renderedPageContext: renderedPageContext) else {
            return .failure(NSError.errorWithDescription(description: "Failed to render page."))
        }
                
        return .success(renderableView)
    }
}
