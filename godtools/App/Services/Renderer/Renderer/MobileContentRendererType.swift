//
//  MobileContentRendererType.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRendererType {
    
    var manifest: MobileContentManifestType { get }
    var resource: ResourceModel { get }
    var language: LanguageModel { get }
    var allPageModels: [PageModelType] { get }
    
    func getPageModel(page: Int) -> PageModelType?
    func getVisiblePageModels() -> [PageModelType]
    func getPageForListenerEvents(events: [String]) -> Int?
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
    func renderPageModel(pageModel: PageModelType, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error>
}

extension MobileContentRendererType {
    
    func getPageModel(page: Int) -> PageModelType? {
        guard page >= 0 && page < allPageModels.count else {
            return nil
        }
        return allPageModels[page]
    }
    
    func getVisiblePageModels() -> [PageModelType] {
        return allPageModels.filter({!$0.isHidden})
    }
}
