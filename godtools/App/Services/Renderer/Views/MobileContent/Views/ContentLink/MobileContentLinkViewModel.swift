//
//  MobileContentLinkViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentLinkViewModel: MobileContentViewModel {
    
    private let linkModel: Link
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let mobileContentAnalytics: MobileContentAnalytics
    let titleColor: UIColor
    
    init(linkModel: Link, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.linkModel = linkModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        self.titleColor = linkModel.text.textColor
        
        super.init(baseModel: linkModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var backgroundColor: UIColor {
        return .clear
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return linkModel.text.text
    }
}
