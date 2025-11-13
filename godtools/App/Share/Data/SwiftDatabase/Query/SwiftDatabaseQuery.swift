//
//  SwiftDatabaseQuery.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
public class SwiftDatabaseQuery<T: IdentifiableSwiftDataObject> {
    
    public let fetchDescriptor: FetchDescriptor<T>
    
    public init(filter: Predicate<T>?, sortBy: [SortDescriptor<T>]?) {
        self.fetchDescriptor = FetchDescriptor(predicate: filter, sortBy: sortBy ?? [])
    }
    
    public init(fetchDescriptor: FetchDescriptor<T>) {
        self.fetchDescriptor = fetchDescriptor
    }
    
    public static func filter(filter: Predicate<T>) -> SwiftDatabaseQuery {
        return SwiftDatabaseQuery(filter: filter, sortBy: nil)
    }
    
    public static func sort(sortBy: [SortDescriptor<T>]) -> SwiftDatabaseQuery {
        return SwiftDatabaseQuery(filter: nil, sortBy: sortBy)
    }
}
