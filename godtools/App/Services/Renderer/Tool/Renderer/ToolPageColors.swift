//
//  ToolPageColors.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageColors {
    
    let backgroundColor: UIColor
    let cardTextColor: UIColor?
    let primaryColor: UIColor
    let primaryTextColor: UIColor
    let textColor: UIColor
    
    required init(pageNode: PageNode, manifest: MobileContentXmlManifest) {
        
        backgroundColor = pageNode.getBackgroundColor()?.color ?? manifest.attributes.getBackgroundColor().color
        cardTextColor = pageNode.getCardTextColor()?.color
        primaryColor = pageNode.getPrimaryColor()?.color ?? manifest.attributes.getPrimaryColor().color
        primaryTextColor = pageNode.getPrimaryTextColor()?.color ?? manifest.attributes.getPrimaryTextColor().color
        textColor = pageNode.getTextColor()?.color ?? manifest.attributes.getTextColor().color
    }
}
