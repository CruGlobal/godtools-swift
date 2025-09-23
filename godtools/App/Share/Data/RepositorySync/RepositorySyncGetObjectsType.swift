//
//  RepositorySyncGetObjectsType.swift
//  godtools
//
//  Created by Levi Eggert on 8/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public enum RepositorySyncGetObjectsType<PersistenceQueryType> {
    case allObjects
    case objectsWithQuery(query: PersistenceQueryType?)
    case object(id: String)
}
