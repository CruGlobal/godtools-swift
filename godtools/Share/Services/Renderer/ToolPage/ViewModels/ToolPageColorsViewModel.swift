//
//  ToolPageColorsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/4/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageColorsViewModel {
    
    let primaryColor: UIColor
    let primaryTextColor: UIColor
    let textColor: UIColor
    
    required init(pageNode: PageNode, manifest: MobileContentXmlManifest) {
        
        primaryColor = pageNode.getPrimaryColor()?.color ?? manifest.attributes.getPrimaryColor().color
        primaryTextColor = pageNode.getPrimaryTextColor()?.color ?? manifest.attributes.getPrimaryTextColor().color
        textColor = pageNode.getTextColor()?.color ?? manifest.attributes.getTextColor().color
    }
}
