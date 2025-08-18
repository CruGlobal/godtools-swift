//
//  RepositorySyncResponse.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public struct RepositorySyncResponse<DataModel> {
    
    let objects: [DataModel]
    let errors: [Error]
}
