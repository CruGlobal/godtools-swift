//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: ToolPageViewModelType {
        
    let headerNumber: String?
    let headerTitle: String?
    let hidesHeader: Bool
    let hidesHero: Bool
    let heroView: MobileContentStackView?
    let callToActionTitle: String?
    let hidesCallToAction: Bool
    
    required init(pageNode: PageNode) {
        
        let pageHeaderNumber: String? = pageNode.header?.number
        let pageHeaderTitle: String? = pageNode.header?.title
        
        headerNumber = pageHeaderNumber
        headerTitle = pageHeaderTitle
        hidesHeader = pageHeaderNumber == nil && pageHeaderTitle == nil
        hidesHero = pageNode.hero == nil
        callToActionTitle = pageNode.callToAction?.text
        hidesCallToAction = pageNode.callToAction == nil
        
        if let heroNode = pageNode.hero {
            heroView = nil
        }
        else {
            heroView = nil
        }
    }
}
