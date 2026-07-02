//
//  RealmEmailSignUpMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmEmailSignUpMapping: Mapping {
    
    func toDataModel(externalObject: EmailSignUpDataModel) -> EmailSignUpDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmEmailSignUp) -> EmailSignUpDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: EmailSignUpDataModel) -> RealmEmailSignUp? {
        return RealmEmailSignUp.createNewFrom(model: externalObject)
    }
}
