//
//  URLLinkTappedParams.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct URLLinkTappedParams: Sendable {
    
    let url: URL
    let screenName: String
    let siteSection: String
    let siteSubSection: String
    let contentLanguage: String?
    let contentLanguageSecondary: String?
}
