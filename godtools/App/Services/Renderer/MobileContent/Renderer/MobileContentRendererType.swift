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
    var pages: ObservableValue<[PageNode]> { get }
    
    func getPageForListenerEvents(events: [String]) -> Int?
    func getPageNode(page: Int) -> PageNode?
    func renderPageFromAllPageNodes(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
    func renderPageFromPageNodes(pageNodes: [PageNode], page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
}
