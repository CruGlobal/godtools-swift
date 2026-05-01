//
//  SwiftLocalActivityCountMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftLocalActivityCountMapping: Mapping {
    
    func toDataModel(externalObject: LocalActivityCountDataModel) -> LocalActivityCountDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftLocalActivityCount) -> LocalActivityCountDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: LocalActivityCountDataModel) -> SwiftLocalActivityCount? {
        return SwiftLocalActivityCount.createNewFrom(model: externalObject)
    }
}
