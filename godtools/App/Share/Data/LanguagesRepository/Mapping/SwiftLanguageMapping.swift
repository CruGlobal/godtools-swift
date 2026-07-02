//
//  SwiftLanguageMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftLanguageMapping: Mapping {
    
    func toDataModel(externalObject: LanguageCodable) -> LanguageDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftLanguage) -> LanguageDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: LanguageCodable) -> SwiftLanguage? {
        return SwiftLanguage.createNewFrom(model: externalObject.toModel())
    }
}
