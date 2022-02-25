//
//  MobileContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentRenderer {
    
    private let rendererState: State = State()
    
    let resource: ResourceModel
    let language: LanguageModel
    let pageViewFactories: MobileContentRendererPageViewFactories
    let parser: MobileContentParser
    
    required init(resource: ResourceModel, language: LanguageModel, parser: MobileContentParser, pageViewFactories: MobileContentRendererPageViewFactories) {
        
        self.parser = parser
        self.pageViewFactories = pageViewFactories
        self.resource = resource
        self.language = language
    }
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
        guard let pageModel = parser.getPageModel(page: page) else {
            return .failure(NSError.errorWithDescription(description: "Failed to render page at index: \(page)"))
        }
        
        return renderPageModel(
            pageModel: pageModel,
            page: page,
            numberOfPages: parser.pageModels.count,
            window: window,
            safeArea: safeArea,
            primaryRendererLanguage: primaryRendererLanguage
        )
    }
    
    func renderPageModel(pageModel: Page, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
        guard let manifest = parser.manifest else {
            return .failure(NSError.errorWithDescription(description: "Failed to render page because manifest does not exist."))
        }
        
        guard let resourcesCache = parser.manifestResourcesCache else {
            return .failure(NSError.errorWithDescription(description: "Failed to render page because manifest does not exist."))
        }
        
        let rendererPageModel = MobileContentRendererPageModel(
            pageModel: pageModel,
            page: page,
            isLastPage: page == numberOfPages - 1,
            window: window,
            safeArea: safeArea,
            manifest: manifest,
            resourcesCache: resourcesCache,
            resource: resource,
            language: language,
            pageViewFactories: pageViewFactories,
            primaryRendererLanguage: primaryRendererLanguage,
            rendererState: rendererState
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

