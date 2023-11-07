//
//  StringSearcher.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class StringSearcher {
    
    func search<T: StringSearchable>(for searchText: String, in searchables: [T]) -> [T] {
        
        if searchText.isEmpty {
            
            return searchables
            
        } else {
            
            let lowercasedSearchText = searchText.lowercased()
            
            return getSearchResults(for: lowercasedSearchText, in: searchables)
        }
    }
    
    private func getSearchResults<T: StringSearchable>(for searchText: String, in searchables: [T]) -> [T] {
        
        return searchables.filter { searchable in
            
            for searchableString in searchable.searchableStrings {
                
                let lowercasedSearchableString = searchableString.lowercased()
                
                if lowercasedSearchableString.contains(searchText) {
                    return true
                }
            }
            
            return false
        }
    }
}
