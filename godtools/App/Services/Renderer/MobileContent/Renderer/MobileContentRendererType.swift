//
//  MobileContentRendererType.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRendererType {
    
    var manifest: MobileContentXmlManifest { get }
    var resource: ResourceModel { get }
    var language: LanguageModel { get }
    var allPages: [PageNode] { get }
    
    func getPageForListenerEvents(events: [String]) -> Int?
    func getPageNode(page: Int) -> PageNode?
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
    func renderPageNode(pageNode: PageNode, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
}
