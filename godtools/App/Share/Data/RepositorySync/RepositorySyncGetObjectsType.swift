//
//  RepositorySyncGetObjectsType.swift
//  godtools
//
//  Created by Levi Eggert on 8/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

@available(iOS 17, *)
public enum RepositorySyncGetObjectsType<T: IdentifiableSwiftDataObject> {
    case allObjects
    case objectsWithQuery(databaseQuery: RepositorySyncDatabaseQuery<T>?)
    case object(id: String)
}
