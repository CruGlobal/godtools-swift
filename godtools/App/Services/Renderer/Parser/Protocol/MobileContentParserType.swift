//
//  MobileContentParserType.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentParserType {
    
    var manifest: MobileContentManifestType { get }
    var pageModels: [PageModelType] { get }
    var errors: [Error] { get }
    
    init(translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache)
    init(manifest: MobileContentManifestType, pageNodes: [PageNode])
    
    func getPageForListenerEvents(events: [String]) -> Int?
    func getPageModel(page: Int) -> PageModelType?
    func getVisiblePageModels() -> [PageModelType]
}

extension MobileContentParserType {
    
    func getPageModel(page: Int) -> PageModelType? {
        guard page >= 0 && page < pageModels.count else {
            return nil
        }
        return pageModels[page]
    }
    
    func getVisiblePageModels() -> [PageModelType] {
        return pageModels.filter({!$0.isHidden})
    }
}
