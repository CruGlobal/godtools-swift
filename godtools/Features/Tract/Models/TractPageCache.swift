//
//  TractPageCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractPageCache {
    
    private var primaryTractPages: [Int: TractPage] = Dictionary()
    private var parallelTractPages: [Int: TractPage] = Dictionary()
    
    func getCacheDictionary(type: TractLanguageType) -> [Int: TractPage] {
        switch type {
        case .primary:
            return primaryTractPages
        case .parallel:
            return parallelTractPages
        }
    }
    
    func cacheTractPage(type: TractLanguageType, page: Int, tractPage: TractPage) {
        
        switch type {
        case .primary:
            primaryTractPages[page] = tractPage
        case .parallel:
            parallelTractPages[page] = tractPage
        }
    }
    
    func getTractPage(type: TractLanguageType, page: Int) -> TractPage? {
        return getCacheDictionary(type: type)[page]
    }
    
    func tractPagesCached(page: Int) -> Bool {
        
        return getTractPage(type: .primary, page: page) != nil && getTractPage(type: .parallel, page: page) != nil
    }
    
    func clearCache(type: TractLanguageType) {
        
        switch type {
        case .primary:
            primaryTractPages.removeAll()
        case .parallel:
            parallelTractPages.removeAll()
        }
    }
    
    func deleteTractPage(type: TractLanguageType, page: Int) {
        
        switch type {
        case .primary:
            primaryTractPages[page] = nil
        case .parallel:
            parallelTractPages[page] = nil
        }
    }
    
    func deleteTractPagesOutsideBuffer(buffer: Int, page: Int) {
                
        deleteTractPagesOutsideBuffer(buffer: buffer, page: page, tractPagesCache: &primaryTractPages)
        
        deleteTractPagesOutsideBuffer(buffer: buffer, page: page, tractPagesCache: &parallelTractPages)
    }
    
    private func deleteTractPagesOutsideBuffer(buffer: Int, page: Int, tractPagesCache: inout [Int: TractPage]) {
        
        let tractPageKeys: [Int] = Array(tractPagesCache.keys)
                
        for key in tractPageKeys {
            let distance: Int = abs(page - key)
            if distance > buffer {
                tractPagesCache[key] = nil
            }
        }
    }
}
