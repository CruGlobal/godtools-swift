//
//  MobileContentMultiplatformRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentMultiplatformRenderer {
    
    private let mobileContentMultiplatformParser: MobileContentMultiplatformParser
    
    let resource: ResourceModel
    let language: LanguageModel
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, language: LanguageModel, manifestFilename: String, resourcesSHA256FileCache: ResourcesSHA256FileCache) {
        
        self.mobileContentMultiplatformParser = MobileContentMultiplatformParser(manifestFilename: manifestFilename, sha256FileCache: resourcesSHA256FileCache)
        self.resource = resource
        self.language = language
    }
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
        /*
        let pageNode: PageNode?
        let parseError: Error?
        
        if let cachedPageNode = getPageNode(page: page) {
            pageNode = cachedPageNode
            parseError = nil
        }
        else {
            
            let result: Result<PageNode, Error> = parsePageNode(
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                page: page
            )
            
            switch result {
            
            case .success(let parsedPageNode):
                pageNode = parsedPageNode
                parseError = nil
                
            case .failure(let error):
                pageNode = nil
                parseError = error
            }
        }
        
        if let pageNode = pageNode {
                        
            return renderPageNode(
                pageNode: pageNode,
                page: page,
                numberOfPages: allPages.count,
                window: window,
                safeArea: safeArea,
                primaryRendererLanguage: primaryRendererLanguage
            )
        }
        else if let parseError = parseError {
            
            return .failure(parseError)
        }*/
        
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node."])
        return .failure(failedToRenderPageError)
    }
}
