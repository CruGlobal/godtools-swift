//
//  SwiftDownloadedTranslationDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftDownloadedTranslationDataModelMapping: Mapping {
    
    func toDataModel(externalObject: DownloadedTranslationDataModel) -> DownloadedTranslationDataModel? {
        return DownloadedTranslationDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftDownloadedTranslation) -> DownloadedTranslationDataModel? {
        return DownloadedTranslationDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: DownloadedTranslationDataModel) -> SwiftDownloadedTranslation? {
        return SwiftDownloadedTranslation.createNewFrom(interface: externalObject)
    }
}
