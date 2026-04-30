//
//  SwiftAppLanguageMapping.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftAppLanguageMapping: Mapping {
    
    func toDataModel(externalObject: AppLanguageCodable) -> AppLanguageDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftAppLanguage) -> AppLanguageDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: AppLanguageCodable) -> SwiftAppLanguage? {
        return SwiftAppLanguage.createNewFrom(model: externalObject.toModel())
    }
}
