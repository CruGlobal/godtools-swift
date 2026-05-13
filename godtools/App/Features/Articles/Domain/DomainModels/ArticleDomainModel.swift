//
//  ArticleDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ArticleDomainModel: Sendable {
    
    enum UrlType: Sendable {
        case fileUrl
        case url
    }
    
    let url: URL?
    let urlType: UrlType?
}
