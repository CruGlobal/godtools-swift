//
//  PageXmlNodeType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum PageXmlNodeType: String, CaseIterable {
    
    case contentParagraph = "content:paragraph"
    case contentText = "content:text"
    case contentImage = "content:image"
    case page = "page"
}
