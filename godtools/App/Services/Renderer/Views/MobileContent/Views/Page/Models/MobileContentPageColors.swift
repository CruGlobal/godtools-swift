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
    
    required init(pageModel: PageModelType, manifest: MobileContentManifestType) {
        
        backgroundColor = pageModel.getBackgroundColor() ?? manifest.attributes.backgroundColor
        cardTextColor = pageModel.getCardTextColor()
        primaryColor = pageModel.getPrimaryColor() ?? manifest.attributes.primaryColor
        primaryTextColor = pageModel.getPrimaryTextColor() ?? manifest.attributes.primaryTextColor
        textColor = pageModel.getTextColor() ?? manifest.attributes.textColor
    }
}
