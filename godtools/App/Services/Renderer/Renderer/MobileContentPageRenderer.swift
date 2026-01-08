//
//  MobileContentPageRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class MobileContentPageRenderer {
    
    private let navigation: MobileContentRendererNavigation
    
    let sharedState: State
    let resource: ResourceDataModel
    let appLanguage: AppLanguageDomainModel
    let rendererLanguages: MobileContentRendererLanguages
    let manifest: Manifest
    let language: LanguageDataModel
    let translation: TranslationDataModel
    let manifestResourcesCache: MobileContentRendererManifestResourcesCache
    let viewRenderer: MobileContentViewRenderer
    let pagesViewDataCache: MobileContentPageRendererPagesViewDataCache = MobileContentPageRendererPagesViewDataCache()
    
    init(sharedState: State, resource: ResourceDataModel, appLanguage: AppLanguageDomainModel, rendererLanguages: MobileContentRendererLanguages, languageTranslationManifest: MobileContentRendererLanguageTranslationManifest, pageViewFactories: MobileContentRendererPageViewFactories, navigation: MobileContentRendererNavigation, manifestResourcesCache: MobileContentRendererManifestResourcesCache) {
        
        self.sharedState = sharedState
        self.resource = resource
        self.appLanguage = appLanguage
        self.rendererLanguages = rendererLanguages
        self.manifest = languageTranslationManifest.manifest
        self.language = languageTranslationManifest.language
        self.translation = languageTranslationManifest.translation
        self.manifestResourcesCache = manifestResourcesCache
        self.viewRenderer = MobileContentViewRenderer(pageViewFactories: pageViewFactories)
        self.navigation = navigation
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
            
            for listener in pageModel.listeners where eventIds.contains(listener) {
                
                return pageIndex
            }
        }
        
        return nil
    }
    
    // MARK: - Page Renderering
    
    private func getRenderedPageContext(pageModel: Page, page: Int, numberOfPages: Int, parentPageParams: MobileContentParentPageParams?, window: UIViewController, safeArea: UIEdgeInsets, manifest: Manifest, manifestResourcesCache: MobileContentRendererManifestResourcesCache, resource: ResourceDataModel, language: LanguageDataModel, translation: TranslationDataModel, viewRenderer: MobileContentViewRenderer, rendererLanguages: MobileContentRendererLanguages, sharedState: State, trainingTipsEnabled: Bool, userInfo: [String: Any]?) -> MobileContentRenderedPageContext {
        
        let renderedPageContext = MobileContentRenderedPageContext(
            pageModel: pageModel,
            page: page,
            isLastPage: page == numberOfPages - 1,
            parentPageParams: parentPageParams,
            window: window,
            safeArea: safeArea,
            manifest: manifest,
            resourcesCache: manifestResourcesCache,
            resource: resource,
            appLanguage: appLanguage,
            language: language,
            translation: translation,
            viewRenderer: viewRenderer,
            navigation: navigation,
            rendererLanguages: rendererLanguages,
            rendererState: sharedState,
            trainingTipsEnabled: trainingTipsEnabled,
            pageViewDataCache: pagesViewDataCache.getPageViewDataCache(page: pageModel),
            userInfo: userInfo
        )
        
        return renderedPageContext
    }
    
    @MainActor func renderPageModel(pageModel: Page, page: Int, numberOfPages: Int, parentPageParams: MobileContentParentPageParams?, window: UIViewController, safeArea: UIEdgeInsets, trainingTipsEnabled: Bool, userInfo: [String: Any]?) -> Result<MobileContentView, Error> {
        
        let renderedPageContext: MobileContentRenderedPageContext = getRenderedPageContext(
            pageModel: pageModel,
            page: page,
            numberOfPages: numberOfPages,
            parentPageParams: parentPageParams,
            window: window,
            safeArea: safeArea,
            manifest: manifest,
            manifestResourcesCache: manifestResourcesCache,
            resource: resource,
            language: language,
            translation: translation,
            viewRenderer: viewRenderer,
            rendererLanguages: rendererLanguages,
            sharedState: sharedState,
            trainingTipsEnabled: trainingTipsEnabled,
            userInfo: userInfo
        )
        
        guard let renderableView = viewRenderer.recurseAndRender(renderableModel: pageModel, renderableModelParent: nil, renderedPageContext: renderedPageContext) else {
            return .failure(NSError.errorWithDescription(description: "Failed to render page."))
        }
                
        return .success(renderableView)
    }
}
