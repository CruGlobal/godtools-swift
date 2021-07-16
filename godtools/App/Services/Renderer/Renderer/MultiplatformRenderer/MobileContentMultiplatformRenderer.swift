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
    let allPageModels: [PageModelType] = Array()
    
    required init(flowDelegate: FlowDelegate, multiplatformParser: MobileContentMultiplatformParser, resource: ResourceModel, language: LanguageModel) {
        
        self.multiplatformParser = multiplatformParser
        self.resource = resource
        self.language = language
    }
    
    var manifest: MobileContentManifestType {
        return multiplatformParser.manifest
    }
    
    func getPageForListenerEvents(events: [String]) -> Int? {
        return nil
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
