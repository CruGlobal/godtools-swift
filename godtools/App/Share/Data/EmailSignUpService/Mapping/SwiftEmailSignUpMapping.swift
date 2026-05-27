//
//  SwiftEmailSignUpMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftEmailSignUpMapping: Mapping {
    
    func toDataModel(externalObject: EmailSignUpDataModel) -> EmailSignUpDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftEmailSignUp) -> EmailSignUpDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: EmailSignUpDataModel) -> SwiftEmailSignUp? {
        return SwiftEmailSignUp.createNewFrom(model: externalObject)
    }
}
