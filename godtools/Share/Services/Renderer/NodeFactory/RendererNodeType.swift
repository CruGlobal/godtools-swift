//
//  RendererNodeNameType.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum RendererNodeType: String, CaseIterable {
    
    case contentParagraph = "content:paragraph"
    case contentText = "content:text"
    case contentImage = "content:image"
    case trainingTip = "training:tip"
    case heading = "heading"
    case hero = "hero"
    case pages = "pages"
    case page = "page"
    case tip = "tip"
}
