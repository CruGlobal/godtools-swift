//
//  MobileContentButtonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentButtonViewModel: MobileContentButtonViewModelType {
    
    private let buttonModel: ContentButtonModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let containerNode: MobileContentContainerNode?
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let backgroundColor: UIColor
    let titleColor: UIColor
    let borderColor: UIColor?
    
    required init(buttonModel: ContentButtonModelType, rendererPageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.buttonModel = buttonModel
        self.rendererPageModel = rendererPageModel
        self.containerNode = containerNode
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        
        let buttonColor: UIColor = buttonModel.getColor() ?? containerNode?.buttonColor?.color ?? rendererPageModel.pageColors.primaryColor
        let buttonTitleColor: UIColor? = buttonModel.getTextColor()
        
        let buttonStyle: MobileContentButtonStyle = buttonModel.style ?? containerNode?.buttonStyle ?? .contained
        
        switch buttonStyle {
        
        case .contained:
            backgroundColor = buttonColor
            titleColor = buttonTitleColor ?? rendererPageModel.pageColors.primaryTextColor
            borderColor = UIColor.clear
        case .outlined:
            backgroundColor = buttonModel.getBackgroundColor() ?? .clear
            titleColor = buttonColor
            borderColor = buttonColor
        }
    }
    
    var font: UIFont {
        return fontService.getFont(size: fontSize, weight: fontWeight)
    }
    
    var title: String? {
        return buttonModel.text
    }
    
    var borderWidth: CGFloat? {
        if borderColor == nil {
            return nil
        }
        return 1
    }
    
    var buttonType: MobileContentButtonType {
        return buttonModel.type
    }
    
    var buttonEvents: [String] {
        return buttonModel.events
    }
    
    var buttonUrl: String {
        return buttonModel.url ?? ""
    }
    
    func buttonTapped() {
        mobileContentAnalytics.trackEvents(events: buttonModel.getAnalyticsEvents(), rendererPageModel: rendererPageModel)
    }
}
