//
//  SwiftLanguageDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

@available(iOS 17.4, *)
class SwiftLanguageDataModelMapping: RepositorySyncMapping {
    
    func toDataModel(externalObject: LanguageCodable) -> LanguageDataModel? {
        return LanguageDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftLanguage) -> LanguageDataModel? {
        return LanguageDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: LanguageCodable) -> SwiftLanguage? {
        return SwiftLanguage.createNewFrom(interface: externalObject)
    }
}
