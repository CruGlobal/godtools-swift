//
//  MobileContentButtonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentButtonViewModel: MobileContentButtonViewModelType {
    
    private let buttonNode: ContentButtonNode
    private let pageModel: MobileContentRendererPageModel
    private let containerStyles: MobileContentNodeStyles?
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let backgroundColor: UIColor
    let titleColor: UIColor
    let borderColor: UIColor?
    
    required init(buttonNode: ContentButtonNode, pageModel: MobileContentRendererPageModel, containerStyles: MobileContentNodeStyles?, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.buttonNode = buttonNode
        self.pageModel = pageModel
        self.containerStyles = containerStyles
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        
        let buttonColor: UIColor = buttonNode.getColor()?.color ?? containerStyles?.buttonColor?.color ?? pageModel.pageColors.primaryColor
        let buttonTitleColor: UIColor? = buttonNode.textNode?.getTextColor()?.color
        
        let buttonStyle: MobileContentButtonNodeStyle = buttonNode.buttonStyle ?? containerStyles?.buttonStyle ?? .contained
        
        switch buttonStyle {
        
        case .contained:
            backgroundColor = buttonColor
            titleColor = buttonTitleColor ?? pageModel.pageColors.primaryTextColor
            borderColor = UIColor.clear
        case .outlined:
            backgroundColor = buttonNode.getBackgroundColor()?.color ?? .clear
            titleColor = buttonColor
            borderColor = buttonColor
        }
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return buttonNode.textNode?.text
    }
    
    var borderWidth: CGFloat? {
        if borderColor == nil {
            return nil
        }
        return 1
    }
    
    var buttonType: MobileContentButtonNodeType {
        return buttonNode.buttonType
    }
    
    var buttonEvents: [String] {
        return buttonNode.events
    }
    
    var buttonUrl: String {
        return buttonNode.url ?? ""
    }
    
    func buttonTapped() {
        if let analyticsEventsNode = buttonNode.analyticsEventsNode {
            mobileContentAnalytics.trackEvents(events: analyticsEventsNode)
        }
    }
}
