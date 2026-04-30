//
//  SwiftDownloadedLanguageMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftDownloadedLanguageMapping: Mapping {
    
    func toDataModel(externalObject: DownloadedLanguageDataModel) -> DownloadedLanguageDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftDownloadedLanguage) -> DownloadedLanguageDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: DownloadedLanguageDataModel) -> SwiftDownloadedLanguage? {
        return SwiftDownloadedLanguage.createNewFrom(model: externalObject)
    }
}
