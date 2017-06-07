//
//  Translation.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class Translation: Object {
    dynamic var isDownloaded = false
    dynamic var isPublished = false
    dynamic var localizedDescription: String?
    dynamic var localizedName: String?
    dynamic var manifestFilename: String?
    dynamic var remoteId = ""
    dynamic var version: Int16 = 0
    dynamic var language: Language?
    let downloadedResource = LinkingObjects(fromType: DownloadedResource.self, property: "translations")
    let referencedFiles = LinkingObjects(fromType: ReferencedFile.self, property: "translations")
    let attachments = LinkingObjects(fromType: Attachment.self, property: "translations")
}
