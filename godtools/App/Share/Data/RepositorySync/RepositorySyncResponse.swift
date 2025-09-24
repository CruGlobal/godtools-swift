//
//  RepositorySyncResponse.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public struct RepositorySyncResponse<DataModelType> {
    
    public let objects: [DataModelType]
    public let errors: [Error]
    
    public init(objects: [DataModelType], errors: [Error]) {
        
        self.objects = objects
        self.errors = errors
    }
    
    public func copy(objects: [DataModelType]? = nil, errors: [Error]? = nil) -> RepositorySyncResponse<DataModelType> {
        
        let copy: RepositorySyncResponse<DataModelType> = RepositorySyncResponse(
            objects: objects ?? self.objects,
            errors: errors ?? self.errors
        )
        
        return copy
    }
}
