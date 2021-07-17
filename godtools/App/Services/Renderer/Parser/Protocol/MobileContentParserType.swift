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
    init(manifest: MobileContentManifestType, pageModels: [PageModelType])
    
    func getPageModel(page: Int) -> PageModelType?
    func getVisiblePageModels() -> [PageModelType]
    func getPageForListenerEvents(events: [String]) -> Int?
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
    
    func getPageForListenerEvents(events: [String]) -> Int? {
        
        return nil // TODO: Remove this line. ~Levi
        
        for pageIndex in 0 ..< pageModels.count {
            let pageModel: PageModelType = pageModels[pageIndex]
            for listener in pageModel.listeners {
                if events.contains(listener) {
                    return pageIndex
                }
            }
        }
        
        return nil
    }
}
