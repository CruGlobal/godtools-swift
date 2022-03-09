//
//  WebContent.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct WebContent: WebContentType {
    
    let navTitle: String
    let url: URL?
    let analyticsScreenName: String
    let analyticsSiteSection: String
}
