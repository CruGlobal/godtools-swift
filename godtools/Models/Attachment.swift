//
//  Attachment.swift
//  godtools
//
//  Created by Ryan Carlson on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class Attachment: Object {
    dynamic var remoteId = ""
    dynamic var sha: String? = nil
    dynamic var isBanner = false
    dynamic var resource: DownloadedResource?
    let translations = List<Translation>()
}
