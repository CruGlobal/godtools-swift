//
//  RealmDatabaseQuery.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public class RealmDatabaseQuery {
    
    public let filter: NSPredicate?
    public let sortByKeyPath: SortByKeyPath?
    
    public init(filter: NSPredicate?, sortByKeyPath: SortByKeyPath?) {
        
        self.filter = filter
        self.sortByKeyPath = sortByKeyPath
    }
    
    public static func filter(filter: NSPredicate) -> RealmDatabaseQuery {
        return RealmDatabaseQuery(filter: filter, sortByKeyPath: nil)
    }
    
    public static func sort(byKeyPath: SortByKeyPath) -> RealmDatabaseQuery {
        return RealmDatabaseQuery(filter: nil, sortByKeyPath: byKeyPath)
    }
}
