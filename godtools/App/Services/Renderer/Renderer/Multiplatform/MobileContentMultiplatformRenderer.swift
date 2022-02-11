//
//  MobileContentMultiplatformRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentMultiplatformRenderer: MobileContentRendererType {
    
    private let multiplatformParser: MobileContentMultiplatformParser
    private let rendererState: State = State()
    
    let resource: ResourceModel
    let language: LanguageModel
    let pageViewFactories: MobileContentRendererPageViewFactories
    
    required init(resource: ResourceModel, language: LanguageModel, multiplatformParser: MobileContentMultiplatformParser, pageViewFactories: MobileContentRendererPageViewFactories) {
        
        self.multiplatformParser = multiplatformParser
        self.pageViewFactories = pageViewFactories
        self.resource = resource
        self.language = language
    }
    
    var parser: MobileContentParserType {
        return multiplatformParser
    }
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
        if let pageModel = multiplatformParser.getPageModel(page: page) {
                    
            // TODO: Could this get moved to MobileContentRendererType? ~Levi
            return renderPageModel(
                pageModel: pageModel,
                page: page,
                numberOfPages: parser.pageModels.count,
                window: window,
                safeArea: safeArea,
                primaryRendererLanguage: primaryRendererLanguage
            )
        }
        else {
            
            let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page."])
            return .failure(failedToRenderPageError)
        }
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
            primaryRendererLanguage: primaryRendererLanguage,
            rendererState: rendererState
        )
        
        if let renderableView = recurseAndRender(renderableModel: pageModel, renderableModelParent: nil, rendererPageModel: rendererPageModel, containerModel: nil) {
            return .success(renderableView)
        }
                
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page."])
        return .failure(failedToRenderPageError)
    }
    
    private func recurseAndRender(renderableModel: MobileContentRenderableModel, renderableModelParent: MobileContentRenderableModel?, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) -> MobileContentView? {
        
        let containerModel: MobileContentRenderableModelContainer? = (renderableModel as? MobileContentRenderableModelContainer) ?? containerModel
           
        let mobileContentView: MobileContentView? = pageViewFactories.getViewFromViewFactory(renderableModel: renderableModel, renderableModelParent: renderableModelParent, rendererPageModel: rendererPageModel, containerModel: containerModel)
        
        let childModels: [MobileContentRenderableModel] = renderableModel.getRenderableChildModels()
                
        for childModel in childModels {
            
            let childMobileContentView: MobileContentView? = recurseAndRender(renderableModel: childModel, renderableModelParent: renderableModel, rendererPageModel: rendererPageModel, containerModel: containerModel)
            
            if let childMobileContentView = childMobileContentView, let mobileContentView = mobileContentView {
                mobileContentView.renderChild(childView: childMobileContentView)
            }
        }
        
        mobileContentView?.finishedRenderingChildren()
        
        return mobileContentView
    }
}
