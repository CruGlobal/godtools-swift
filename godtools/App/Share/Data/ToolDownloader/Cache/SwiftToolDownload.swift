//
//  SwiftToolDownload.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftToolDownload = SwiftToolDownloadV1.SwiftToolDownload

@available(iOS 17.4, *)
enum SwiftToolDownloadV1 {

    @Model
    class SwiftToolDownload: IdentifiableSwiftDataObject {

        var toolId: String = ""
        var languages: [BCP47LanguageIdentifier] = Array<BCP47LanguageIdentifier>()
        var downloadStarted: Date = Date()
        var progress: Double = 0
        var downloadErrorDescription: String?
        var downloadErrorHttpStatusCode: Int?

        @Attribute(.unique) var id: String = ""

        init() {

        }
    }
}

@available(iOS 17.4, *)
extension SwiftToolDownload {
    
    public static func idPredicate(id: String) -> Predicate<SwiftToolDownload> {
        return #Predicate<SwiftToolDownload> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftToolDownload> {
        return #Predicate<SwiftToolDownload> { object in
            ids.contains(object.id)
        }
    }

    func mapFrom(model: ToolDownloadDataModel) {
        id = model.id.value
        toolId = model.toolId
        languages = model.languages
        downloadStarted = model.downloadStarted
        progress = model.progress
        downloadErrorDescription = model.downloadErrorDescription
        downloadErrorHttpStatusCode = model.downloadErrorHttpStatusCode
    }

    static func createNewFrom(model: ToolDownloadDataModel) -> SwiftToolDownload {
        let object = SwiftToolDownload()
        object.mapFrom(model: model)
        return object
    }

    func toModel() -> ToolDownloadDataModel {
        return ToolDownloadDataModel(
            toolId: toolId,
            languages: languages,
            downloadStarted: downloadStarted,
            progress: progress,
            downloadErrorDescription: downloadErrorDescription,
            downloadErrorHttpStatusCode: downloadErrorHttpStatusCode
        )
    }
}
