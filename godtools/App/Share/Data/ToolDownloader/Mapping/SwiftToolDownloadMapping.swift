//
//  SwiftToolDownloadMapping.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftToolDownloadMapping: Mapping {

    func toDataModel(externalObject: ToolDownloadDataModel) -> ToolDownloadDataModel? {
        return externalObject
    }

    func toDataModel(persistObject: SwiftToolDownload) -> ToolDownloadDataModel? {
        return persistObject.toModel()
    }

    func toPersistObject(externalObject: ToolDownloadDataModel) -> SwiftToolDownload? {
        return SwiftToolDownload.createNewFrom(model: externalObject)
    }
}
