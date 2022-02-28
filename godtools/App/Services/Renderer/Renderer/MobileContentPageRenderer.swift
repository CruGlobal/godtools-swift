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
    
    private let sharedState: State
    private let primaryLanguage: LanguageModel
    private let manifestResourcesCache: ManifestResourcesCache
    private let pageViewFactories: MobileContentRendererPageViewFactories
    
    let resource: ResourceModel
    let manifest: Manifest
    let language: LanguageModel
    
    required init(sharedState: State, resource: ResourceModel, primaryLanguage: LanguageModel, languageTranslationManifest: MobileContentRendererLanguageTranslationManifest, pageViewFactories: MobileContentRendererPageViewFactories, translationsFileCache: TranslationsFileCache) {
        
        self.sharedState = sharedState
        self.resource = resource
        self.primaryLanguage = primaryLanguage
        self.manifest = languageTranslationManifest.manifest
        self.language = languageTranslationManifest.language
        self.manifestResourcesCache = ManifestResourcesCache(manifest: languageTranslationManifest.manifest, translationsFileCache: translationsFileCache)
        self.pageViewFactories = pageViewFactories
    }
    
    func getRenderablePageModels() -> [Page] {
        return manifest.pages
    }
    
    func getPageModel(page: Int) -> Page? {
        
        let pageModels: [Page] = getRenderablePageModels()
        
        guard page >= 0 && page < pageModels.count else {
            return nil
        }
        return pageModels[page]
    }
    
    func getVisibleRenderablePageModels() -> [Page] {
        let pageModels: [Page] = getRenderablePageModels()
        return pageModels.filter({!$0.isHidden})
    }
    
    func getPageForListenerEvents(eventIds: [EventId]) -> Int? {
                
        let pageModels: [Page] = getRenderablePageModels()
        
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
    
    private func getRendererPageModel(pageModel: Page, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets) -> MobileContentRendererPageModel {
        
        let rendererPageModel = MobileContentRendererPageModel(
            pageModel: pageModel,
            page: page,
            isLastPage: page == numberOfPages - 1,
            window: window,
            safeArea: safeArea,
            manifest: manifest,
            resourcesCache: manifestResourcesCache,
            resource: resource,
            language: language,
            pageViewFactories: pageViewFactories,
            primaryRendererLanguage: primaryLanguage,
            rendererState: sharedState
        )
        
        return rendererPageModel
    }
    
    func renderPageModel(pageModel: Page, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets) -> Result<MobileContentView, Error> {
        
        let rendererPageModel: MobileContentRendererPageModel = getRendererPageModel(
            pageModel: pageModel,
            page: page,
            numberOfPages: numberOfPages,
            window: window,
            safeArea: safeArea
        )
        
        guard let renderableView = recurseAndRender(renderableModel: pageModel, renderableModelParent: nil, rendererPageModel: rendererPageModel) else {
            return .failure(NSError.errorWithDescription(description: "Failed to render page."))
        }
                
        return .success(renderableView)
    }
    
    private func recurseAndRender(renderableModel: AnyObject, renderableModelParent: AnyObject?, rendererPageModel: MobileContentRendererPageModel) -> MobileContentView? {
                   
        let mobileContentView: MobileContentView? = pageViewFactories.viewForRenderableModel(
            renderableModel: renderableModel,
            renderableModelParent: renderableModelParent,
            rendererPageModel: rendererPageModel
        )
                
        let childModels: [AnyObject]
        
        if let renderableModel = renderableModel as? MobileContentRenderableModel {
            childModels = renderableModel.getRenderableChildModels()
        }
        else {
            childModels = Array()
        }
                        
        for childModel in childModels {
            
            let childMobileContentView: MobileContentView? = recurseAndRender(
                renderableModel: childModel,
                renderableModelParent: renderableModel,
                rendererPageModel: rendererPageModel
            )
            
            if let childMobileContentView = childMobileContentView, let mobileContentView = mobileContentView {
                mobileContentView.renderChild(childView: childMobileContentView)
            }
        }
        
        mobileContentView?.finishedRenderingChildren()
        
        return mobileContentView
    }
}
