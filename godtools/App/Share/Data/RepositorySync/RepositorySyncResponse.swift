//
//  RepositorySyncResponse.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public struct RepositorySyncResponse<DataModel> {
    
    public let objects: [DataModel]
    public let errors: [Error]
    
    public init(objects: [DataModel], errors: [Error]) {
        
        self.objects = objects
        self.errors = errors
    }
    
    public func copy(objects: [DataModel]? = nil, errors: [Error]? = nil) -> RepositorySyncResponse<DataModel> {
        
        let copy: RepositorySyncResponse<DataModel> = RepositorySyncResponse(
            objects: objects ?? self.objects,
            errors: errors ?? self.errors
        )
        
        return copy
    }
}
