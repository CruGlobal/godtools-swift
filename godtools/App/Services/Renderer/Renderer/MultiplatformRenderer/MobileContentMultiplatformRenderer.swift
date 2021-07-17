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
        
        guard let multiplatformPage = pageModel as? MultiplatformTractPage else {
            let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page."])
            return .failure(failedToRenderPageError)
        }
        
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
        
        /*
        let pageView: MobileContentView? = getViewFromViewFactory(
            renderableNode: pageModel,
            rendererPageModel: rendererPageModel,
            containerNode: nil
        )*/
                
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page."])
        return .failure(failedToRenderPageError)
    }
}
