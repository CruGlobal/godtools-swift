//
//  RepositorySyncDatabaseQuery.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

@available(iOS 17, *)
public class RepositorySyncDatabaseQuery<T: IdentifiableSwiftDataObject> {
    
    public let filter: Predicate<T>?
    public let sortByKeyPath: SortByKeyPath?
    
    public init(filter: Predicate<T>?, sortByKeyPath: SortByKeyPath?) {
        
        self.filter = filter
        self.sortByKeyPath = sortByKeyPath
    }
    
    public static func filter(filter: Predicate<T>) -> RepositorySyncDatabaseQuery {
        return RepositorySyncDatabaseQuery(filter: filter, sortByKeyPath: nil)
    }
    
    public static func sort(byKeyPath: SortByKeyPath) -> RepositorySyncDatabaseQuery {
        return RepositorySyncDatabaseQuery(filter: nil, sortByKeyPath: byKeyPath)
    }
}
