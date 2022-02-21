//
//  MobileContentParserType.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol MobileContentParserType {
        
    var manifest: MobileContentManifestType { get }
    var manifestResourcesCache: ManifestResourcesCacheType { get }
    var pageModels: [PageModelType] { get }
    var errors: [Error] { get }
    
    init(translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache)
    init(manifest: MobileContentManifestType, pageModels: [PageModelType], translationsFileCache: TranslationsFileCache)
    
    func getPageModel(page: Int) -> PageModelType?
    func getVisiblePageModels() -> [PageModelType]
    func getPageForListenerEvents(eventIds: [EventId]) -> Int?
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
    
    func getPageForListenerEvents(eventIds: [EventId]) -> Int? {
                
        for pageIndex in 0 ..< pageModels.count {
            
            let pageModel: PageModelType = pageModels[pageIndex]
            
            for listener in pageModel.listeners {
               
                if eventIds.contains(listener) {
                    return pageIndex
                }
            }
        }
        
        return nil
    }
}
