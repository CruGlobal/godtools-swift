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
    dynamic var isDownloadInProgress = false
    dynamic var isDownloaded = false
    dynamic var isPublished = false
    dynamic var localizedDescription: String?
    dynamic var localizedName: String?
    dynamic var manifestFilename: String?
    dynamic var remoteId = ""
    dynamic var version: Int16 = 0
    dynamic var language: Language?
    dynamic var downloadedResource: DownloadedResource?
    dynamic var tagline: String?
    let referencedFiles = LinkingObjects(fromType: ReferencedFile.self, property: "translations")
    let attachments = LinkingObjects(fromType: Attachment.self, property: "translations")
    
    override static func primaryKey() -> String {
        return "remoteId"
    }
    
    func shouldDownload() -> Bool {
        return isInvalidated == false &&
            isDownloaded == false &&
            isDownloadInProgress == false
    }
}
