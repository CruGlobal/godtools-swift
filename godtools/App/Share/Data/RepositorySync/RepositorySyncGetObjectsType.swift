//
//  RepositorySyncGetObjectsType.swift
//  godtools
//
//  Created by Levi Eggert on 8/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public enum RepositorySyncGetObjectsType {
    case objects
    case objectsWithQuery(databaseQuery: RepositorySyncDatabaseQuery?)
    case object(id: String)
}
