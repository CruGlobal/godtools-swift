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
    
    required init(pageNode: PageNode, primaryColor: UIColor, primaryTextColor: UIColor) {
        
        callToActionTitle = pageNode.callToActionNode?.textNode?.text
        callToActionTitleColor = pageNode.callToActionNode?.textNode?.getTextColor()?.color ?? primaryTextColor
        callToActionNextButtonColor = pageNode.callToActionNode?.getControlColor()?.color ?? primaryColor
        hidesCallToAction = pageNode.callToActionNode == nil
    }
}
