//
//  SwiftToolLanguageDownloadMapping.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftToolLanguageDownloadMapping: Mapping {
    
    func toDataModel(externalObject: ToolLanguageDownloadDataModel) -> ToolLanguageDownloadDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftToolLanguageDownload) -> ToolLanguageDownloadDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ToolLanguageDownloadDataModel) -> SwiftToolLanguageDownload? {
        return SwiftToolLanguageDownload.createNewFrom(model: externalObject)
    }
}
