//
//  MobileContentButtonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentButtonViewModel: NSObject, MobileContentButtonViewModelType {
    
    private let maxAllowedIconSize = 40
    
    private let buttonModel: Button
    private let renderedPageContext: MobileContentRenderedPageContext
    private let mobileContentAnalytics: MobileContentAnalytics
    private let fontService: FontService
    private let fontSize: CGFloat = 18
    private let fontWeight: UIFont.Weight = .regular
    
    private var visibilityFlowWatcher: FlowWatcher?
    
    let backgroundColor: UIColor
    let buttonWidth: MobileContentViewWidth
    let titleColor: UIColor
    let borderColor: UIColor?
    let visibilityState: ObservableValue<MobileContentViewVisibilityState> = ObservableValue(value: .visible)
    let icon: MobileContentButtonIcon?
    
    required init(buttonModel: Button, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.buttonModel = buttonModel
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
        self.fontService = fontService
        
        buttonWidth = MobileContentViewWidth(dimension: buttonModel.width)
        
        let defaultBackgroundColor: UIColor = buttonModel.buttonColor
        let defaultTitleColor: UIColor = buttonModel.text.textColor
        let defaultBorderColor: UIColor = .clear
                                
        switch buttonModel.style {
        
        case .contained:
            backgroundColor = defaultBackgroundColor
            titleColor = defaultTitleColor
            borderColor = defaultBorderColor
            
        case .outlined:
            backgroundColor = buttonModel.backgroundColor
            titleColor = buttonModel.buttonColor
            borderColor = buttonModel.buttonColor
            
        case .unknown:
            backgroundColor = defaultBackgroundColor
            titleColor = defaultTitleColor
            borderColor = defaultBorderColor
            
        default:
            backgroundColor = defaultBackgroundColor
            titleColor = defaultTitleColor
            borderColor = defaultBorderColor
        }
                
        if let resource = buttonModel.icon, let image = renderedPageContext.resourcesCache.getUIImage(resource: resource)  {
            
            let iconSize = min(Int(buttonModel.iconSize), maxAllowedIconSize)
                    
            let scaledImage = image.scalePreservingAspectRatio(targetSize: CGSize(width: iconSize, height: iconSize))
            
            self.icon = MobileContentButtonIcon(size: buttonModel.iconSize, gravity: buttonModel.iconGravity, image: scaledImage)
        } else {
            
            self.icon = nil
        }
        
        super.init()
        
        visibilityFlowWatcher = buttonModel.watchVisibility(state: renderedPageContext.rendererState, block: { [weak self] (invisible: KotlinBoolean, gone: KotlinBoolean) in
            
            let visibilityStateValue: MobileContentViewVisibilityState
            
            if gone.boolValue {
                visibilityStateValue = .gone
            }
            else if invisible.boolValue {
                visibilityStateValue = .hidden
            }
            else {
                visibilityStateValue = .visible
            }
            
            self?.visibilityState.accept(value: visibilityStateValue)
        })
    }
    
    deinit {
        visibilityFlowWatcher?.close()
    }
    
    private var textScale: Double {
        return buttonModel.text.textScale
    }
    
    var font: UIFont {
                
        let fontScale = CGFloat(textScale)
        
        return fontService.getFont(
            size: fontSize * fontScale,
            weight: fontWeight
        )
    }
    
    var title: String? {
        return buttonModel.text.text
    }
    
    var borderWidth: CGFloat? {
        if borderColor == nil {
            return nil
        }
        return 1
    }
    
    var buttonType: Button.Type_ {
        return buttonModel.type
    }
    
    var buttonEvents: [EventId] {
        return buttonModel.events
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
    
    func getClickableUrl() -> URL? {
        return getClickableUrl(model: buttonModel)
    }
    
    func buttonTapped() {
        trackClickableEvents(model: buttonModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
