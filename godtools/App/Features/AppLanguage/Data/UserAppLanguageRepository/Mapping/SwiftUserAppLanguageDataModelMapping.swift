//
//  SwiftUserAppLanguageDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserAppLanguageDataModelMapping: Mapping {
    
    func toDataModel(externalObject: UserAppLanguageDataModel) -> UserAppLanguageDataModel? {
        return UserAppLanguageDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftUserAppLanguage) -> UserAppLanguageDataModel? {
        return UserAppLanguageDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: UserAppLanguageDataModel) -> SwiftUserAppLanguage? {
        return SwiftUserAppLanguage.createNewFrom(interface: externalObject)
    }
}
