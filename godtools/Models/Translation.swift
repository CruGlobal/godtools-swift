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
    @objc dynamic var isDownloadInProgress = false
    @objc dynamic var isDownloaded = false
    @objc dynamic var isPublished = false
    @objc dynamic var localizedDescription: String?
    @objc dynamic var localizedName: String?
    @objc dynamic var manifestFilename: String?
    @objc dynamic var remoteId = ""
    @objc dynamic var version: Int16 = 0
    @objc dynamic var language: Language?
    @objc dynamic var downloadedResource: DownloadedResource?
    @objc dynamic var tagline: String?
    
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
