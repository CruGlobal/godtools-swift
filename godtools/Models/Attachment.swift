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
    @objc dynamic var remoteId = ""
    @objc dynamic var sha: String? = nil
    @objc dynamic var isBanner = false
    @objc dynamic var resource: DownloadedResource?
    let translations = List<Translation>()
}
