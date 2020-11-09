//
//  MobileContentXmlNodeType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum MobileContentXmlNodeType: String, CaseIterable {
    
    case analyticsAttribute = "analytics:attribute"
    case analyticsEvent = "analytics:event"
    case analyticsEvents = "analytics:events"
    case contentParagraph = "content:paragraph"
    case contentText = "content:text"
    case contentButton = "content:button"
    case contentImage = "content:image"
    case contentLabel = "content:label"
    case contentTab = "content:tab"
    case contentTabs = "content:tabs"
    case title = "title"
    case number = "number"
    case label = "label"
    case header = "header"
    case heading = "heading"
    case hero = "hero"
    case card = "card"
    case cards = "cards"
    case callToAction = "call-to-action"
    case page = "page"
    case pages = "pages"
    case tip = "tip"
}
