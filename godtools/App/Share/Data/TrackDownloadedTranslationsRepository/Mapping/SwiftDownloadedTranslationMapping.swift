//
//  SwiftDownloadedTranslationMapping.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftDownloadedTranslationMapping: Mapping {
    
    func toDataModel(externalObject: DownloadedTranslationDataModel) -> DownloadedTranslationDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftDownloadedTranslation) -> DownloadedTranslationDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: DownloadedTranslationDataModel) -> SwiftDownloadedTranslation? {
        return SwiftDownloadedTranslation.createNewFrom(model: externalObject)
    }
}
