//
//  GTRealmDatabaseQuery.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public class GTRealmDatabaseQuery {
    
    public let filter: NSPredicate?
    public let sortByKeyPath: GTSortByKeyPath?
    
    public init(filter: NSPredicate?, sortByKeyPath: GTSortByKeyPath?) {
        
        self.filter = filter
        self.sortByKeyPath = sortByKeyPath
    }
    
    public static func filter(filter: NSPredicate) -> GTRealmDatabaseQuery {
        return GTRealmDatabaseQuery(filter: filter, sortByKeyPath: nil)
    }
    
    public static func sort(byKeyPath: GTSortByKeyPath) -> GTRealmDatabaseQuery {
        return GTRealmDatabaseQuery(filter: nil, sortByKeyPath: byKeyPath)
    }
}
