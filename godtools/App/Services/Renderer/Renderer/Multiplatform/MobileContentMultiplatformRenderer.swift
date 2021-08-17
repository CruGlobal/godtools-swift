//
//  MobileContentMultiplatformRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentMultiplatformRenderer: MobileContentRendererType {
    
    private let multiplatformParser: MobileContentMultiplatformParser
    
    let resource: ResourceModel
    let language: LanguageModel
    let pageViewFactories: [MobileContentPageViewFactoryType]
    
    required init(resource: ResourceModel, language: LanguageModel, multiplatformParser: MobileContentMultiplatformParser, pageViewFactories: MobileContentRendererPageViewFactories) {
        
        self.multiplatformParser = multiplatformParser
        self.pageViewFactories = pageViewFactories.factories
        self.resource = resource
        self.language = language
    }
    
    var parser: MobileContentParserType {
        return multiplatformParser
    }
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page."])
        return .failure(failedToRenderPageError)
    }
    
    func renderPageModel(pageModel: PageModelType, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
        let rendererPageModel = MobileContentRendererPageModel(
            pageModel: pageModel,
            page: page,
            isLastPage: page == numberOfPages - 1,
            window: window,
            safeArea: safeArea,
            manifest: parser.manifest,
            resourcesCache: parser.manifestResourcesCache,
            resource: resource,
            language: language,
            pageViewFactories: pageViewFactories,
            primaryRendererLanguage: primaryRendererLanguage
        )
        
        if let renderableView = recurseAndRender(renderableModel: pageModel, rendererPageModel: rendererPageModel, containerModel: nil) {
            return .success(renderableView)
        }
                
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page."])
        return .failure(failedToRenderPageError)
    }
    
    private func recurseAndRender(renderableModel: MobileContentRenderableModel, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) -> MobileContentView? {
        
        let containerModel: MobileContentRenderableModelContainer? = (renderableModel as? MobileContentRenderableModelContainer) ?? containerModel
        
        guard renderableModel.isRenderable else {
            return nil
        }
         
        let mobileContentView: MobileContentView? = getViewFromViewFactory(renderableModel: renderableModel, rendererPageModel: rendererPageModel, containerModel: containerModel)
        
        let childModels: [MobileContentRenderableModel] = renderableModel.getRenderableChildModels()
        
        for childModel in childModels {
            
            let childMobileContentView: MobileContentView? = recurseAndRender(renderableModel: childModel, rendererPageModel: rendererPageModel, containerModel: containerModel)
            
            if let childMobileContentView = childMobileContentView, let mobileContentView = mobileContentView {
                mobileContentView.renderChild(childView: childMobileContentView)
            }
        }
        
        mobileContentView?.finishedRenderingChildren()
        
        return mobileContentView
    }
}
