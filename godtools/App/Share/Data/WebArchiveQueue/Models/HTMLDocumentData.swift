//
//  HTMLDocumentData.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Fuzi

struct HTMLDocumentData {
    let mainResource: WebArchiveMainResource
    let htmlDocument: HTMLDocument
    let resourceUrls: [String]
}
