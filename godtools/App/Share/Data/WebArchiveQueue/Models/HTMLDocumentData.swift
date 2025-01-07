//
//  HTMLDocumentData.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Fuzi

class HTMLDocumentData {
    
    let mainResource: WebArchiveMainResource
    let resourceUrls: [String]
    
    init(mainResource: WebArchiveMainResource, resourceUrls: [String]) {
        
        self.mainResource = mainResource
        self.resourceUrls = resourceUrls
    }
}
