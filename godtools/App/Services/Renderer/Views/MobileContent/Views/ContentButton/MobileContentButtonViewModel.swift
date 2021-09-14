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
    private let containerModel: MobileContentRenderableModelContainer?
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    let backgroundColor: UIColor
    let titleColor: UIColor
    let borderColor: UIColor?
    
    required init(buttonModel: ContentButtonModelType, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.buttonModel = buttonModel
        self.rendererPageModel = rendererPageModel
        self.containerModel = containerModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        
        let buttonColor: UIColor = buttonModel.getColor()?.uiColor ?? containerModel?.buttonColor?.uiColor ?? rendererPageModel.pageColors.primaryColor.uiColor
        let buttonTitleColor: UIColor? = buttonModel.getTextColor()?.uiColor
        
        let buttonStyle: MobileContentButtonStyle = buttonModel.style ?? containerModel?.buttonStyle ?? .contained
        
        switch buttonStyle {
        
        case .contained:
            backgroundColor = buttonColor
            titleColor = buttonTitleColor ?? rendererPageModel.pageColors.primaryTextColor.uiColor
            borderColor = UIColor.clear
        case .outlined:
            backgroundColor = buttonModel.getBackgroundColor()?.uiColor ?? .clear
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
    
    var buttonEvents: [MultiplatformEventId] {
        return buttonModel.events
    }
    
    var buttonUrl: String {
        return buttonModel.url ?? ""
    }
    
    var rendererState: MobileContentMultiplatformState {
        return rendererPageModel.rendererState
    }
    
    func buttonTapped() {
        mobileContentAnalytics.trackEvents(events: buttonModel.getAnalyticsEvents(), rendererPageModel: rendererPageModel)
    }
}
