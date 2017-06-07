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
    dynamic var localizedDescription = ""
    dynamic var localizedName = ""
    dynamic var manifestFilename = ""
    dynamic var remoteId = ""
    dynamic var version: Int16 = 0
    dynamic var downloadedResource: DownloadedResource?
    dynamic var language: Language?
    let referencedFiles = List<ReferencedFile>()
    let attachments = List<Attachment>()
}
