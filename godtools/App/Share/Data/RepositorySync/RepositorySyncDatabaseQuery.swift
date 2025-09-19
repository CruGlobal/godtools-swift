//
//  RepositorySyncDatabaseQuery.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public class RepositorySyncDatabaseQuery {
    
    public let filter: NSPredicate?
    public let sortByKeyPath: SortByKeyPath?
    
    public init(filter: NSPredicate?, sortByKeyPath: SortByKeyPath?) {
        
        self.filter = filter
        self.sortByKeyPath = sortByKeyPath
    }
    
    public static func filter(filter: NSPredicate) -> RepositorySyncDatabaseQuery {
        return RepositorySyncDatabaseQuery(filter: filter, sortByKeyPath: nil)
    }
    
    public static func sort(byKeyPath: SortByKeyPath) -> RepositorySyncDatabaseQuery {
        return RepositorySyncDatabaseQuery(filter: nil, sortByKeyPath: byKeyPath)
    }
}
