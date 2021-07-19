//
//  MobileContentPageColors.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentPageColors {
    
    let backgroundColor: UIColor
    let cardTextColor: UIColor?
    let primaryColor: UIColor
    let primaryTextColor: UIColor
    let textColor: UIColor
    
    required init(pageModel: PageModelType, manifest: MobileContentXmlManifest) {
        
        backgroundColor = pageModel.getBackgroundColor()?.color ?? manifest.attributes.getBackgroundColor().color
        cardTextColor = pageModel.getCardTextColor()?.color
        primaryColor = pageModel.getPrimaryColor()?.color ?? manifest.attributes.getPrimaryColor().color
        primaryTextColor = pageModel.getPrimaryTextColor()?.color ?? manifest.attributes.getPrimaryTextColor().color
        textColor = pageModel.getTextColor()?.color ?? manifest.attributes.getTextColor().color
    }
}
