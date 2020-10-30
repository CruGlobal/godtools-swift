//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: ToolPageViewModelType {
        
    let contentStack: MobileContentStackViewModel?
    let headerNumber: String?
    let headerTitle: String?
    let hidesHeader: Bool
    let hero: MobileContentStackViewModel?
    let callToActionTitle: String?
    let hidesCallToAction: Bool
    
    required init(pageNode: PageNode) {
        
        let pageHeaderNumber: String? = pageNode.header?.number
        let pageHeaderTitle: String? = pageNode.header?.title
        let hidesHeader: Bool = pageHeaderNumber == nil && pageHeaderTitle == nil
        
        let firstNodeIsContentParagraph: Bool = pageNode.children.first is ContentParagraphNode
        
        if firstNodeIsContentParagraph {
            contentStack = MobileContentStackViewModel(node: pageNode)
        }
        else {
            contentStack = nil
        }
        
        headerNumber = pageHeaderNumber
        headerTitle = pageHeaderTitle
        self.hidesHeader = hidesHeader
        callToActionTitle = pageNode.callToAction?.text
        hidesCallToAction = pageNode.callToAction == nil
        
        if let heroNode = pageNode.hero {
            hero = MobileContentStackViewModel(node: heroNode)
        }
        else {
            hero = nil
        }
    }
}
