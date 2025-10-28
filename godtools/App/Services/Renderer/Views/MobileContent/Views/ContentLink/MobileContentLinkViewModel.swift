//
//  MobileContentLinkViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class MobileContentLinkViewModel: MobileContentViewModel {
    
    private let linkModel: Link
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let mobileContentAnalytics: MobileContentRendererAnalytics
    let titleColor: UIColor
    
    init(linkModel: Link, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.linkModel = linkModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.titleColor = linkModel.text.textColor.toUIColor()
        
        super.init(baseModel: linkModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var backgroundColor: UIColor {
        return .clear
    }
    
    var font: UIFont {
        return FontLibrary.systemUIFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return linkModel.text.text
    }
}
