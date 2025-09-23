//
//  RepositorySyncDatabaseQuery.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
public class RepositorySyncDatabaseQuery<T: IdentifiableSwiftDataObject> {
    
    public let fetchDescriptor: FetchDescriptor<T>
    
    public init(filter: Predicate<T>?, sortBy: [SortDescriptor<T>]?) {
        self.fetchDescriptor = FetchDescriptor(predicate: filter, sortBy: sortBy ?? [])
    }
    
    public init(fetchDescriptor: FetchDescriptor<T>) {
        self.fetchDescriptor = fetchDescriptor
    }
    
    public static func filter(filter: Predicate<T>) -> RepositorySyncDatabaseQuery {
        return RepositorySyncDatabaseQuery(filter: filter, sortBy: nil)
    }
    
    public static func sort(sortBy: [SortDescriptor<T>]) -> RepositorySyncDatabaseQuery {
        return RepositorySyncDatabaseQuery(filter: nil, sortBy: sortBy)
    }
}
