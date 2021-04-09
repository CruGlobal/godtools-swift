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
    case callToAction = "call-to-action"
    case card = "card"
    case cards = "cards"
    case contentButton = "content:button"
    case contentFallback = "content:fallback"
    case contentForm = "content:form"
    case contentImage = "content:image"
    case contentInput = "content:input"
    case contentLabel = "content:label"
    case contentLink = "content:link"
    case contentNode = "content"
    case contentParagraph = "content:paragraph"
    case contentPlaceholder = "content:placeholder"
    case contentSpacer = "content:spacer"
    case contentTab = "content:tab"
    case contentTabs = "content:tabs"
    case contentText = "content:text"
    case header = "header"
    case heading = "heading"
    case hero = "hero"
    case label = "label"
    case modal = "modal"
    case modals = "modals"
    case number = "number"
    case page = "page"
    case pages = "pages"
    case tip = "tip"
    case title = "title"
    case trainingTip = "training:tip"
}
