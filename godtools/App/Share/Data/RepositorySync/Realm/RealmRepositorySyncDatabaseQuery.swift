//
//  RealmRepositorySyncDatabaseQuery.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public class RealmRepositorySyncDatabaseQuery {
    
    public let filter: NSPredicate?
    public let sortByKeyPath: SortByKeyPath?
    
    public init(filter: NSPredicate?, sortByKeyPath: SortByKeyPath?) {
        
        self.filter = filter
        self.sortByKeyPath = sortByKeyPath
    }
    
    public static func filter(filter: NSPredicate) -> RealmRepositorySyncDatabaseQuery {
        return RealmRepositorySyncDatabaseQuery(filter: filter, sortByKeyPath: nil)
    }
    
    public static func sort(byKeyPath: SortByKeyPath) -> RealmRepositorySyncDatabaseQuery {
        return RealmRepositorySyncDatabaseQuery(filter: nil, sortByKeyPath: byKeyPath)
    }
}
