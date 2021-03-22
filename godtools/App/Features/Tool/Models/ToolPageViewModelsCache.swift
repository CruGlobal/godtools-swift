//
//  ToolPageViewModelsCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// TODO: Remove this class. ~Levi
class ToolPageViewModelsCache {
    
    typealias PageNumber = Int
    
    private var cache: [PageNumber: ToolPageViewModelType] = Dictionary()
    
    required init() {
        
    }
    
    func getPage(page: Int) -> ToolPageViewModelType? {
        return cache[page]
    }
    
    func cachePage(page: Int, toolPageViewModel: ToolPageViewModelType) {
        cache[page] = toolPageViewModel
    }
    
    func deletePage(page: Int) {
        cache[page] = nil
    }
    
    func clearCache() {
        cache.removeAll()
    }
    
    func deleteAllPagesExcept(page: Int) {
        let pageToKeep: ToolPageViewModelType? = cache[page]
        cache.removeAll()
        cache[page] = pageToKeep
    }
    
    func deleteAllPagesOutsideBufferFromPage(page: Int, buffer: Int) {
        
        let allPageNumbers: [Int] = Array(cache.keys)
        
        guard allPageNumbers.count > 1 else {
            return
        }
        
        for pageNumber in allPageNumbers {
            if pageNumber < (page - buffer) || pageNumber > (page + buffer) {
                deletePage(page: pageNumber)
            }
        }
    }
}
