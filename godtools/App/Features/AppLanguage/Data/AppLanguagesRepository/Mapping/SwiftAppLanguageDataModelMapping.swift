//
//  SwiftAppLanguageDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftAppLanguageDataModelMapping: Mapping {
    
    func toDataModel(externalObject: AppLanguageCodable) -> AppLanguageDataModel? {
        return AppLanguageDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftAppLanguage) -> AppLanguageDataModel? {
        return AppLanguageDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: AppLanguageCodable) -> SwiftAppLanguage? {
        return SwiftAppLanguage.createNewFrom(interface: externalObject)
    }
}
