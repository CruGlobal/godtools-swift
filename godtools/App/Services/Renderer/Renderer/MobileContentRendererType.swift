//
//  MobileContentRendererType.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRendererType {
    
    var resource: ResourceModel { get }
    var language: LanguageModel { get }
    var parser: MobileContentParserType { get }
    var pageViewFactories: [MobileContentPageViewFactoryType] { get }
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
    func renderPageModel(pageModel: PageModelType, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
}

extension MobileContentRendererType {
    
    func getViewFromViewFactory(renderableModel: MobileContentRenderableModel, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) -> MobileContentView? {
        
        for viewFactory in pageViewFactories {
            
            if let view = viewFactory.viewForRenderableModel(renderableModel: renderableModel, rendererPageModel: rendererPageModel, containerModel: containerModel) {
            
                return view
            }
        }
        
        return nil
    }
}
