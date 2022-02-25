//
//  MobileContentPageColors.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

// TODO: Is this class still needed with using the multiplatform parser? ~Levi
class MobileContentPageColors {
    
    let backgroundColor: UIColor
    let cardTextColor: UIColor?
    let primaryColor: UIColor
    let primaryTextColor: UIColor
    let textColor: UIColor
    
    required init(pageModel: Page, manifest: Manifest) {
        
        //backgroundColor = pageModel.getBackgroundColor() ?? manifest.attributes.backgroundColor.uiColor
        //cardTextColor = pageModel.getCardTextColor()
        //primaryColor = pageModel.getPrimaryColor() ?? manifest.attributes.primaryColor.uiColor
        //primaryTextColor = pageModel.getPrimaryTextColor() ?? manifest.attributes.primaryTextColor.uiColor
        //textColor = pageModel.getTextColor() ?? manifest.attributes.textColor.uiColor
                
        backgroundColor = .white
        cardTextColor = .black
        primaryColor = .white
        primaryTextColor = .black
        textColor = .black
    }
}
