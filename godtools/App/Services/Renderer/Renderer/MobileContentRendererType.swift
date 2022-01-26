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
    var pageViewFactories: MobileContentRendererPageViewFactories { get }
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
    func renderPageModel(pageModel: PageModelType, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
}
