//
//  ToolPageCallToActionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCallToActionViewModel {
    
    let callToActionTitle: String?
    let callToActionTitleColor: UIColor
    let callToActionNextButtonColor: UIColor
    let hidesCallToAction: Bool
    
    required init(pageNode: PageNode, toolPageColors: ToolPageColorsViewModel) {
        
        callToActionTitle = pageNode.callToActionNode?.textNode?.text
        callToActionTitleColor = pageNode.callToActionNode?.textNode?.getTextColor()?.color ?? toolPageColors.primaryTextColor
        callToActionNextButtonColor = pageNode.callToActionNode?.getControlColor()?.color ?? toolPageColors.primaryColor
        hidesCallToAction = pageNode.callToActionNode == nil
    }
}
