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
    private let pageViewFactories: [MobileContentPageViewFactoryType]
    
    let resource: ResourceModel
    let language: LanguageModel
    
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
        
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page."])
        return .failure(failedToRenderPageError)
    }
}
